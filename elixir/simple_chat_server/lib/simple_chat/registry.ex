defmodule SimpleChat.Registry do
  use GenServer

  @table :connections

  def init(_args) do
    case :ets.whereis(@table) do
       :undefined -> :ets.new(@table, [:named_table, :public])
       _ -> nil
    end
    {:ok, nil}
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def is_connected?(address) do
    :ets.lookup_element(@table, address, 2)
  rescue
    ArgumentError -> false
  end

  def connect(client) do
    :ets.insert(:connections, {client.name, client.socket})
    client
  end

  def disconnect(address) do
    :ets.delete(@table, address)
  end

  def get_connections do
    :ets.tab2list(:connections)
  end
end
