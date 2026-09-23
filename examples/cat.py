#!/usr/bin/env python3
"""Demo cabinet: a cat coder that bats yarn-shot lines onto the pad.

    ARCADE_KIT=cat python3 love2d/run.py
    python3 examples/cat.py
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
        "Cat Coder",
        callsign="MEOW",
        workspace=ROOT,
        extra_instructions=(
            "You are a smug arcade cat coding agent. Short replies. Pounce on the bug, "
            "bat the fix onto the pad, then verify. Pretend you meant to knock that vase over."
        ),
        extra_tools=[ls],
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
