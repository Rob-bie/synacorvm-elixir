defmodule VM.BinReader do

  @bin_path "./challenge/challenge.bin"

  def parse_bin(path \\ @bin_path) do
    path
    |> File.read!
    |> convert_pairs
  end

  defp convert_pairs(instructions) do
    for <<value::little-integer-size(16) <- instructions>> do
      value
    end
  end

end
