defmodule Cache.CacheTest do
  use ExUnit.Case

  alias Cache.Cache

  @cache_size 3
  @cache :main_cache

  test "cache maintains size" do
    Cache.put("key", 1)
    Cache.put("key2", 2)
    Cache.put("key3", 3)
    Cache.put("key4", 4)

    assert Cache.get("key") == nil
  end

  test "cache maintains LRU eviction" do
    Cache.put("key", 1)
    Cache.put("key2", 2)
    Cache.put("key3", 3)
    Cache.put("key4", 4)

    assert Cache.get("key") == nil
    assert Cache.get("key2") == 2

    Cache.put("key5", 3)
    Cache.put("key6", 4)

    assert Cache.get("key3") == nil
  end
end
