from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def index():
    vm_hostname = os.environ.get('VM_HOSTNAME', 'Unknown VM')
    commit_hash = os.environ.get('COMMIT_HASH', 'Unknown Commit')
    return f'''
    <h1>Simple VM Web App Testing</h1>
    <p><strong>VM Hostname:</strong> {vm_hostname}</p>
    <p><strong>Git Commit Hash:</strong> {commit_hash}</p>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
