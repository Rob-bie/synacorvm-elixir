defmodule Debugger.VMHook do

  @vm_node     :vm@localhost
  @debugserver VM.DebugServer

  def cycle_until_halt do
    GenServer.call({@debugserver, @vm_node}, :cycle_until_halt)
  end

  def get_registers do
    GenServer.call({@debugserver, @vm_node}, :registers_dump)
  end

  def get_stack do
    GenServer.call({@debugserver, @vm_node}, :stack_dump)
  end

  def get_vm_dump do
    GenServer.call({@debugserver, @vm_node}, :vm_dump)    
  end

  def restart_vm do
    GenServer.cast({@debugserver, @vm_node}, :restart_vm)
  end

  def load_save_state(name) do
    restart_vm
    dir = Debugger.Serializer.directory
    path = "#{dir}/#{name}.json"
    GenServer.call({@debugserver, @vm_node}, {:load_save_state, path})
  end

end
