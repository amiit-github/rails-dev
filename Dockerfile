# https://hub.docker.com/r/amitshinde/rails-dev/
FROM ubuntu:15.10

#set environment variables
ENV RAILS_ENV development
ENV RUBY_VER 2.1.5
ENV GIT_VER 2.5.0

#update packages
RUN apt-get update -qq
RUN apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
RUN apt-get install -y libxml2-dev libxslt1-dev nodejs redis-server

# compile git with openssl instead of gnutls

# Clear out all previous attempts
RUN rm -rf "/tmp/source-git/"
# Get the dependencies for git, then get openssl
RUN apt-get install -y fakeroot dpkg-dev -y
RUN apt-get build-dep git -y
RUN mkdir -p "/tmp/source-git/"
WORKDIR /tmp/source-git/
RUN apt-get source git
# We need to actually go into the git source directory
# find -type f -name "*.dsc" -exec dpkg-source -x \{\} \;

# This is where we actually change the library from one type to the other.
RUN cd * && sed -i -- 's/libcurl4-gnutls-dev/libcurl4-openssl-dev/' ./debian/control
# Compile time, itself, is long. Skips the tests. Do so at your own peril.
RUN cd * && sed -i -- '/TEST\s*=\s*test/d' ./debian/rules
# Build it.
RUN apt-get install -y libcurl4-openssl-dev
RUN cd * && dpkg-buildpackage -rfakeroot -b
# Install
RUN find .. -type f -name "git_*ubuntu*.deb" -exec dpkg -i \{\} \;

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
WORKDIR /home
