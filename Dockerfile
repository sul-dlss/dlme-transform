FROM ruby:2.5-alpine3.8

# Create and set the working directory as /opt
RUN mkdir -p /opt/traject/output
WORKDIR /opt/traject

RUN apk add --update build-base curl zip

# Copy the Gemfile and Gemfile.lock, and run bundle install prior to copying all source files
# This is an optimization that will prevent the need to re-run bundle install when only source
# code is changed and not dependencies.
COPY Gemfile /opt/traject/
COPY Gemfile.lock /opt/traject/

ENV BUNDLER_VERSION 2.0.1
RUN gem install bundler
RUN bundle install

COPY invoke.sh /opt/traject/
RUN chmod +x /opt/traject/invoke.sh

ENV USE_GITHUB false

ENTRYPOINT ["/opt/traject/invoke.sh"]
