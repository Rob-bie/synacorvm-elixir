defmodule VM.Memory do

  @memory_container MemoryContainer
  @memory           __MODULE__

  def start_link do
    Agent.start_link(fn ->
      {:ets.new(@memory, [:set, :public, :named_table]),
       [pointer: 0, mem_size: 0]}
    end, name: @memory_container)
  end

  def load_bin_instructions do
    instructions = VM.BinReader.parse_bin
    size = length(instructions)
    start_address = instruction_pointer
    memory_size = memory_size

    Enum.reduce(instructions, start_address, fn(instruction, address) ->
      load_instruction(instruction, address)
      address + 1
    end)

    inc_memory_size(size)
  end

  def load_instruction(instruction, address) do
    :ets.insert(@memory, {address, instruction})
  end

  def load_instructions(instructions) do
    Enum.each(instructions, fn({address, instruction}) ->
      load_instruction(instruction, address)
    end)
  end

  def instruction_at(address) do
    instruction = :ets.lookup(@memory, address)
    extract_instruction(instruction)
  end

  def instruction_arguments(0), do: []

  def instruction_arguments(arity) do
    current_address = instruction_pointer
    drop_opcode = current_address + 1
    instruction_end = current_address + arity
    address_range = drop_opcode..instruction_end

    address_range |> Enum.map(&instruction_at/1)
  end

  def get_memory do
    :ets.tab2list(@memory)
    |> Enum.map(fn {k, v} -> {to_string(k), v} end)
    |> Enum.into(%{})
  end

  def shift_pointer(shift) do
    Agent.update(@memory_container, fn
      {memory, [pointer: n, mem_size: s]} ->
        {memory, [pointer: n + shift, mem_size: s]}
    end)
  end

  def set_pointer(address) do
    Agent.update(@memory_container, fn
      {memory, [pointer: _n, mem_size: s]} ->
        {memory, [pointer: address, mem_size: s]}
    end)
  end

  def inc_memory_size(size) do
    Agent.update(@memory_container, fn
      {memory, [pointer: n, mem_size: s]} ->
        {memory, [pointer: n, mem_size: s + size]}
    end)
  end

  def instruction_pointer do
    Agent.get(@memory_container, fn
      {_memory, [pointer: n, mem_size: _s]} -> n
    end)
  end

  def memory_size do
    Agent.get(@memory_container, fn
      {_memory, [pointer: _n, mem_size: s]} -> s
    end)
  end

  defp extract_instruction([{_address, instruction}]) do
    instruction
  end

end
