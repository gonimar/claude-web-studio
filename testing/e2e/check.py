#!/usr/bin/env python3
"""Assert studio behaviour from a headless run's stream-json + the fixture's filesystem/git.

Usage: check.py --branch B9 <project-dir> <turn.jsonl> [...]
Branches map to scenario-pipeline.md. Exit 0 = all assertions pass.
"""
import argparse, json, os, re, subprocess, sys

ap = argparse.ArgumentParser()
ap.add_argument("--branch", required=True)
ap.add_argument("dir")
ap.add_argument("files", nargs="+")
a = ap.parse_args()

events = []  # (name, input|text) in order
for path in a.files:
    with open(path) as f:
        for line in f:
            try:
                j = json.loads(line)
            except json.JSONDecodeError:
                continue
            m = j.get("message")
            if not isinstance(m, dict):
                continue
            c = m.get("content")
            if not isinstance(c, list):
                continue
            for x in c:
                if not isinstance(x, dict):
                    continue
                if x.get("type") == "tool_use":
                    events.append((x.get("name"), x.get("input") or {}))
                elif x.get("type") == "text":
                    events.append(("TEXT", {"text": x.get("text", "")}))

def texts():
    return "\n".join(i["text"] for n, i in events if n == "TEXT")

def writes(pattern=""):
    return [i.get("file_path", "") for n, i in events if n in ("Write", "Edit")
            and re.search(pattern, str(i.get("file_path", "")))]

def bash(pattern):
    return [i.get("command", "") for n, i in events if n == "Bash"
            and re.search(pattern, i.get("command", ""))]

def git(*args):
    return subprocess.run(["git", "-C", a.dir, *args], capture_output=True, text=True).stdout.strip()

fails = []
def check(name, ok, note=""):
    print(("PASS " if ok else "FAIL "), name, f"[{note}]")
    if not ok:
        fails.append(name)

B = a.branch.upper()
if B == "B3":  # no write before the first consent question
    gate = next((i for i, (n, inp) in enumerate(events) if
                 (n == "AskUserQuestion") or
                 (n == "TEXT" and "?" in inp.get("text", "") and
                  re.search("May I write|\u0437\u0430\u043f\u0438\u0441", inp.get("text", ""), re.I))), None)
    first_write = next((i for i, (n, _) in enumerate(events) if n in ("Write", "Edit")), None)
    check("gate exists", gate is not None)
    check("no write before gate", first_write is None or (gate is not None and gate < first_write),
          f"gate={gate} write={first_write}")
elif B == "B4":  # git precondition: never -b, decline path documented separately
    check("no hardcoded init branch", not bash(r"git init\s+-b|--initial-branch"))
    if os.path.isdir(os.path.join(a.dir, ".git")):
        check("branch honours init.defaultBranch",
              git("branch", "--show-current") ==
              (subprocess.run(["git", "config", "--global", "init.defaultBranch"],
                              capture_output=True, text=True).stdout.strip() or "master"),
              git("branch", "--show-current"))
elif B == "B5":  # preferences: draft/ask before write
    w = next((i for i, (n, inp) in enumerate(events) if n in ("Write", "Edit")
              and "technical-preferences" in str(inp.get("file_path", ""))), None)
    q = next((i for i, (n, inp) in enumerate(events)
              if "preferences" in json.dumps(inp, ensure_ascii=False) and
              (n == "AskUserQuestion" or (n == "TEXT" and "?" in inp.get("text", "")))), None)
    check("ask before preferences write", w is None or (q is not None and q < w), f"q={q} w={w}")
elif B == "B9":  # dev-story blocked without test-strategy
    t = texts()
    check("BLOCKED verdict", "BLOCKED" in t)
    check("names /test-setup", "/test-setup" in t)
    check("no files written", not writes(), str(writes()[:2]))
elif B == "B11":  # documents lane: commit gate + branch named after an authoring write
    t = texts()
    br = git("branch", "--show-current")
    check("current branch named", br in t, br)
    check("commit gate offered", re.search("docs:|\u043a\u043e\u043c\u043c\u0438\u0442|commit", t, re.I) is not None)
elif B == "B15":  # help version drift
    t = texts()
    check("drift line names /update", "/update" in t)
else:
    print(f"branch {B} has no automated checks yet (see scenario-pipeline.md)"); sys.exit(0)

print("VERDICT:", "FAIL " + str(len(fails)) if fails else "PASS")
sys.exit(1 if fails else 0)
