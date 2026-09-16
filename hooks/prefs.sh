#!/bin/bash
# Is the stack chosen? One definition, used by session-start.sh (the startup banner) and by
# install.sh (whether the seeding may overwrite technical-preferences.md).
#
# "Configured" is the `**Type**` field being filled — the same predicate docs/workflow-catalog.yaml
# uses for the setup-stack step. A whole-file grep for the placeholder never sees a configured file:
# the template's own header comment says "While [TO BE CONFIGURED] remains, skills treat the stack
# as not chosen", and projects keep that line (WS-082 fixed this in the installer, WS-113 in the
# banner, which was still telling fully configured projects to run /setup-stack at every start).
configured_prefs() { # <path to technical-preferences.md>
  [ -f "$1" ] && grep -qE '^[[:space:]]*-[[:space:]]*\*\*Type\*\*:' "$1" \
    && ! grep -qE '^[[:space:]]*-[[:space:]]*\*\*Type\*\*:[[:space:]]*\[TO BE CONFIGURED\]' "$1"
}
