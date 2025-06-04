ARG GIT_BRANCH
ARG GIT_COMMIT
ARG GIT_MESSAGE

FROM python:3.11-slim
WORKDIR /app

COPY . .

# Set up Python deps
RUN pip install -r requirements.txt

# Save Git info passed as build args
RUN echo "$GIT_BRANCH" > git_info.txt && \
    echo "$GIT_COMMIT" >> git_info.txt && \
    echo "$GIT_MESSAGE" >> git_info.txt

EXPOSE 5000
CMD ["python", "app.py"]
