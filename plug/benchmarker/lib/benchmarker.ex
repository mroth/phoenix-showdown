defmodule Benchmarker do
  use Plug.Router

  plug :match
  plug :fetch_params
  plug :dispatch

  get "/:title" do
    render conn, :index, title: title, members: [
      %{name: "Chris McCord"},
      %{name: "Matt Sears"},
      %{name: "David Stump"},
      %{name: "Ricardo Thompson"}
    ]
  end

  defp render(conn, template, assigns) do
    inner = apply(__MODULE__, template, [[conn: conn] ++ assigns])
    outer = layout([conn: conn, inner: inner] ++ assigns])
    send_resp(conn, 200, outer)
  end

  # Embed the views
  require EEx
  EEx.function_from_file :def, :index,  "lib/views/index.eex", [:assigns]
  EEx.function_from_file :def, :layout, "lib/views/layout.eex", [:assigns]
  EEx.function_from_file :def, :bio,    "lib/views/_bio.eex", [:assigns]
end
