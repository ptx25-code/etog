import Config

# Configure your database
config :elix_together, ElixTogether.Repo,
  url:
    System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost:5432/elix_together_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :elix_together, ElixTogetherWeb.Endpoint,
  # Bind to 0.0.0.0 to expose the server to the docker host machine.
  # This makes make the service accessible from any network interface.
  # Change to `ip: {127, 0, 0, 1}` to allow access only from the server machine.
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4001")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "H+XrG6UL9CjcfLfc68p6Q5A5SKhfZHzL/5Ui57khO+1akReszNgUHrOLJ2pYO3Fq",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:elix_together, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:elix_together, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :elix_together, ElixTogetherWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/elix_together_web/(?:controllers|live|components|router)/?.*\.(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :elix_together, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include debug annotations and locations in rendered markup.
  # Changing this configuration will require mix clean and a full recompile.
  debug_heex_annotations: true,
  debug_attributes: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
