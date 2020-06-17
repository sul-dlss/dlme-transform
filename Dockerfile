FROM ruby:2.7.1-alpine3.11

# Note: The base image is currently pinned to alpine3.11 in order to stick to a supported
# version of python 2 (2.7.x). Currently alpine3.12 and greater requires specifying python3
# and additionally uses python 3.8.3 which introduces a dependency incompatiblity with the
# required awscli. This should be investigated separately.

# Create and set the working directory as /opt
RUN mkdir -p /opt/traject/output
WORKDIR /opt/traject

ENV BUNDLER_VERSION 2.0.2

RUN apk add --no-cache \
    curl \
    zip \
    python \
    libxml2-dev \
    libxslt-dev \
    jq \
    util-linux \
    && apk add --no-cache --virtual build-dependencies \
      build-base \
    && apk add --no-cache --virtual python-dependencies \
    py-pip \
    python-dev \
    && pip install awscli \
    && apk del python-dependencies \
    && gem install bundler

# Copy the Gemfile and Gemfile.lock, and run bundle install prior to copying all source files
# This is an optimization that will prevent the need to re-run bundle install when only source
# code is changed and not dependencies.
COPY Gemfile /opt/traject/
COPY Gemfile.lock /opt/traject/

RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --without test && \
    apk del build-dependencies

COPY . /opt/traject/

ENV SKIP_FETCH_DATA false
ENV S3_BASE_URL https://s3-us-west-2.amazonaws.com
ENV AWS_DEFAULT_REGION us-west-2

# Metadata params
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

ENV VERSION=$VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DLME Traject transformer" \
      org.label-schema.description="Transforms various source metadata into the DLME intermediate representation schema" \
      org.label-schema.schema-version="1.0"

ENTRYPOINT ["/opt/traject/invoke.sh"]
