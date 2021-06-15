defmodule Cache.LruCache do
  use Agent

  @position_index 2
  @cache_table :cache
  @ttl_table :cache_ttl

  def start_link(size) do
    Agent.start_link(__MODULE__, :init, [size], name: __MODULE__)
  end

  def put(key, value),
    do: Agent.get(__MODULE__, __MODULE__, :handle_put, [key, value])

  def get(key) do
    case :ets.lookup(:cache, key) do
      [{_, _, value}] ->
        Agent.get(__MODULE__, __MODULE__, :touch, [key])
        value

      [] ->
        nil
    end
  end

  def init(size) do
    :ets.new(@ttl_table, [:named_table, :ordered_set])
    :ets.new(@cache_table, [:named_table, :public, {:read_concurrency, true}])
    %{size: size}
  end

  def handle_put(%{size: size}, key, value) do
    delete_ttl(key)
    position = insert_ttl(key)
    :ets.insert(@cache_table, {key, position, value})
    clean_oversize(size)
    :ok
  end

  def touch(_state, key) do
    delete_ttl(key)
    position = insert_ttl(key)
    :ets.update_element(@cache_table, key, [{@position_index, position}])
    :ok
  end

  defp delete_ttl(key) do
    case :ets.lookup(@cache_table, key) do
      [{_, old_position, _}] ->
        :ets.delete(@ttl_table, old_position)

      _ ->
        nil
    end
  end

  defp insert_ttl(key) do
    position = :erlang.unique_integer([:monotonic])
    :ets.insert(@ttl_table, {position, key})
    position
  end

  defp clean_oversize(size) do
    if :ets.info(@cache_table, :size) > size do
      oldest_timestamp = :ets.first(@ttl_table)
      [{_, old_key}] = :ets.lookup(@ttl_table, oldest_timestamp)
      :ets.delete(@ttl_table, oldest_timestamp)
      :ets.delete(@cache_table, old_key)
    else
      :ok
    end
  end
end
