FROM python:3.11-slim

WORKDIR /app

COPY . /app

# Install Git temporarily to capture info
RUN apt-get update && apt-get install -y git && \
    echo "commit_hash=$(git rev-parse HEAD)" > build_info.txt && \
    echo "commit_msg=$(git log -1 --pretty=%B)" >> build_info.txt && \
    echo "branch_name=$(git rev-parse --abbrev-ref HEAD)" >> build_info.txt && \
    apt-get remove -y git && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*


RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
