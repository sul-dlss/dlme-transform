FROM ruby:2.5-alpine3.8

# Create and set the working directory as /opt
RUN mkdir -p /opt/traject/output
WORKDIR /opt/traject

ENV BUNDLER_VERSION 2.0.1

RUN apk add --no-cache \
    curl \
    zip \
    python \
    libxml2-dev \
    libxslt-dev \
    jq \
    && apk add --no-cache --virtual build-dependencies \
      build-base \
    && apk add --no-cache --virtual python-dependencies \
    py-pip \
    python-dev \
    && pip install awscli \
    && apk del python-dependencies \
    && gem install bundler

# This is here temporarily until we have a released version of traject_plus
RUN apk add --no-cache git

# Copy the Gemfile and Gemfile.lock, and run bundle install prior to copying all source files
# This is an optimization that will prevent the need to re-run bundle install when only source
# code is changed and not dependencies.
COPY Gemfile /opt/traject/
COPY Gemfile.lock /opt/traject/

RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --without test && \
    apk del build-dependencies

COPY . /opt/traject/

ENV SKIP_FETCH_CONFIG false
ENV SKIP_FETCH_DATA false
ENV S3_BASE_URL https://s3-us-west-2.amazonaws.com
ENV AWS_DEFAULT_REGION us-west-2

# Metadata params
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DLME Traject transformer" \
      org.label-schema.description="Transforms various source metadata into the DLME intermediate representation schema" \
      org.label-schema.schema-version="1.0"

ENTRYPOINT ["/opt/traject/invoke.sh"]
