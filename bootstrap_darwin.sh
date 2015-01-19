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
rbenv install --skip-existing 2.2.0
(cd rails/benchmarker   && bundle install)
(cd sinatra/benchmarker && bundle install)

# bootstrap express
brew install node
(cd express/benchmarker && npm install)

# TODO: bootstrap martini

# TODO: bootstrap phoenix

# TODO: bootstrap gin

# TODO: bootstrap play
