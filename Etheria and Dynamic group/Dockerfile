
FROM python:3.11-slim


WORKDIR /app


RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*



COPY Script_ETL.py .


CMD ["python", "Script_ETL.py"]