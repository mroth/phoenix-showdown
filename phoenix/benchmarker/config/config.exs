# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :benchmarker, Benchmarker.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "73VPBpeLgZrt/w5Xu7J+8gNUZekDfyc/zrK6/wLr/+pssmAB7pndkPy8wg0ISYP1",
  debug_errors: false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
