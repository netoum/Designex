# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phoenix_tailwind_v4,
  ecto_repos: [PhoenixTailwindV4.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :phoenix_tailwind_v4, PhoenixTailwindV4Web.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PhoenixTailwindV4Web.ErrorHTML, json: PhoenixTailwindV4Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixTailwindV4.PubSub,
  live_view: [signing_salt: "j2qtNHdU"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :phoenix_tailwind_v4, PhoenixTailwindV4.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  phoenix_tailwind_v4: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.6",
  phoenix_tailwind_v4: [
    args: ~w(
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :designex,
  version: "1.0.2",
  commit: "1da4b31",
  cd: Path.expand("../assets", __DIR__),
  dir: "design",
  demo: [
    setup_args: ~w(
    --template=tailwind/v4/tokens-studio/single
  ),
    build_args: ~w(
    --script=build.mjs
    --tokens=tokens
  )
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
