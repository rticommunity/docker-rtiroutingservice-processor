FROM python:3.7.2-alpine3.7
RUN adduser -D myuser
USER myuser
WORKDIR /artifacts
CMD ["python", "-m", "http.server"]