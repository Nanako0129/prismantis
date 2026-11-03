import json, os, subprocess, sys
import pathlib
S = os.environ.get('SHOTS_DIR', os.path.expanduser('~/.cache/prismantis-shots'))
HERE = str(pathlib.Path(__file__).resolve().parent)
haze = {'alertNoteColor': '#a1b5d8', 'alertTipColor': '#b7d6a6', 'alertImportantColor': '#c4b7dc', 'alertWarningColor': '#ebc98e', 'alertCautionColor': '#e3968f'}
reply = 'Reply in English. Reply with exactly this sentence and nothing else: The test passes now.'
skill = 'Reply in English. Use the Skill tool to load the skill named keybindings-help. After it loads, do nothing else: reply only with the word loaded.'
alerts = 'Reply in English. Reply with five GitHub alerts and nothing else: one each of NOTE, TIP, IMPORTANT, WARNING and CAUTION, each with a one-line body of at most six words.'
code = 'Reply in English. Reply with only a typescript code block, no prose: 40 lines, line N is exactly `export const nN = N`, for N from 1 to 40.'
sleep = 'Reply in English. Use the Bash tool to run exactly this command and nothing else: sleep 9'
def run(name, src, opts, steps, snaps='', rows='34'):
    env = dict(os.environ, SNAPS=snaps, SHOT_CWD=os.environ.get('SHOT_CWD', '/tmp/prismantis-demo'))
    r = subprocess.run([f'{HERE}/shoot.sh', f'{S}/src/{src}', name, '100', rows, json.dumps(opts), json.dumps(steps), '--model', 'haiku'], env=env, capture_output=True, text=True)
    print(name, r.returncode, (r.stdout + r.stderr).strip().replace('\n', ' | '), flush=True)
    for png in [l for l in r.stdout.split() if l.endswith('.png')]:
        subprocess.run([f'{S}/crop', png, png.replace('.png', '-c.png'), '84'])
ask = lambda text, wait=30: [[20, text], [1, '\r'], [wait, '']]
blinky = [[20, sleep], [1, '\r'], [9, ''], [0.25, ''], [0.25, ''], [0.25, ''], [0.25, ''], [8, '']]
queue = [[20, sleep], [1, '\r'], [7, 'what is 2+2?'], [1, '\r'], [1, ''], [0.5, ''], [15, '']]
jobs = [
  ('skill-before', 'upstream-main', {}, ask(skill, 40)),
  ('skill-after', 'skill-row-name', {}, ask(skill, 40)),
  ('reply-before', 'upstream-main', {}, ask(reply)),
  ('border-after', 'reply-border-color', {'replyBorderColor': '#c4b7dc'}, ask(reply)),
  ('labels-small', 'reply-labels', {'bubbleLabels': 'small'}, ask(reply)),
  ('labels-off', 'reply-labels', {'bubbleLabels': 'off'}, ask(reply)),
  ('alerts-before', 'upstream-main', {}, ask(alerts, 35), '', '60'),
  ('alerts-after', 'alert-colors', haze, ask(alerts, 35), '', '60'),
  ('folds-before', 'upstream-main', {}, ask(code, 40), '', '60'),
  ('folds-after', 'folds-open', {'folds': 'open'}, ask(code, 40), '', '60'),
  ('blink-before', 'upstream-main', {}, blinky, '3'),
  ('blink-after', 'blink', {'runningDot': 'blink'}, blinky, '3 4 5 6'),
  ('unread-before', 'upstream-main', {}, queue, '4 5'),
  ('unread-after', 'blink', {'unreadPrompts': True}, queue, '4 5'),
]
only = sys.argv[1:]
for j in jobs:
    if not only or j[0] in only: run(*j)
print('BATCH DONE', flush=True)
