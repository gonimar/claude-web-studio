#!/usr/bin/env python3
"""Structural checks for the Web Studio plugin: frontmatter, cross-references, JSON, static skill linter."""
import json, os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
fails, warns = [], []
def fail(m): fails.append(m)
def warn(m): warns.append(m)
def fm(path):
    s = open(path, encoding='utf-8').read()
    if not s.startswith('---\n'): fail(f'{path}: frontmatter must start on line 1'); return {}, s
    end = s.find('\n---', 4)
    head = s[4:end]; body = s[end+4:]
    d = {}
    for line in head.splitlines():
        m = re.match(r'^([\w-]+):\s*(.*)$', line)
        if m: d[m.group(1)] = m.group(2)
    return d, body

# JSON files
for j in ['.claude-plugin/plugin.json', '.claude-plugin/marketplace.json', 'hooks/hooks.json', 'templates/settings.json', 'templates/settings.plugin-mode.json']:
    try: json.load(open(j))
    except Exception as e: fail(f'{j}: invalid JSON ({e})')

# Agents
agents = sorted(f[:-3] for f in os.listdir('agents') if f.endswith('.md'))
for a in agents:
    d, body = fm(f'agents/{a}.md')
    for k in ('name', 'description', 'model', 'tools'):
        if k not in d: fail(f'agents/{a}.md: missing {k}')
    if d.get('name') != a: fail(f'agents/{a}.md: name mismatch')
    if 'Collaboration protocol' not in body: fail(f'agents/{a}.md: no collaboration protocol')
    if 'stack-reference' not in body and a != 'tech-writer': warn(f'agents/{a}.md: no stack-reference link')
    for s in re.findall(r'^skills:\s*\[(.*)\]', open(f'agents/{a}.md').read(), re.M):
        for sk in [x.strip() for x in s.split(',') if x.strip()]:
            if not os.path.isdir(f'skills/{sk}'): fail(f'agents/{a}.md: preloads unknown skill {sk}')

# Skills — static linter (mirrors /skill-test static)
VERDICTS = r'\b(PASS|FAIL|CONCERNS|APPROVED|ACCEPTED|PROPOSED|NEEDS (REVISION|CHANGES)|BLOCKED|COMPLETE|READY|DONE|UPDATED|CLEAN|RELEASED|DEPLOYED|HARDENED|PLAYABLE|COMPLIANT|INITIALISED|RESOLVED|MITIGATED|(WITHIN|OVER) BUDGET|ON TRACK|AT RISK|OFF TRACK|FIXED|IMPROVED)\b'
skills = sorted(os.listdir('skills'))
for s in skills:
    p = f'skills/{s}/SKILL.md'
    if not os.path.isfile(p): fail(f'{p}: missing'); continue
    d, body = fm(p)
    for k in ('name', 'description', 'argument-hint', 'user-invocable', 'allowed-tools'):
        if k not in d: fail(f'{p}: missing {k}')
    if d.get('name') != s: fail(f'{p}: name mismatch')
    if len(re.findall(r'^## ', body, re.M)) < 2: fail(f'{p}: fewer than 2 phases')
    if not re.search(VERDICTS, body): fail(f'{p}: no verdict word')
    if re.search(r'Write|Edit', d.get('allowed-tools', '')) and 'May I write' not in body: fail(f'{p}: Write/Edit allowed but no "May I write" gate')
    if 'Next step' not in body: warn(f'{p}: no next step')
    if not d.get('argument-hint', '').strip('"'): warn(f'{p}: empty argument-hint')
    ag = d.get('agent')
    if ag and not os.path.isfile(f'agents/{ag}.md'): fail(f'{p}: unknown agent {ag}')
    if re.search(r'[\u0400-\u04ff]', body): fail(f'{p}: non-English text')

# Catalog ↔ files
cat = open('testing/catalog.yaml').read()
cs = set(re.findall(r'\{name: ([\w-]+), category', cat)); ca = set(re.findall(r'\{name: ([\w-]+), tier', cat))
for n, sp in re.findall(r'\{name: ([\w-]+), (?:category|tier): [\w-]+.*?spec: (\S+)\}', cat):
    if not os.path.isfile(sp): fail(f'catalog: spec missing {sp}')
if set(skills) - cs: fail(f'skills not in catalog: {sorted(set(skills) - cs)}')
if set(agents) - ca: fail(f'agents not in catalog: {sorted(set(agents) - ca)}')
if cs - set(skills): fail(f'catalog skills without files: {sorted(cs - set(skills))}')
if ca - set(agents): fail(f'catalog agents without files: {sorted(ca - set(agents))}')

# Workflow catalog and roster
for cmd in set(re.findall(r'command: /([\w-]+)', open('docs/workflow-catalog.yaml').read())):
    if not os.path.isdir(f'skills/{cmd}'): fail(f'workflow-catalog: unknown command /{cmd}')
for a in set(re.findall(r'^\| `([a-z0-9-]+)`', open('docs/agent-roster.md').read(), re.M)):
    if not os.path.isfile(f'agents/{a}.md'): fail(f'roster: unknown agent {a}')

# Hooks referenced exist
for h in set(re.findall(r'hooks/([a-z-]+\.sh)', open('hooks/hooks.json').read())):
    if not os.path.isfile(f'hooks/{h}'): fail(f'hooks.json: missing hooks/{h}')
for h in set(re.findall(r'\.claude/hooks/([a-z-]+\.sh)', open('templates/settings.json').read())):
    if not os.path.isfile(f'hooks/{h}'): fail(f'settings.json: missing hooks/{h}')

# README command coverage
for r in ['README.md'] + [f'docs/readme/{f}' for f in os.listdir('docs/readme')]:
    txt = open(r, encoding='utf-8').read()
    miss = [s for s in skills if f'`/{s}`' not in txt]
    if miss: fail(f'{r}: commands not documented: {miss}')

# Stack reference dated
for f in os.listdir('docs/stack-reference'):
    if not re.search(r'^updated: \d{4}-\d{2}-\d{2}', open(f'docs/stack-reference/{f}').read(), re.M): fail(f'stack-reference/{f}: no updated date')

# Non-English content outside translations
for dp, _, fs in os.walk('.'):
    if any(x in dp for x in ('/.git', '/dev', '/docs/readme', '/node_modules')): continue
    for f in fs:
        if f.endswith(('.md', '.sh', '.json', '.yaml', '.py', '.yml')):
            if f == 'validate-structure.py': continue
            for line in open(os.path.join(dp, f), encoding='utf-8', errors='ignore'):
                if 'docs/readme/' in line: continue  # language switcher
                if re.search(r'[\u0400-\u04ff\u4e00-\u9fff]', line): fail(f'{os.path.join(dp, f)}: non-English text outside docs/readme'); break

print(f'agents: {len(agents)}  skills: {len(skills)}  warnings: {len(warns)}  failures: {len(fails)}')
for w in warns: print('WARN', w)
for f in fails: print('FAIL', f)
sys.exit(1 if fails else 0)
