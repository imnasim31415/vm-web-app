from flask import Flask, render_template
import socket
from git_info import get_git_info

app = Flask(__name__)

@app.route('/')
def index():
    hostname = socket.gethostname()
    git_info = get_git_info()
    return render_template('index.html', hostname=hostname, git_info=git_info)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
