import subprocess

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode('utf-8').strip()
    except Exception:
        return "N/A"

def get_git_info():
    return {
        'commit_hash': run_cmd(['git', 'rev-parse', 'HEAD']),
        'commit_msg': run_cmd(['git', 'log', '-1', '--pretty=%B']),
        'branch_name': run_cmd(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])
    }
