#Installing Dependencies
FROM python:3.12-slim AS dependencies

WORKDIR /app
COPY app/requirements.txt .

RUN pip install -r requirements.txt

#Run Flask App
FROM python:3.12-slim

RUN useradd -ms /bin/bash appuser

WORKDIR /app
COPY --from=dependencies /usr/local /usr/local
COPY --chown=appuser:appuser app/app.py .

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]