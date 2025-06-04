ARG GIT_BRANCH
ARG GIT_COMMIT
ARG GIT_MESSAGE

FROM python:3.11-slim
WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

# Save git metadata
RUN echo "$GIT_BRANCH" > git_info.txt && \
    echo "$GIT_COMMIT" >> git_info.txt && \
    echo "$GIT_MESSAGE" >> git_info.txt

EXPOSE 5000
CMD ["python", "app.py"]
