defmodule VM.DebugServer do
  use GenServer

  @debugserver __MODULE__

  def start_link do
    GenServer.start_link(@debugserver, [], name: @debugserver)
  end

  def handle_call(:cycle_until_halt, _from, state) do
    VM.Runtime.cycle_until_halt
    {:reply, :ok, state}
  end

  def handle_call(:registers_dump, _from, state) do
    {:reply, VM.Register.get_all, state}
  end

  def handle_call(:stack_dump, _from, state) do
    {:reply, VM.Stack.get_stack, state}
  end

  def handle_call(:vm_dump, _from, state) do
    vm_dump = %{
      memory: VM.Memory.get_memory,
      registers: VM.Register.get_all,
      stack: VM.Stack.get_stack,
      ip: VM.Memory.instruction_pointer
    }
    {:reply, vm_dump, state}
  end

  def handle_call({:load_save_state, path}, _from, state) do
    vm_data = File.read!(path) |> Poison.decode!
    memory = vm_data["memory"] |> Enum.map(fn {a, v} -> {String.to_integer(a), v} end)
    registers = vm_data["registers"]
    stack = vm_data["stack"]
    pointer = vm_data["ip"]

    VM.Memory.load_instructions(memory)
    VM.Register.set_all(registers)
    VM.Stack.set_stack(stack)
    VM.Memory.set_pointer(pointer)

    {:reply, :save_state_loaded, state}
  end

  def handle_cast(:restart_vm, state) do
    Agent.stop(:reg_0)
    clear_terminal
    {:noreply, state}
  end

  defp clear_terminal do
    :timer.sleep(100)
    IO.puts("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
  end

end
