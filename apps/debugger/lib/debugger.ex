defmodule Debugger do
  use Application

  alias Debugger.VMHook
  alias Debugger.PrettyPrinter
  alias Debugger.Serializer

  def start, do: start(:no, :args)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    start_local_node

    children = []

    opts = [strategy: :one_for_one, name: Debugger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def restart_vm do
    VMHook.restart_vm
  end

  def save_state(name) do
    Serializer.save_state(name)
  end

  def load_save_state(name) do
    VMHook.load_save_state(name)
  end

  def show_registers do
    VMHook.get_registers
    |> PrettyPrinter.pretty_print_registers
  end

  def show_stack do
    VMHook.get_stack
    |> PrettyPrinter.pretty_print_stack
  end

  defp start_local_node do
    Node.start(:debugger@localhost, :shortnames)
  end

end
