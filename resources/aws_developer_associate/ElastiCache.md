# ElastiCache

Amazon ElastiCache:

- ElastiCache is to get managed Redis or Memcached
- Cache — in memory databases, high performance and low latency
    - Cache helps reduce load off of databases for read intensive workload
    - Common queries are going to be cached — to not query database all the time
- **AWS takes care** of OS maintenance/patching, optimization setup, configuration, monitoring, failure recovery, backups
- **Using ElastiCache involves heavy application code changes**

**Redis vs Memcached:**

- Redis:
    - **Multi AZ with Auto-Failover**
        - If you **enable cluster mode** → replication across multiple shards
        - If you **disable cluster mode** → single shard with one primary node and up to 5 read replicas (more below)
    - **Read replicas to scale reads** (you can enable multiple replication/clustering/sharding)
    - **High availability**
    - Data Durability → AOF persistance
    - Backup and restore features
- Memcached:
    - **Sharding** (multi-node for partitioning data)
    - No High availability (no replication)
    - No persistant
    - No backup and restore
    - Multi-threaded architecture
    

Caching Strategies:

- Is caching safe? Yes, but data may be out of date → eventually consistent
    - Use cache if data changing slowly
- Data should be structured for caching → key value
- Which caching pattern?

- **Lazy Loading / Cache-Aside / Lazy Population** —
    
    ![Untitled](ElastiCache%203e186c34cd4e4c65a8991e9dceffbe75/Untitled.png)
    
    - Pros:
        - **Only requested data is cached** → the cache isn’t filled with unused data
        - **Node failures are not fatal** → if cache node is down → read from RDS
    - Cons:
        - If cache miss → 3 network calls → noticeable delay
        - Stale data → data can be updated in RDS but outdated in ElastiCache (eventually consistent)

- **Write Through** — add or update cache when database is updated
    
    ![Untitled](ElastiCache%203e186c34cd4e4c65a8991e9dceffbe75/Untitled%201.png)
    
    - Pros:
        - **Data in cache is always up-to-date** → read are always quick
        - **Write penalty** vs. Read penalty → each write requires 2 calls → probably it’s better from the user perspective
    - Cons:
        - Cache has no data until we make RDS write → we can combine Lazy Loading with this strategy
        - Cache churn — a lot of data will never be read/used

- **Cache Evictions and TTL** —
    - Item from cache can be deleted or outdated (due to TTL)
    - Item is evicted because the memory is full and it’s not recently used (LRU)
    - TTL is helpful for any kind of data (can be seconds/hours/days)
    - **If too many evictions happen due to memory, you should scale up or out**
    

ElastiCache Redis: Cluster Modes

- **Clusted Mode Disabled** —
    - Single shard with one primary node with up to 5 replicas
    - Asynchronous replication
    - The primary node is used for reads/writes
    - The other nodes are used only for reads
    - **One shard — all nodes have all the data**
    - Multi AZ is enabled by default for failover
    
    ![Untitled](ElastiCache%203e186c34cd4e4c65a8991e9dceffbe75/Untitled%202.png)
    
- **Cluster Mode Enabled** —
    - Data is partitioned across shards (helpful to scale writes)
    - Each shard has a primary node and up to 5 read-only replicas
    - Multi AZ capability
    - **Up to 500 nodes per cluster**
        - If you don’t set any replicas: 500 single shards with single master
        - 250 shards with one master and one read replica
        - etc.
    
    ![Untitled](ElastiCache%203e186c34cd4e4c65a8991e9dceffbe75/Untitled%203.png)
    
    MemoryDB for Redis:
    
    - Redis-compatible, **durable**, in-memory database service
    - MemoryDB is real database (not only for caching) with Redis API
    - **************Ultra-fast performance with over 160 millions requests per second**************
    - Scale seamlessly from 10s GB to 100s TBs of storage
    - Use cases: web and mobile apps, media streaming