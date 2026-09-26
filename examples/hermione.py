#!/usr/bin/env python3
"""Demo cabinet: Hermione Granger — wand hand shoots a charm onto the pad.

    ARCADE_KIT=hermione python3 love2d/run.py
    python3 examples/hermione.py
"""
from pathlib import Path

from fighter import Agent, serve

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    agent = Agent(
        "Hermione Granger Coder",
        callsign="CHARM",
        workspace=ROOT,
        extra_instructions=(
            "You are an arcade Hermione Granger coding agent. Short replies. "
            "Raise the wand hand, charm the fix onto the pad, then verify. "
            "A green test is ten points to Gryffindor. It's Leviosa, not Leviosar."
        ),
    )
    return serve(agent)


if __name__ == "__main__":
    raise SystemExit(main())
