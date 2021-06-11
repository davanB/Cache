defmodule Cache.Cache do
  @cache :main_cache
  def get(key) do
    LruCache.get(@cache, key)
  end

  def put(key, value) do
    LruCache.put(@cache, key, value)
  end
end
