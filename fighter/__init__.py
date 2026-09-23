"""Arcade Coder — Grok + tools + kit pad.

    from fighter import Agent, serve, tool

    agent = Agent("Arcade Coder", extra_instructions="Keep replies short.")
    serve(agent)

Shell:

    python3 -m fighter --name "Arcade Coder"
    ARCADE_KIT=ghost python3 love2d/run.py
"""
from fighter.agent import Agent, AgentConfig
from fighter.server import serve
from fighter.tools import Tool, builtin_tools, tool

__all__ = [
    "Agent",
    "AgentConfig",
    "Tool",
    "builtin_tools",
    "serve",
    "tool",
]
