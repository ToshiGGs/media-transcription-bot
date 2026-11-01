FROM python:3.15-slim@sha256:94d3426f1def7db4a106a232ac121bfd975393e5dfd40a619b955fae45fe7913 AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates ffmpeg nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.lock ./

RUN python -m pip install --no-cache-dir --require-hashes -r requirements.lock \
    && rm requirements.lock \
    && adduser --disabled-password --gecos "" --home /nonexistent \
       --shell /usr/sbin/nologin --no-create-home --uid 10001 appuser

COPY src ./src

ENV PYTHONPATH=/app/src

USER 10001:10001

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=4 \
  CMD ["python", "-m", "media_transcription_bot.health"]

ENTRYPOINT ["python", "-m", "media_transcription_bot"]
