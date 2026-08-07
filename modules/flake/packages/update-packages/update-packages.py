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
    log: str | None = None

    @property
    def failed(self) -> bool:
        """The update script exited with an error."""
        return self.log is not None

    @property
    def changed(self) -> bool:
        """The update script raised the version."""
        return self.before != self.after

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


def version(package: str) -> str:
    """Return the version of a package, or an empty string."""
    result = run("nix", "eval", "--raw", f".#{package}.version")
    return result.stdout if result.returncode == 0 else ""


def update(package: str) -> Result:
    """Run the update script of one package."""
    before = version(package)
    result = run(NIX_UPDATE, "--flake", "--use-update-script", package)

    if result.returncode != 0:
        return Result(package, log=result.stdout + result.stderr)

    return Result(package, before=before, after=version(package))


def verify(packages: Iterable[str]) -> list[str]:
    """Return a message for each name that this command cannot update."""
    problems = []

    for package in packages:
        if package not in KNOWN:
            problems.append(f"{package} is not a package in this flake")
        elif package not in UPDATABLE:
            problems.append(f"{package} has no update script")

    return problems


def update_all(packages: Sequence[str]) -> list[Result]:
    """Update each package, and spin on its line until the update ends."""
    failures = []

    columns = [Mark(style="blue"), TextColumn("{task.description}")]

    with Progress(*columns, console=OUT) as progress:
        tasks = {
            package: progress.add_task(package, total=1, mark="")
            for package in packages
        }

        with ThreadPoolExecutor() as pool:
            futures = [pool.submit(update, package) for package in packages]

            for future in as_completed(futures):
                result = future.result()
                progress.update(
                    tasks[result.package],
                    description=result.line(),
                    mark=result.mark,
                    completed=1,
                )

                if result.failed:
                    failures.append(result)

    return failures


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
        "packages",
        nargs="*",
        default=UPDATABLE,
        metavar="PACKAGE",
        help="the packages to update (default: every updatable package)",
    )
    packages = parser.parse_args().packages

    problems = verify(packages)
    if problems:
        for problem in problems:
            ERR.print(f"[red]✗[/] {problem}")
        return 1

    failures = update_all(packages)
    if not failures:
        return 0

    report(failures)
    return 1


if __name__ == "__main__":
    sys.exit(main())
