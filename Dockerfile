FROM ruby:2.4

RUN gem install bundler --no-ri --no-rdoc

RUN mkdir /gem
WORKDIR /gem

ADD lib/roda/monads/version.rb /gem/lib/roda/monads/version.rb
ADD *.gemspec /gem/
ADD Gemfile /gem/Gemfile
RUN bundle install -j $(nproc) --path=/vendor/bundle
