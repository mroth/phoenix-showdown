defmodule Benchmarker.Controllers.Pages do
  use Phoenix.Controller

  def index(conn, %{"title" => title}) do
    render conn, "index", title: title, members: [
      %{name: "Chris McCord"},
      %{name: "Matt Sears"},
      %{name: "David Stump"},
      %{name: "Ricardo Thompson"}
    ]
  end
end
