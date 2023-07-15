###################################################################
## Base image
###################################################################
FROM registry.access.redhat.com/ubi8/nginx-118 AS base

###################################################################
## Admin Frontend building
###################################################################
FROM registry.access.redhat.com/ubi8/nodejs-16 AS prepare_frontend

ARG API_HOSTNAME
ENV GENERATE_SOURCEMAP false
ENV WORKDIR_FRONTEND=/opt/app-root/src
ENV NPM_INSTALL_FOLDER="/.npm"

# set working directory
WORKDIR ${WORKDIR_FRONTEND}

# Copy project to working directory
COPY . ${WORKDIR_FRONTEND}

USER 0
RUN chown -R 1001:1001 ${WORKDIR_FRONTEND} && \
    mkdir ${NPM_INSTALL_FOLDER} && \
    chown -R 1001:0 ${NPM_INSTALL_FOLDER} 
USER 1001

# Install dependency loglevel=error will remove warnings
# RUN npm install --loglevel=error || cat /opt/app-root/src/.npm/_logs/*-debug*.log
RUN npm -v && \
    node -v && \
    NODE_DEBUG_NATIVE=tls npm install --loglevel=error && \
    cat ${NPM_INSTALL_FOLDER}/_logs/*-debug*.log

# Run tests
RUN CI=true REACT_APP_API_SCHEMA="http://" npm run test

# Build project
ENV REACT_APP_API_SCHEMA="https://"
ENV REACT_APP_API_HOSTNAME=${API_HOSTNAME}
ENV PARCEL_WORKERS 1
RUN npm run build

###################################################################
## Install image
###################################################################

# now start with the real image
FROM base AS install_app

ARG API_HOSTNAME
ENV GENERATE_SOURCEMAP false
ENV REACT_APP_API_HOSTNAME=${API_HOSTNAME}
ENV WORKDIR_FRONTEND=/opt/app-root/src

COPY --from=prepare_frontend ${WORKDIR_FRONTEND}/build /opt/app-root/src

USER 1001
CMD nginx -g "daemon off;"
