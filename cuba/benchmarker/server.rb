require 'cuba'
require 'cuba/render'
require 'erb'

Cuba.plugin Cuba::Render

Cuba.define do
  on ':title' do |title|
    @title = title
    @members = [
      { name: "Chris McCord" },
      { name: "Matt Sears" },
      { name: "David Stump" },
      { name: "Ricardo Thompson" }
    ]
    res.write view('index')
  end
end
