import shutil
import stat
import sys
import zipfile
from pathlib import Path

out = Path(sys.argv[1]) / "steamrtarm64"
for archive, root in zip(sys.argv[2:], ("steamrtarm64",) * 3 + ("steamrt64",)):
    with zipfile.ZipFile(archive) as source:
        for member in source.infolist():
            parts = Path(member.filename.replace("\\", "/")).parts
            if not parts or parts[0] != root or ".." in parts:
                raise ValueError(f"Unexpected archive path: {member.filename}")
            target = out.joinpath(*parts[1:])
            mode = member.external_attr >> 16
            if member.is_dir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.is_symlink() or target.exists():
                target.unlink()
            if stat.S_ISLNK(mode):
                target.symlink_to(source.read(member).decode())
            else:
                with (
                    source.open(member) as input_file,
                    target.open("wb") as output_file,
                ):
                    shutil.copyfileobj(input_file, output_file)
                target.chmod(mode & 0o777 or 0o644)
