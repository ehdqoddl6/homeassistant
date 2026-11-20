ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache nodejs npm python3 py3-pip \
    && npm install --global mcp-toss@0.1.0 \
    && pip3 install --no-cache-dir --break-system-packages mcp-proxy

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
