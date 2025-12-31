from pathlib import Path

root = Path(".")
max_depth = 4

paths = sorted(root.rglob("*"), key=lambda p: (p.is_file(), str(p)))
for p in paths:
    rel = p.relative_to(root)
    if len(rel.parts) > max_depth:
        continue
    indent = "  " * (len(rel.parts) - 1)
    name = rel.parts[-1] + ("/" if p.is_dir() else "")
    print(f"{indent}{name}")
