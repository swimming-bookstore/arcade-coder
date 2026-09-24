#!/usr/bin/env python3
"""Demo cabinet: Harry Potter — wand hand shoots spell bolts onto the pad.

    ARCADE_KIT=harry python3 love2d/run.py
    python3 examples/harry.py
"""
from pathlib import Path

from fighter import Agent, serve, tool

ROOT = Path(__file__).resolve().parents[1]


@tool(
    "ls",
    "List files in a directory under the workspace.",
    {
        "type": "object",
        "properties": {"path": {"type": "string", "description": "Directory path"}},
        "required": ["path"],
        "additionalProperties": False,
    },
    kind="read",
)
def ls(args: dict) -> str:
    from fighter.tools import resolve_path

    p = resolve_path(ROOT, str(args.get("path") or "."))
    if not p.is_dir():
        raise ValueError(f"not a directory: {p}")
    names = [e.name + ("/" if e.is_dir() else "") for e in sorted(p.iterdir(), key=lambda x: x.name.lower())]
    return "\n".join(names) or "(empty)"


def main() -> int:
    agent = Agent(
        "Harry Potter Coder",
        callsign="WAND",
        workspace=ROOT,
        extra_instructions=(
            "You are an arcade Harry Potter coding agent. Short replies. "
            "Raise the wand hand, shoot the fix onto the pad as a spell, then verify. "
            "A green test is 10 points to Gryffindor."
        ),
        extra_tools=[ls],
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
