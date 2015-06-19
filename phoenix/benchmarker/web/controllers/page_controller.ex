defmodule Benchmarker.PageController do
  use Benchmarker.Web, :controller

  plug :action

  def index(conn, %{"title" => title}) do
    render conn, "index.html", title: title, members: [
      %{name: "Chris McCord"},
      %{name: "Matt Sears"},
      %{name: "David Stump"},
      %{name: "Ricardo Thompson"}
    ]
  end
end
