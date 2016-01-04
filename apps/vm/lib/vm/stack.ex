defmodule VM.Stack do

  @stack __MODULE__

  def start_link() do
    Agent.start_link(fn -> [] end, name: @stack)
  end

  def get_stack do
    Agent.get(@stack, fn(stack) -> stack end)
  end

  def set_stack(stack) do
    Agent.update(@stack, fn(_stack) -> stack end)
  end

  def push(e) do
    Agent.update(@stack, fn(stack) -> [e|stack] end)
  end

  def pop do
    Agent.get_and_update(@stack, fn [h|t] -> {h, t} end)
  end

end
