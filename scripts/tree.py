from pathlib import Path

root = Path(".")
max_depth = 4

def is_hidden(rel: Path) -> bool:
    # skip anything with a hidden component: .git, .config, .cache, etc.
    return any(part.startswith(".") for part in rel.parts)

paths = sorted(root.rglob("*"), key=lambda p: (p.is_file(), str(p)))
for p in paths:
    rel = p.relative_to(root)
    if len(rel.parts) > max_depth:
        continue
    if is_hidden(rel):
        continue

    indent = "  " * (len(rel.parts) - 1)
    name = rel.parts[-1] + ("/" if p.is_dir() else "")
    print(f"{indent}{name}")

