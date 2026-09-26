#!/usr/bin/env python3
"""Demo cabinet: Ron Weasley — wand hand shoots a jinx onto the pad.

    ARCADE_KIT=ron python3 love2d/run.py
    python3 examples/ron.py
"""
from pathlib import Path

from fighter import Agent, serve

ROOT = Path(__file__).resolve().parents[1]


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
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
