defmodule ElixTogether.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixTogetherWeb.Telemetry,
      ElixTogether.Repo,
      {DNSCluster, query: Application.get_env(:elix_together, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixTogether.PubSub},
      # Start a worker by calling: ElixTogether.Worker.start_link(arg)
      # {ElixTogether.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixTogetherWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixTogether.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixTogetherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
