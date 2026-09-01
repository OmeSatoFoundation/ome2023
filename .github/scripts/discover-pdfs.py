#!/usr/bin/env python3
"""Discover configured textbook and slide PDF sources for GitHub Actions."""

from __future__ import annotations

import json
import os
from pathlib import Path
import sys
import tomllib


ROOT = Path(__file__).resolve().parents[2]


def annotation(level: str, message: str, path: Path | None = None) -> None:
    location = f" file={path.relative_to(ROOT)}" if path is not None else ""
    print(f"::{level}{location}::{message}", file=sys.stderr)


def main() -> int:
    entries: list[dict[str, str]] = []

    for chapter in range(1, 9):
        for document_type in ("textbook", "slide"):
            directory = ROOT / f"{chapter:02d}" / document_type
            config = directory / "llmk.toml"

            if not directory.is_dir():
                annotation("warning", "Directory is missing; skipping it", directory)
                continue
            if not config.is_file():
                annotation("warning", "llmk.toml is missing; skipping it", config)
                continue

            try:
                with config.open("rb") as stream:
                    sources = tomllib.load(stream).get("source", [])
            except (OSError, tomllib.TOMLDecodeError) as error:
                annotation("error", f"Could not parse llmk.toml: {error}", config)
                return 1

            if not isinstance(sources, list) or not all(
                isinstance(source, str) for source in sources
            ):
                annotation("error", "source must be an array of strings", config)
                return 1
            if not sources:
                annotation("warning", "No sources are configured; skipping it", config)
                continue

            for source in sources:
                source_path = directory / source
                if not source_path.is_file():
                    annotation(
                        "warning",
                        f"Configured source {source!r} is missing; skipping it",
                        config,
                    )
                    continue

                entries.append(
                    {
                        "target": str(directory.relative_to(ROOT)),
                        "source": source,
                        "pdf": f"{Path(source).stem}.pdf",
                    }
                )

    by_pdf: dict[str, list[dict[str, str]]] = {}
    for entry in entries:
        by_pdf.setdefault(entry["pdf"], []).append(entry)
    duplicates = {pdf: items for pdf, items in by_pdf.items() if len(items) > 1}
    if duplicates:
        for pdf, items in sorted(duplicates.items()):
            sources = ", ".join(
                f"{item['target']}/{item['source']}" for item in items
            )
            annotation("error", f"Duplicate PDF filename {pdf!r}: {sources}")
        return 1

    matrix = json.dumps({"include": entries}, separators=(",", ":"))
    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with Path(output).open("a", encoding="utf-8") as stream:
            stream.write(f"matrix={matrix}\n")
            stream.write(f"count={len(entries)}\n")
    else:
        print(matrix)

    annotation("notice", f"Discovered {len(entries)} PDF targets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
