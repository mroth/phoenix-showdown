#!/bin/bash

# Script to bootstrap all dependencies.
# Currently only works on a Darwin (MacOSX system), and utilizes homebrew.
# TODO / HELP WANTED: update this to work on other *nixes (and change filename).

# Install Homebrew if not there already.
if [ ! -f  /usr/local/bin/brew ]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# bootstrap rails/sinatra
brew install rbenv
rbenv install --skip-existing 2.3.1
rbenv shell 2.3.1 && gem install bundler
rbenv shell --unset
(cd rails/benchmarker   && bundle install)
(cd sinatra/benchmarker && bundle install)
(cd cuba/benchmarker    && bundle install)

# bootstrap express
brew install node
(cd express/benchmarker && npm install)

# bootstrap phoenix
brew install elixir
(cd phoenix/benchmarker && mix do deps.get, compile)
(cd phoenix/benchmarker && MIX_ENV=prod mix compile.protocols)

# bootstrap plug
(cd plug/benchmarker && mix do deps.get, compile)
(cd plug/benchmarker && MIX_ENV=prod mix compile.protocols)

# bootstrap martini / gin
# (benchmarks are identical between go run and compiled version, so we don't
# bother to pre-compile binaries)
go get github.com/go-martini/martini
go get github.com/martini-contrib/render
go get github.com/gin-gonic/gin

# bootstrap play
brew install caskroom/cask/brew-cask
brew cask install java
(cd play/benchmarker && ./activator clean stage)

# bootstrap undertow
(cd undertow/benchmarker && ./gradlew clean build)

# install forego/wrk to do the benchmarking
brew install forego
brew install wrk
