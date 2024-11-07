defmodule Service1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Service1.Service1Plug, options: [port: 80]},
      %{id: Service1.Limiter, start: {Service1.Limiter, :start_link, [:ok]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Service1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
