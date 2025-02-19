defmodule PhoenixTailwindV4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixTailwindV4Web.Telemetry,
      PhoenixTailwindV4.Repo,
      {DNSCluster,
       query: Application.get_env(:phoenix_tailwind_v4, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixTailwindV4.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixTailwindV4.Finch},
      # Start a worker by calling: PhoenixTailwindV4.Worker.start_link(arg)
      # {PhoenixTailwindV4.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixTailwindV4Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixTailwindV4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixTailwindV4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
