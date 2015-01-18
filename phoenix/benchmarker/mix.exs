defmodule Benchmarker.Mixfile do
  use Mix.Project

  def project do
    [app: :benchmarker,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Benchmarker, []},
     applications: [:phoenix, :cowboy, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, github: "phoenixframework/phoenix", ref: "9d13da084bc09c94e7440be94be5fba8d33ac5ca"},
     {:cowboy, "~> 1.0"}]
  end
end
