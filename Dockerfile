FROM ubuntu:18.04

ENV APP_ROOT=/mixcrep

#mixcr version
ENV version 3.0.13

RUN apt-get update -y && apt-get install -y \
    git \
    build-essential \
    openjdk-8-jre \
    wget \
    unzip \
    python3 \
    vim \
    python3-pip 

RUN pip3 install pandas



# set inital WORKDIR
WORKDIR /mixcrep/

# download the source
RUN wget https://github.com/milaboratory/mixcr/releases/download/v${version}/mixcr-${version}.zip

# unzip the source
RUN unzip mixcr-${version}.zip


# add mixcr executable to path
ENV PATH="/mixcr/mixcr-${version}/:${PATH}"
ENV PATH="/mixcrep/mixcr-${version}/:${PATH}"
#repseq version
ARG version2="1.3.4"

RUN wget -q https://github.com/repseqio/repseqio/releases/download/v${version2}/repseqio-${version2}.zip

RUN unzip repseqio-${version2}.zip



ENV APP_ROOT=/mixcrep

ENV PATH="${APP_ROOT}:${PATH}"

COPY . /mixcrep
WORKDIR /mixcrep


