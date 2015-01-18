use Mix.Config

# ## SSL Support
#
# To get SSL working, you will need to set:
#
#     https: [port: 443,
#             keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#             certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables point to a file on
# disk for the key and cert.

config :benchmarker, Benchmarker.Endpoint,
  url: [host: "example.com"],
  http: [port: System.get_env("PORT") || 4000],
  secret_key_base: "73VPBpeLgZrt/w5Xu7J+8gNUZekDfyc/zrK6/wLr/+pssmAB7pndkPy8wg0ISYP1"

# Do not pring debug messages in production
config :logger, level: :error

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :benchmarker, Benchmarker.Endpoint, server: true
#
