FROM python:3.11-alpine3.18
LABEL maintainer="rochajunior905@gmail.com"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY djangoapp /djangoapp
COPY scripts /scripts

RUN sed -i 's/\r$//' /scripts/commands.sh && chmod +x /scripts/commands.sh

WORKDIR /djangoapp

EXPOSE 8000

# Instalar dependências do sistema necessárias
RUN apk add --no-cache \
  gcc \
  musl-dev \
  linux-headers \
  postgresql-client && \
  python -m venv /venv && \
  /venv/bin/pip install --upgrade pip && \
  /venv/bin/pip install -r /djangoapp/requirements.txt && \
  adduser --disabled-password --no-create-home duser && \
  mkdir -p /data/web/static && \
  mkdir -p /data/web/media && \
  chown -R duser:duser /venv && \
  chown -R duser:duser /data/web && \
  chown -R duser:duser /djangoapp && \
  chmod -R 755 /data/web && \
  chmod -R +x /scripts

ENV PATH="/scripts:/venv/bin:$PATH"

USER duser

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health/', timeout=5)"

CMD ["commands.sh"]