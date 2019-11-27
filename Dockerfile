# Based on https://github.com/standardfile/ruby-server/blob/master/Dockerfile

FROM ruby:2-alpine

ENV PROJECT_REPO=https://github.com/standardfile/ruby-server
ENV PROJECT_COMMIT=master
ENV PROJECT_DIR=/data/src/

# Build and test dependencies.
RUN apk add --update --no-cache \
    git \
    netcat-openbsd

# Application's dependencies.
RUN apk add --update --no-cache \
    build-base \
    mariadb-connector-c \
    mariadb-dev \
    nodejs \
    tzdata \
    zlib-dev \
    yarn

RUN git clone $PROJECT_REPO $PROJECT_DIR && \
    cd $PROJECT_DIR && \
    git checkout $PROJECT_COMMIT

WORKDIR $PROJECT_DIR

RUN gem install bundler:2.0.2
RUN bundle install
RUN bundle exec rake assets:precompile
RUN rails db:migrate || true

# See https://github.com/brianmario/mysql2/issues/1023
RUN mkdir ./lib/mariadb && ln -s /usr/lib/mariadb/plugin ./lib/mariadb/plugin

EXPOSE 3000

ENTRYPOINT [ "./docker/entrypoint" ]
CMD [ "start" ]
