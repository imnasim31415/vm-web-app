FROM python:3.11-slim

WORKDIR /app

COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Get git info before copying to docker image
RUN chmod +x get_git_info.sh && ./get_git_info.sh

EXPOSE 5000

CMD ["python", "app.py"]
