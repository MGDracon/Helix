defmodule HELFRouter.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(HELF.Router, [])
    ]

    opts = [strategy: :one_for_one, name: HELFRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end