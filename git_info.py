def get_git_info():
    info = {
        'commit_hash': 'N/A',
        'commit_msg': 'N/A',
        'branch_name': 'N/A'
    }
    try:
        with open('build_info.txt', 'r') as f:
            for line in f:
                k, v = line.strip().split('=', 1)
                info[k] = v
    except Exception:
        pass
    return info
