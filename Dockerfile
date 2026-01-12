FROM ruby:3.4-alpine

# Create and set the working directory as /opt
RUN mkdir -p /opt/traject/output

WORKDIR /opt/traject

ENV BUNDLER_VERSION=2.6.5

RUN apk add --no-cache \
    curl \
    zip \
    python3 \
    libxml2-dev \
    libxslt-dev \
    yaml-dev \
    linux-headers \
    jq \
    util-linux \
    && apk add --no-cache --virtual build-dependencies \
      build-base \
    && apk add --no-cache --virtual python-dependencies \
    py-pip \
    python3-dev \
    && apk del python-dependencies \
    && gem install bundler

# Copy the Gemfile and Gemfile.lock, and run bundle install prior to copying all source files
# This is an optimization that will prevent the need to re-run bundle install when only source
# code is changed and not dependencies.
COPY Gemfile /opt/traject/
COPY Gemfile.lock /opt/traject/

RUN bundle config set build.nokogiri --use-system-libraries && \
    bundle config set without test && \
    apk del build-dependencies

COPY . /opt/traject/

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
