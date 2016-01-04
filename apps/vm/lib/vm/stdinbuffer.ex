defmodule VM.StdinBuffer do
  use GenServer

  @stdinbuffer __MODULE__

  def start_link do
    GenServer.start_link(@stdinbuffer, [], name: @stdinbuffer)
  end

  def read_stdin do
    GenServer.call(@stdinbuffer, :read_stdin, :infinity)
  end

  def has_next_char? do
    GenServer.call(@stdinbuffer, :has_next_char?)
  end

  def next_char do
    GenServer.call(@stdinbuffer, :next_char)
  end

  def insert(input) do
    GenServer.cast(@stdinbuffer, {:insert, input})
  end

  def handle_call(:read_stdin, _from, state) do
    {:reply, IO.gets(""), state}
  end

  def handle_call(:has_next_char?, _from, state) do
    {:reply, !Enum.empty?(state), state}
  end

  def handle_call(:next_char, _from, [char|rest]) do
    {:reply, char, rest}
  end

  def handle_cast({:insert, input}, state) do
    input = input |> to_char_list |> Enum.reverse
    buffer = Enum.reduce(input, state, fn(c, a) -> [c|a] end)
    {:noreply, buffer}
  end

end
