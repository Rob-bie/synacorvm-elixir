defmodule VM do
  use Application

  @memory          VM.Memory
  @register        VM.Register
  @stack           VM.Stack
  @stdinbuffer     VM.StdinBuffer
  @debugsupervisor VM.DebugSupervisor

  def start, do: start(:no, :args)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    start_local_node
    start_debug_server

    children = [
      worker(@memory, []),
      worker(@stack, []),
      worker(@register, [:reg_0], id: 0),
      worker(@register, [:reg_1], id: 1),
      worker(@register, [:reg_2], id: 2),
      worker(@register, [:reg_3], id: 3),
      worker(@register, [:reg_4], id: 4),
      worker(@register, [:reg_5], id: 5),
      worker(@register, [:reg_6], id: 6),
      worker(@register, [:reg_7], id: 7),
      worker(@stdinbuffer, []),
    ]

    opts = [strategy: :one_for_all, name: VM.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_debug_server do
    VM.DebugSupervisor.start_link
  end

  defp start_local_node do
    Node.start(:vm@localhost, :shortnames)
  end

end
