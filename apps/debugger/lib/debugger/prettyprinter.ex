defmodule Debugger.PrettyPrinter do

  def pretty_print_registers(registers) do
    :io.fwrite("~17c~n", [?-])
    :io.fwrite("|~s|~s|~n", [center("reg", 7), center("value", 7)])
    :io.fwrite("~17c~n", [?-])
    Enum.each(registers, fn({reg, value}) ->
      :io.fwrite("|~s|~s|~n", [center(reg, 7), center(value, 7)])
      :io.fwrite("~17c~n", [?-])
    end)
  end

  def pretty_print_stack(stack) do
    :io.fwrite("~9c~n", [?-])
    :io.fwrite("|~s|~n", [center("stack", 7)])
    :io.fwrite("~9c~n", [?-])
    case stack do
      [] ->
        :io.fwrite("|~s|~n", [center("empty", 7)])
        :io.fwrite("~9c~n", [?-])
      _  ->
        Enum.each(stack, fn(value) ->
          :io.fwrite("|~s|~n", [center(value, 7)])
          :io.fwrite("~9c~n", [?-])
        end)
    end
  end

  defp center(text, n) do
    text = text |> to_char_list
    :string.centre(text, n)
  end

end
