from flask import Flask, render_template
import os

app = Flask(__name__)

def read_git_info():
    try:
        with open("git_info.txt", "r") as f:
            lines = f.read().strip().split("\n")
            return {
                "branch": lines[0] if len(lines) > 0 else "N/A",
                "commit": lines[1] if len(lines) > 1 else "N/A",
                "message": lines[2] if len(lines) > 2 else "N/A"
            }
    except Exception as e:
        print(f"Error reading git_info.txt: {e}")
        return {"branch": "N/A", "commit": "N/A", "message": "N/A"}

def get_vm_hostname():
    try:
        with open("/host_hostname", "r") as f:
            return f.read().strip()
    except Exception as e:
        print(f"Error reading /host_hostname: {e}")
        return os.uname().nodename

@app.route("/")
def index():
    git_info = read_git_info()
    hostname = get_vm_hostname()
    return render_template("index.html", git_info=git_info, hostname=hostname)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
