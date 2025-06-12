# Dockerfile

# Build arguments passed from GitHub Actions
ARG GIT_BRANCH
ARG GIT_COMMIT
ARG GIT_MESSAGE

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy app code
COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Write Git info to a file
RUN echo "$GIT_BRANCH" > git_info.txt && \
    echo "$GIT_COMMIT" >> git_info.txt && \
    echo "$GIT_MESSAGE" >> git_info.txt

# Expose Flask app port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
