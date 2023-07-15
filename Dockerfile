FROM registry.access.redhat.com/ubi8/nodejs-16 AS test-0

ARG API_HOSTNAME
ENV GENERATE_SOURCEMAP false
ENV WORKDIR_FRONTEND=/opt/app-root/src

# set working directory
WORKDIR ${WORKDIR_FRONTEND}

# Copy project to working directory
COPY . ${WORKDIR_FRONTEND}

USER 0
RUN chown -R 1001:1001 ${WORKDIR_FRONTEND}
USER 1001

# Install dependency loglevel=error will remove warnings
RUN npm install --loglevel=error || cat /opt/app-root/src/.npm/_logs/*-debug*.log


