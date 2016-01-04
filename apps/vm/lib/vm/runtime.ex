defmodule VM.Runtime do
  use Bitwise

  @register_table %{
    32768 => :reg_0,
    32769 => :reg_1,
    32770 => :reg_2,
    32771 => :reg_3,
    32772 => :reg_4,
    32773 => :reg_5,
    32774 => :reg_6,
    32775 => :reg_7,
  }

  @jump_opcodes [6, 7, 8, 17, 18]

  def opcode_table do
    %{
      0  => [arity: 0, fun: &halt/0],   # halt
      1  => [arity: 2, fun: &set/2],    # set
      2  => [arity: 1, fun: &push/1],   # push
      3  => [arity: 1, fun: &pop/1],    # pop
      4  => [arity: 3, fun: &eq/3],     # eq
      5  => [arity: 3, fun: &gt/3],     # gt
      6  => [arity: 1, fun: &jmp/2],    # jump
      7  => [arity: 2, fun: &jt/3],     # jt
      8  => [arity: 2, fun: &jf/3],     # jf
      9  => [arity: 3, fun: &add/3],    # add
      10 => [arity: 3, fun: &mult/3],   # mult
      11 => [arity: 3, fun: &mod/3],    # mod
      12 => [arity: 3, fun: &and_op/3], # and
      13 => [arity: 3, fun: &or_op/3],  # or
      14 => [arity: 2, fun: &not_op/2], # not
      15 => [arity: 2, fun: &rmem/2],   # rmem
      16 => [arity: 2, fun: &wmem/2],   # wmem
      17 => [arity: 1, fun: &call/2],   # call
      18 => [arity: 0, fun: &ret/1],    # ret
      19 => [arity: 1, fun: &out/1],    # out
      20 => [arity: 1, fun: &in_op/1],  # in
      21 => [arity: 0, fun: &noop/0],   # noop
    }
  end

  def capture_next_opcode do
    instruction_pointer = VM.Memory.instruction_pointer
    VM.Memory.instruction_at(instruction_pointer)
  end

  def cycle do
    opcode = capture_next_opcode
    [arity: arity, fun: fun] = opcode_table[opcode]
    arguments = VM.Memory.instruction_arguments(arity)
    case opcode do
      opcode when opcode in @jump_opcodes ->
        apply(fun, [arity|arguments])
      _non_jump_opcode ->
        ret = apply(fun, arguments)
        shift_pointer(arity)
        ret
    end
  end

  def cycle_until_halt do
    cycle_res = cycle
    case cycle_res do
      :halt -> :halt
      _     -> cycle_until_halt
    end
  end

  defp halt do
    :halt
  end

  defp set(a, b) do
    register_name = @register_table[a]
    b = operand_value(b)
    VM.Register.set(register_name, b)
  end

  defp push(a) do
    a = operand_value(a)
    VM.Stack.push(a)
  end

  defp pop(a) do
    a = @register_table[a]
    top_of_stack = VM.Stack.pop
    VM.Register.set(a, top_of_stack)
  end

  defp eq(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    register_name = @register_table[a]
    case b == c do
      true  -> VM.Register.set(register_name, 1)
      false -> VM.Register.set(register_name, 0)
    end
  end

  defp gt(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    register_name = @register_table[a]
    case b > c do
      true  -> VM.Register.set(register_name, 1)
      false -> VM.Register.set(register_name, 0)
    end
  end

  defp jmp(_arity, a) do
    VM.Memory.set_pointer(a)
  end

  defp jt(arity, a, b) do
    a = operand_value(a)
    cond do
      a != 0 -> VM.Memory.set_pointer(b)
      true   -> shift_pointer(arity)
    end
  end

  defp jf(arity, a, b) do
    a = operand_value(a)
    cond do
      a == 0 -> VM.Memory.set_pointer(b)
      true   -> shift_pointer(arity)
    end
  end

  defp add(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    sum = rem(b + c, 0x8000)
    register_name = @register_table[a]
    VM.Register.set(register_name, sum)
  end

  defp mult(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    product = rem(b * c, 0x8000)
    register_name = @register_table[a]
    VM.Register.set(register_name, product)
  end

  defp mod(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    remainder = rem(b, c)
    register_name = @register_table[a]
    VM.Register.set(register_name, remainder)
  end

  defp and_op(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    and_value = b &&& c
    register_name = @register_table[a]
    VM.Register.set(register_name, and_value)
  end

  defp or_op(a, b, c) do
    b = operand_value(b)
    c = operand_value(c)
    or_value = b ||| c
    register_name = @register_table[a]
    VM.Register.set(register_name, or_value)
  end

  defp not_op(a, b) do
    b = operand_value(b)
    register_name = @register_table[a]
    not_value = b ^^^ 0x7FFF
    VM.Register.set(register_name, not_value)
  end

  defp rmem(a, b) do
    mem_value = b |> operand_value |> VM.Memory.instruction_at
    register_name = @register_table[a]
    VM.Register.set(register_name, mem_value)
  end

  defp wmem(a, b) do
    b = b |> operand_value
    a = a |> operand_value
    VM.Memory.load_instruction(b, a)
  end

  defp call(arity, a) do
    next_instruction_address = (VM.Memory.instruction_pointer + arity) + 1
    a = operand_value(a)
    VM.Stack.push(next_instruction_address)
    VM.Memory.set_pointer(a)
  end

  defp ret(_arity) do
    instruction_address = VM.Stack.pop
    VM.Memory.set_pointer(instruction_address)
  end

  defp out(a) do
    a = operand_value(a)
    IO.write([a])
  end

  defp in_op(a) do
    register_name = @register_table[a]
    case VM.StdinBuffer.has_next_char? do
      true  ->
        char = VM.StdinBuffer.next_char
        VM.Register.set(register_name, char)
      false ->
        read = VM.StdinBuffer.read_stdin
        VM.StdinBuffer.insert(read)
        in_op(a)
    end
  end

  defp noop do
    :ignore
  end

  defp shift_pointer(arity) do
    VM.Memory.shift_pointer(arity + 1)
  end

  defp operand_value(a) when a >= 32768 and a <= 32775 do
    register_name = @register_table[a]
    VM.Register.get(register_name)
  end

  defp operand_value(a), do: a

end
