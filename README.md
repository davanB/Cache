# Cache

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `CACHE_SIZE=N mix phx.server`

## How it works

- The underlying cache is ETS (Erlang Term Storage).
- Writing to the ETS table is done though an Agent (Genserver).
- This is important because of the LRU eviction policy.
- ETS supports write concurrency via bucketing. This increases mutex granularity. The important part is updating the cache requires updating both the key/value pair and also the order in which keys are updated atomically, hence why it is done in the Agent where the single process acts as a critical section.
- The Agents (processes) message queue ensures clients get responses in the right order (FIFO) so another client writing to the cache does not invalidate the LRU order.
- Read concurrency is turned on to enable concurrent reads. Updating the LRU order is then done in the Agent again.

## Other Designs

- I actually wanted to see if we could avoid the Agent. This had a manjor issue that cleanup would not happen in the event of a large number of concurrent writes.
- A possibility to have concurrent writes is to have a 3rd ETS table act as a garbage collection mutex.
- After a set timeout period. The Agent will send a message to itself to write a single entry to this third cache.
- This entry acts as a mutex to block reads and writes while the Agent clears a large portion of the cache.
- In the meanwhile you only add entries to the time table while doing a put.
- It was also possible to use the Agents state as the cache. This has the downside of making reads non-concurrent and the GenServer is not optomized to store large amounts of data in its state unlike ETS.

## How to use it
- Run the server: `CACHE_SIZE=3 mix phx.server`
- Note `CACHE_SIZE` is required. The server will not start without it set.

cURL
- put: `curl -X PUT -d key=hello -d value=bye http://localhost:4000/cache/put`
--> "ok"
- get: `curl http://localhost:4000/cache/get\?key\=hello`
--> {"value":"bye"}

The arguments are passed via HTTP so they must be a serialized string. If you wish to store complex objects consider passing in a serialized JSON as the value payload.

## Tradeoffs
- A made the assumption that the cache size should never exceed the limit set.
- Other cache libraries such as Cachex use an LRW policy which can be modified to be LRU. The problem is Cachex allows the cache size to exceed the limit if a short burst of put operations occur and will then clear a percentage of all entries and not just what was least used.
- The benefit of this is higher capacity to handle multiple clients in parallel due to both read and write concurrency while sacraficing the correctness of the LRU.
- In production use, this would be the preferred method.
- The Agents message queue would become the bottleneck if the number of concurrent clients increases.
- The only way to know the limit would be to benchmark.
- Overall, this is a simple design which satisfies the requirement.