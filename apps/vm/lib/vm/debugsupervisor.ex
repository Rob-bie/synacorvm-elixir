defmodule VM.DebugSupervisor do
  use Supervisor

  @debugsupervisor __MODULE__
  @debugserver     VM.DebugServer

  def start_link do
    Supervisor.start_link(@debugsupervisor, [])
  end

  def init([]) do
    children = [
      worker(@debugserver, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
