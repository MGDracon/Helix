defmodule Helix.Cache.State.QueueSyncTest do

  use Helix.Test.Case.Integration

  import Helix.Test.Case.Cache

  alias Helix.Test.Cache.Helper, as: CacheHelper
  alias Helix.Cache.Internal.Cache, as: CacheInternal
  alias Helix.Cache.Query.Cache, as: CacheQuery
  alias Helix.Cache.State.PurgeQueue, as: StatePurgeQueue
  alias Helix.Cache.State.QueueSync, as: StateQueueSync

  setup do
    CacheHelper.cache_context()
  end

  describe "queue sync" do
    test "it syncs periodically", context do
      server_id = context.server.server_id

      # First query, will fetch from origin and add entry to PurgeQueue
      {:ok, _} = CacheQuery.from_server_get_all(server_id)
      assert_miss CacheInternal.direct_query(:server, server_id)
      assert StatePurgeQueue.lookup(:server, server_id)

      # Nothing on the DB..
      assert_miss CacheInternal.direct_query(:server, server_id)

      # Set QueueSync interval to 50ms & give it enough time
      StateQueueSync.set_interval(50)
      :timer.sleep(100)

      # ...it will be added to the DB
      assert_hit CacheInternal.direct_query(:server, server_id)
      {:ok, _} = CacheQuery.from_server_get_all(server_id)

      # And removed from the PurgeQueue
      refute StatePurgeQueue.lookup(:server, server_id)

      StatePurgeQueue.sync()
    end
  end
end
