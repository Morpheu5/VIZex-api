# ibmcom/swift-ubuntu-runtime:latest
FROM swift:latest
LABEL Description="Docker image for VizEx API."

USER root

# Expose default port for Kitura
EXPOSE 8080

# Sets a reasonable default for the data filename
ENV VIZEX_API_DATA_FILENAME_1H="/data/ohlc_1h.csv"
ENV VIZEX_API_DATA_FILENAME_4H="/data/ohlc_4h.csv"
ENV VIZEX_API_DATA_FILENAME_1D="/data/ohlc_1d.csv"

# Sets the environment to "production"
ENV VIZEX_API_ENVIRONMENT="production"

# Installs and builds the application
RUN mkdir /root/vizex-api
COPY Package.swift /root/vizex-api/
COPY Sources/ /root/vizex-api/Sources/
WORKDIR /root/vizex-api
RUN swift build -c release
COPY data/ohlc_1h.csv /data/ohlc_1h.csv
COPY data/ohlc_4h.csv /data/ohlc_4h.csv
COPY data/ohlc_1d.csv /data/ohlc_1d.csv

CMD [ "sh", "-c", "/root/vizex-api/.build/release/api" ]
