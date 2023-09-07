defimpl String.Chars, for: PID do
  def to_string(pid) do
    [_, identifier, _] = String.split(inspect(pid), ["<", ">"])
    identifier
  end
end
