#!@python@
"""Run the update script of each package in this flake that has one."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from collections.abc import Iterable, Sequence
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path

from rich.console import Console, RenderableType
from rich.progress import Progress, SpinnerColumn, Task, TextColumn
from rich.text import Text

CONFIG = json.loads(Path("@config@").read_text())

KNOWN: frozenset[str] = frozenset(CONFIG["known"])
UPDATABLE: tuple[str, ...] = tuple(CONFIG["updatable"])
NIX_UPDATE: str = CONFIG["nixUpdate"]

OUT = Console()
ERR = Console(stderr=True)


@dataclass(frozen=True)
class Result:
    """The outcome of one update."""

    package: str
    before: str = ""
    after: str = ""
    homepage: str = ""
    log: str | None = None

    @property
    def failed(self) -> bool:
        """The update script exited with an error."""
        return self.log is not None

    @property
    def changed(self) -> bool:
        """The update script raised the version."""
        return self.before != self.after

    def as_json(self) -> dict[str, object]:
        """Return the result in the machine-readable output format."""
        return {
            "package": self.package,
            "before": self.before,
            "after": self.after,
            "homepage": self.homepage,
            "changed": self.changed,
            "failed": self.failed,
            "log": self.log,
        }

    @property
    def mark(self) -> str:
        """The mark that replaces the spinner, as rich markup."""
        return "[red]✗[/]" if self.failed else "[green]✓[/]"

    def line(self) -> str:
        """The finished line for this package, as rich markup."""
        if self.failed:
            return self.package

        detail = f"{self.before} → {self.after}" if self.changed else "up to date"
        return f"{self.package} [dim]{detail}[/]"


class Mark(SpinnerColumn):
    """Spin while a task runs, then hold the result mark in the same column."""

    def render(self, task: Task) -> RenderableType:
        """Render the spinner, or the mark that the finished task carries."""
        if not task.finished:
            return super().render(task)

        return Text.from_markup(task.fields["mark"])


def run(*command: str) -> subprocess.CompletedProcess[str]:
    """Run a command, and capture its output as text."""
    return subprocess.run(command, capture_output=True, text=True, check=False)


def version(package: str) -> str | None:
    """Return the version of a package, or none when evaluation fails."""
    result = run("nix", "eval", "--raw", f".#{package}.version")
    return result.stdout.strip() if result.returncode == 0 else None


def homepage(package: str) -> str:
    """Return a package's homepage, or an empty string when it has none."""
    result = run("nix", "eval", "--raw", f".#{package}.meta.homepage")
    return result.stdout.strip() if result.returncode == 0 else ""


def update(package: str) -> Result:
    """Run the update script of one package."""
    before = version(package)
    if not before:
        return Result(
            package, log=f"could not evaluate {package}.version before update"
        )

    result = run(NIX_UPDATE, "--flake", "--use-update-script", package)

    if result.returncode != 0:
        return Result(package, log=result.stdout + result.stderr)

    after = version(package)
    if not after:
        return Result(package, log=f"could not evaluate {package}.version after update")

    return Result(package, before=before, after=after, homepage=homepage(package))


def verify(packages: Iterable[str]) -> list[str]:
    """Return a message for each name that this command cannot update."""
    problems = []

    for package in packages:
        if package not in KNOWN:
            problems.append(f"{package} is not a package in this flake")
        elif package not in UPDATABLE:
            problems.append(f"{package} has no update script")

    return problems


def update_all(packages: Sequence[str], *, progress: bool) -> list[Result]:
    """Update each package, optionally spinning on its line until it ends."""
    if not progress:
        return [update(package) for package in packages]

    results = []
    columns = [Mark(style="blue"), TextColumn("{task.description}")]

    with Progress(*columns, console=OUT) as display:
        tasks = {
            package: display.add_task(package, total=1, mark="") for package in packages
        }

        with ThreadPoolExecutor() as pool:
            futures = [pool.submit(update, package) for package in packages]

            for future in as_completed(futures):
                result = future.result()
                display.update(
                    tasks[result.package],
                    description=result.line(),
                    mark=result.mark,
                    completed=1,
                )
                results.append(result)

    return results


def report(failures: Sequence[Result]) -> None:
    """Print each failure, and keep its log in a temporary directory."""
    log_dir = Path(tempfile.mkdtemp(prefix="update-packages-"))

    ERR.print(f"{len(failures)} package(s) failed:")

    for result in failures:
        log = log_dir / f"{result.package}.log"
        log.write_text(result.log or "")

        ERR.rule(result.package)
        ERR.print(result.log, markup=False, highlight=False, end="")
        ERR.print(f"[dim]log: {log}[/]")


def main() -> int:
    """Verify the given names, update them in parallel, and report."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_output",
        help="print structured JSON instead of progress output",
    )
    parser.add_argument(
        "packages",
        nargs="*",
        default=UPDATABLE,
        metavar="PACKAGE",
        help="the packages to update (default: every updatable package)",
    )
    args = parser.parse_args()
    packages = args.packages

    problems = verify(packages)
    if problems:
        for problem in problems:
            ERR.print(f"[red]✗[/] {problem}")
        return 1

    results = update_all(packages, progress=not args.json_output)
    failures = [result for result in results if result.failed]

    if args.json_output:
        print(json.dumps([result.as_json() for result in results], indent=2))

    if failures:
        report(failures)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
