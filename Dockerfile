FROM ruby:2.5-alpine3.8

# Create and set the working directory as /opt
RUN mkdir -p /opt/traject/output
WORKDIR /opt/traject

RUN apk add --update build-base curl zip python3-dev
RUN pip3 install --upgrade pip
RUN pip3 install awscli

# Copy the Gemfile and Gemfile.lock, and run bundle install prior to copying all source files
# This is an optimization that will prevent the need to re-run bundle install when only source
# code is changed and not dependencies.
COPY Gemfile /opt/traject/
COPY Gemfile.lock /opt/traject/

ENV BUNDLER_VERSION 2.0.1
RUN gem install bundler
RUN bundle install --without test

COPY . /opt/traject/

ENV SKIP_FETCH_CONFIG false
ENV SKIP_FETCH_DATA false

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
