#!/bin/bash

mkdir -p $HOME/bin
export PATH=$HOME/bin:$PATH

# bootstrap rails/sinatra
sudo apt-get install -y ruby2.1-dev bundler
(cd rails/benchmarker   && bundle install)
(cd sinatra/benchmarker && bundle install)
(cd cuba/benchmarker && bundle install)

# bootstrap express
sudo apt-get install -y nodejs-dev
(cd express/benchmarker && npm install)

# bootstrap phoenix
(cd /tmp && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb)
sudo apt-get update
sudo apt-get install -y elixir
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
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
sudo apt-get install -y oracle-java8-installer
(cd play/benchmarker && ./activator clean stage)

# bootstrap undertow
(cd undertow/benchmarker && ./gradlew clean build)

# install forego/wrk to do the benchmarking
(cd $HOME/bin && wget https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego && chmod +x forego)
sudo apt-get install -y build-essential libssl-dev git
(cd /tmp && git clone https://github.com/wg/wrk.git && cd wrk && make && cp wrk $HOME/bin)
