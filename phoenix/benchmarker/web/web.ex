defmodule Benchmarker.Web do
  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import common functionality
      import Benchmarker.Router.Helpers

      import Phoenix.Controller, only: [get_flash: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Import URL helpers from the router
      import Benchmarker.Router.Helpers
    end
  end

  def model do
    quote do
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end