FROM marcelocorreia/serverless
MAINTAINER Marcelo Correia <marcelo@correia.io>

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*
