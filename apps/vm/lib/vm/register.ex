defmodule VM.Register do

  @register_names [
    :reg_0, :reg_1, :reg_2,
    :reg_3, :reg_4, :reg_5,
    :reg_6, :reg_7
  ]

  def start_link(name) do
    Agent.start_link(fn -> 0 end, name: name)
  end

  def get(register) do
    Agent.get(register, fn(value) -> value end)
  end

  def get_all do
    Enum.reduce(@register_names, %{}, fn(name, a) ->
      value = get(name)
      Dict.put(a, name, value)
    end)
  end

  def set(register, value) do
    Agent.update(register, fn(_val) -> value end)
  end

  def set_all(registers) do
    Enum.each(registers, fn({name, value}) ->
      name = String.to_atom(name)
      set(name, value)
    end)
  end

end
