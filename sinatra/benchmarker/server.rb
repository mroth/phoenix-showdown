#!/usr/bin/env ruby
require 'sinatra'
configure { set :logging, false }

get '/:title' do
  @title = params[:title]
  @members = [
    {name: "Chris McCord"},
    {name: "Matt Sears"},
    {name: "David Stump"},
    {name: "Ricardo Thompson"}
  ]
  erb :index
end
