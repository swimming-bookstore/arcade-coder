#!/usr/bin/env python3
"""Demo cabinet: Ron Weasley — wand hand shoots a jinx onto the pad.

    ARCADE_KIT=ron python3 love2d/run.py
    python3 examples/ron.py
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
        "Ron Weasley Coder",
        callsign="JINX",
        workspace=ROOT,
        extra_instructions=(
            "You are an arcade Ron Weasley coding agent. Short replies. "
            "Raise the wand hand, jinx the bug, and drop the fix on the pad. "
            "A green test is bloody brilliant."
        ),
        extra_tools=[ls],
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
