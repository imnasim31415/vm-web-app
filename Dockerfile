FROM python:3.11-slim

# Re-declare inside the build context
ARG GIT_BRANCH
ARG GIT_COMMIT
ARG GIT_MESSAGE

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

# Debug print
RUN echo "Branch: $GIT_BRANCH" && echo "Commit: $GIT_COMMIT" && echo "Message: $GIT_MESSAGE"

RUN echo "$GIT_BRANCH" > git_info.txt && \
    echo "$GIT_COMMIT" >> git_info.txt && \
    echo "$GIT_MESSAGE" >> git_info.txt

EXPOSE 5000
CMD ["python", "app.py"]
