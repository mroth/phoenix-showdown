defmodule Benchmarker.Router do
  use Phoenix.Router
  alias Benchmarker.Controllers

  plug Plug.Static, at: "/static", from: :benchmarker
  get "/:title", Controllers.Pages, :index, as: :page
end
