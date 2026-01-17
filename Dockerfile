ARG RJM_BUILDQUASARAPP_IMAGE=metcarob/docker-build-quasar-app:0.0.30
ARG RJM_VERSION=latest

# Quasar frontend build
FROM --platform=$BUILDPLATFORM ${RJM_BUILDQUASARAPP_IMAGE} AS quasar_build
WORKDIR /frontend
COPY ./frontend .
RUN build_quasar_app /frontend pwa ${RJM_VERSION}

# NGINX alap (bookworm, arm64 ready, minden modul megvan)
FROM nginx:1.27-bookworm AS nginx_base

# Python hozzáadása nginx-hez
FROM nginx:1.27-bookworm AS base
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        build-essential \
        python3-dev \
        gettext-base \
        curl \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

LABEL maintainer="Robert Metcalf" \
      description="Dockjob API + Frontend"

ENV APP_DIR=/app \
    APIAPP_FRONTEND=/frontend \
    APIAPP_APIURL=http://localhost:80/dockjobapi \
    APIAPP_APIDOCSURL=http://localhost:80/apidocs \
    APIAPP_FRONTENDURL=http://localhost:80/frontend \
    APIAPP_APIACCESSSECURITY='[]' \
    APIAPP_USERFORJOBS=dockjobuser \
    APIAPP_GROUPFORJOBS=dockjobgroup \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

EXPOSE 80

# uWSGI + RDS CA
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir uwsgi && \
    wget --no-check-certificate \
        https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
        -O /rds-combined-ca-bundle.pem || true

# Nginx log symlink (dir már létezik)
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# App user
RUN groupadd --system ${APIAPP_GROUPFORJOBS} && \
    useradd --system --no-create-home --shell /bin/false \
            --gid ${APIAPP_GROUPFORJOBS} ${APIAPP_USERFORJOBS}

WORKDIR ${APP_DIR}
COPY ./app/src ${APP_DIR}/
# JAVÍTOTT SOR: --break-system-packages!
RUN pip3 install --no-cache-dir --break-system-packages --upgrade pip && \
    pip3 install --no-cache-dir --break-system-packages uwsgi && \
    pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Frontend + config
COPY --from=quasar_build /frontend/dist/pwa ${APIAPP_FRONTEND}/
COPY ./VERSION /VERSION
COPY ./app/run_app_docker.sh /run_app_docker.sh
COPY ./nginx_default.conf /etc/nginx/conf.d/default.conf
COPY ./uwsgi.ini /uwsgi.ini
COPY ./healthcheck.sh /healthcheck.sh

# Jogosultságok
RUN chmod +x /run_app_docker.sh /healthcheck.sh && \
    mkdir -p ${APP_DIR} ${APIAPP_FRONTEND} /var/log/uwsgi && \
    chown -R ${APIAPP_USERFORJOBS}:${APIAPP_GROUPFORJOBS} \
        ${APP_DIR} ${APIAPP_FRONTEND} /var/log/uwsgi /VERSION /uwsgi.ini /run_app_docker.sh

# USER ${APIAPP_USERFORJOBS} - Commented out because JobExecutor requires root
# Running as root for now due to JobExecutor requirements

STOPSIGNAL SIGTERM
CMD ["/run_app_docker.sh"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /healthcheck.sh || exit 1
