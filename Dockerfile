FROM java:8

RUN curl -o /usr/local/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest" && \
	chmod +x /usr/local/bin/digdag && \
	curl --create-dirs -o /usr/local/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar" && \
	chmod +x /usr/local/bin/embulk

# Use --build-arg with docker build command to override these values.
# For example,
# docker build . --build-arg DIGDAG_VERSION=latest \
#                --build-arg EMBULK_VERSION=latest
ARG DIGDAG_DOWNLOAD_SERVER=https://dl.digdag.io
ARG EMBULK_DOWNLOAD_SERVER=https://dl.bintray.com/embulk/maven
ARG DIGDAG_VERSION=0.9.20
ARG EMBULK_VERSION=0.8.36

COPY digdag.properties /etc/digdag.properties
COPY run-digdag.sh /home/digdag/run-digdag.sh
COPY GemFile /home/digdag/GemFile

RUN curl -o /usr/bin/digdag --create-dirs -L "$DIGDAG_DOWNLOAD_SERVER/digdag-$DIGDAG_VERSION" && \
    chmod +x /usr/bin/digdag

RUN curl  -o /usr/bin/embulk --create-dirs -L "$EMBULK_DOWNLOAD_SERVER/embulk-$EMBULK_VERSION.jar" && \
    chmod +x /usr/bin/embulk

RUN chmod +x /home/digdag/run-digdag.sh

RUN useradd -d /home/digdag -s /sbin/nologin -U digdag && \
    chown digdag /home/digdag

WORKDIR /home/digdag

USER digdag

# Install as the digdag user
RUN embulk gem install -g /home/digdag/GemFile

ENV CONFIG_FILE=/etc/digdag.properties
ENV ADDITIONAL_DIGDAG_CLI_PARAMETERS=

EXPOSE 65432 65433

CMD ["/bin/bash", "-c", "./run-digdag.sh $ADDITIONAL_DIGDAG_CLI_PARAMETERS"]
