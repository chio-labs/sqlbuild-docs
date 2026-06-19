# SQLBuild dbt reuse demo
#
# Renders a full-speed source recording (dbt-reuse-raw.mp4). The final, sped-up
# GIF/MP4 are produced in post with ffmpeg (see README.md in this directory).
#
# Visible in the recording:
#   sqb dbt init  (prompts once for the production git ref)
#   sqb dbt build (run 1: reuse 8 unchanged tables from prod, rebuild the 2 edited)
#   sqb dbt build (run 2: nothing changed, no dbt work)
#
# Only environment prep and the playground scaffold run hidden (one-time setup).
#
# Prerequisites:
#   - vhs, ttyd, ffmpeg on PATH
#   - sqb, dbt, git on PATH (e.g. activate the SQLBuild venv before running vhs)
#   - SQLBUILD_NO_PROGRESS=1 (set inside the tape) so the transient spinner does
#     not redraw over streaming dbt output. Color is preserved.

Output dbt-reuse-raw.mp4

Set Shell bash
Set FontSize 15
Set Width 1300
Set Height 820
Set Padding 16
Set Theme "Dracula"
Set TypingSpeed 30ms

# ---------------------------------------------------------------------------
# Hidden one-time env prep: no-progress flag, fresh dir, scaffold the playground.
# Assumes sqb/dbt/git are already on PATH (activate the venv before running vhs).
# ---------------------------------------------------------------------------
Hide
Type "export SQLBUILD_NO_PROGRESS=1"
Enter
Sleep 500ms
Type "cd $(mktemp -d)"
Enter
Sleep 500ms
Type "sqb playground demo --template dbt"
Enter
Sleep 45s
Type "cd demo"
Enter
Sleep 1s
Type "clear"
Enter
Sleep 500ms
Show

# ---------------------------------------------------------------------------
# Visible recording starts here.
# ---------------------------------------------------------------------------

# Point SQLBuild at the dbt project. Prompts once for the production git ref.
Type "sqb dbt init --project-dir dbt_project --profiles-dir profiles"
Enter
Wait@60s /Production git ref/
Sleep 1s
Type "main"
Enter
Sleep 12s

Type "cd sqlbuild_project"
Enter
Sleep 1s

Type "clear"
Enter
Sleep 500ms

# Run 1: reuse 8 unchanged tables from prod, rebuild only the 2 edited models.
# ~27s to complete; extra dwell lets the finished plan / REUSED=8 sit on screen.
Type "sqb dbt build"
Enter
Sleep 40s

Type "clear"
Enter
Sleep 500ms

# Run 2: nothing changed, no dbt work. ~18s to complete; extra dwell at the end.
Type "sqb dbt build"
Enter
Sleep 30s
