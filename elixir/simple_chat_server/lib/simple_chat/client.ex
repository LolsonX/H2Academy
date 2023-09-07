defmodule SimpleChat.Client do
  defstruct [:name, :socket, :username]
  def new(socket, username) do
    %SimpleChat.Client{name: get_name_from_socket(socket), socket: socket, username: username}
  end

  defp get_name_from_socket(socket) do
    {:ok, {ip, port}} = :inet.peername(socket)
    "#{Enum.join(Tuple.to_list(ip), ".")}:#{port}"
  end
end
