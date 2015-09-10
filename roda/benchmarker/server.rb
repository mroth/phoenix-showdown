#!/usr/bin/env ruby
require 'roda'

class Server < Roda
  plugin :render
  route do |r|
    r.get :title do |title|
      @title = title
      @members = [
        {name: "Chris McCord"},
        {name: "Matt Sears"},
        {name: "David Stump"},
        {name: "Ricardo Thompson"}
      ]
      view('index')
    end
  end
end
