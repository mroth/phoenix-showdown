class PagesController < ApplicationController

  def index
    @title = params[:title]
    @members = [
      {name: "Chris McCord"},
      {name: "Matt Sears"},
      {name: "David Stump"},
      {name: "Ricardo Thompson"}
    ]
    render "index"
  end
end
