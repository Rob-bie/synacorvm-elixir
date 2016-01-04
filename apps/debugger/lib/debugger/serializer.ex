defmodule Debugger.Serializer do

  @save_state_dir "./save_states"

  def save_state(name) do
    file_name = "#{name}.json"
    json = Debugger.VMHook.get_vm_dump |> Poison.encode!(pretty: true)

    File.write!("#{@save_state_dir}/#{file_name}", json)
  end

  def directory do
    @save_state_dir
  end

end
