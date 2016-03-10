# https://hub.docker.com/r/amitshinde/rails-local/
FROM ubuntu:15.10

#set environment variables
ENV RAILS_ENV development
ENV RUBY_VER 2.1.5

#update packages
RUN apt-get update -qq
RUN apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
RUN apt-get install -y libxml2-dev libxslt1-dev nodejs redis-server

#install ruby with rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

RUN git clone https://github.com/rbenv/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

RUN $HOME/.rbenv/bin/rbenv install ${RUBY_VER}
RUN $HOME/.rbenv/bin/rbenv global ${RUBY_VER}

#update PATH
ENV PATH /root/.rbenv/shims:$PATH
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN gem install bundler
