defmodule Cache.CacheTest do
  use ExUnit.Case

  alias Cache.LruCache

  @cache_size 3
  @cache :main_cache

  test "cache maintains size" do
    LruCache.put("key", 1)
    LruCache.put("key2", 2)
    LruCache.put("key3", 3)
    LruCache.put("key4", 4)

    assert LruCache.get("key") == nil
  end

  test "cache maintains LRU eviction" do
    LruCache.put("key", 1)
    LruCache.put("key2", 2)
    LruCache.put("key3", 3)
    LruCache.put("key4", 4)

    assert LruCache.get("key") == nil
    assert LruCache.get("key2") == 2

    LruCache.put("key5", 3)
    LruCache.put("key6", 4)

    assert LruCache.get("key3") == nil
  end
end
