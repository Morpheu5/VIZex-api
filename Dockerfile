# ibmcom/swift-ubuntu-runtime:latest
FROM swift:latest
LABEL Description="Docker image for VizEx API."

USER root

# Expose default port for Kitura
EXPOSE 8080

# Sets a reasonable default for the data filename
ENV VIZEX_API_DATA_FILENAME="/data/ohlc.csv"

# Installs and builds the application
RUN mkdir /root/vizex-api
COPY Package.swift Sources /root/vizex-api/
WORKDIR /root/vizex-api
RUN swift build -c release
COPY data/ohlc.csv /data/ohlc.csv

CMD [ "sh", "-c", "/root/vizex-api/.build/release/api" ]