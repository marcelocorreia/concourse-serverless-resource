FROM marcelocorreia/serverless
MAINTAINER Marcelo Correia <marcelo@correia.io>

ADD assets/check.sh /opt/resource/check
ADD assets/out.sh /opt/resource/out
ADD assets/in.sh /opt/resource/in

RUN chmod +x /opt/resource/*
