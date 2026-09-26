#!/usr/bin/env python3
"""Demo cabinet: Harry Potter — wand hand shoots spell bolts onto the pad.

    ARCADE_KIT=harry python3 love2d/run.py
    python3 examples/harry.py
"""
from pathlib import Path

from fighter import Agent, serve

ROOT = Path(__file__).resolve().parents[1]


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
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
