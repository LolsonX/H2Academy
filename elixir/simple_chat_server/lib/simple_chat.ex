defmodule SimpleChat do
  require Logger
  @port String.to_integer(System.get_env("PORT") || "4040")
  def accept() do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connection on port: #{@port}")
    accept_messages(socket)
  end

  defp accept_messages(socket) do
    client = accept_connection(socket)
    start_process(client, fn -> register(client) end)
    accept_messages(socket)
  end

  defp accept_connection(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} -> client
      {:error, msg} -> handle_error(msg)
    end
  end

  defp handle_error(msg) do
    Logger.info("Exited pid: #{self()}, reason: #{msg}")
    Process.exit(self(), :normal)
  end

  defp handle_error(msg, source_address) do
    if source_address do
      SimpleChat.Registry.disconnect(source_address)
      handle_error("Client: #{source_address} closed connection")
    else
      handle_error(msg)
    end
  end

  defp create_user(client_socket) do
    SimpleChat.Client.new(client_socket, get_username(client_socket))
      |> SimpleChat.Registry.connect
  end

  defp get_username(client_socket) do
    send_message(client_socket, "Enter username: ")
    read_line(client_socket)
      |> String.trim_trailing
  end

  defp register(client) do
    user = create_user(client)
    Logger.info("Connected user: #{user.name}")
    start_process(user.socket, fn -> serve(user) end)
  end

  defp serve(user) do
    read_line(user.socket, source_address: user.name)
      |> form_message(user)
      |> broadcast_message(user.name)
    serve(user)
  end

  defp read_line(client_socket, opts \\ []) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} -> data
      {:error, reason} -> handle_error(reason, Keyword.get(opts, :source_address))
    end
  end

  defp broadcast_message(message, source_address) do
    SimpleChat.Registry.get_connections()
      |> Enum.reject(fn {recipient_address, _socket} -> recipient_address == source_address end)
      |> Enum.each(fn {address, recipient_socket} -> send_message(recipient_socket, message, address: address) end)
    Logger.info("#{source_address}: #{message}")
  end

  defp send_message(recipient_socket, message, opts \\ []) do
    case :gen_tcp.send(recipient_socket, message) do
      :ok -> :ok
      {:error, reason} -> handle_error(reason, source_address: Keyword.get(opts, :source_address))
    end
  end

  defp start_process(socket, function) do
    {:ok, pid} = Task.Supervisor.start_child(SimpleChat.TaskSupervisor, function)
    :ok = :gen_tcp.controlling_process(socket, pid)
  end

  defp form_message(message, user) do
    "#{user.username}: #{message}"
  end
end
