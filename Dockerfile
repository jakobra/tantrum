FROM ruby:2.5.0-slim-stretch

RUN apt-get update && apt-get install -y \
  build-essential \
  libgmp-dev


RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE 3300

CMD ["ruby", "tantrum.rb"]
