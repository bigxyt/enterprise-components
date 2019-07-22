## **`mserve` component**

`mserve` routes asynchronous messages to a collection of clones of a process.


### Configuration

A typical use case is to use `mserve` as a load balancer for a collection of clones of a historical data base.
Example `system.cfg` sections may look as follows:

```cfg
  [[core.mserve]]
    command = "q mserve.q"
    type = q:mserve/mserve
    port = ${basePort} + 30
    memCap = 10000
    cfg.dataSource = core.hdb

  [[core.hdb:5]]
    command = "q hdb.q"
    type = q:hdb/hdb
    port = ${basePort} + 20+ ${EC_COMPONENT_INSTANCE}
    memCap = 10000
    cfg.hdbPath = ${EC_SYS_PATH}/data/core.hdb_0 #all instances load the data of first one
```

### Sending queries to `mserve`

`mserve` accepts only asynchronous messages.

One way to see the result is to use deferred communication to emulate synchronous messaging.
For example the following may be executed on the client:

```
h:hopen `::17030; / open connection to mserve
(neg h) "select from trade where date=2019.05.20";t:h[]; / execute a query on one of the slave processes
```

Another way to execute commands on the slave is to define a callback on the client and store the result there.

```
cb:{[r] t::r;}; // define callback
(neg h)({r:select from quote where date=x;:(`cb;r)};2019.05.20);
```

The pair (two-element list)
```
({r:select from quote where date=x;:(`cb;r)};2019.05.20)
```

is forwarded (asynchronously) for evaluation to one of the slaves, where the first element (the function) is evaluated. The return value is the pair which is then forwarded by mserve to the client which results in the evaluation of the `cb` function on the result `r`.
