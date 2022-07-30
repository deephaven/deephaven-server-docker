# syntax=docker/dockerfile:1.4

ARG GENERIC_JAVA_BASE
FROM $GENERIC_JAVA_BASE
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link --from=server-scratch ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link groovy/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENV DEEPHAVEN_HOME=${DEEPHAVEN_HOME}
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]
