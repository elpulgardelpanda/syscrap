
# Syscrap

Syscrap aims to be a systems monitor application with a minimum logic on the monitored machines. The figure is a scraper. Surgically visit the machine, collect data, and leave.

The minimum needed to monitor a machine is a ssh connection. Only with that many metrics can already be gathered, so we can work with it.

## Map

![Map](/doc/syscrap.dot.png)

## Application structure

The main supervisor ensures an `Aggregator`, a `Reactor`, a `Notificator`, and the Mongo pool, are all alive. The Erlang system also ensures [SSH](http://www.erlang.org/doc/man/ssh.html), [Logger](https://github.com/elixir-lang/elixir/tree/master/lib/logger) and [Harakiri](https://github.com/rubencaro/harakiri) are running.

### Aggregation

The `Aggregator` is a mere supervisor for every `Aggregator.Worker`. It keeps alive one and only one `Aggregator.Worker` for each monitored `Target`. It uses a [Populator](https://github.com/rubencaro/populator) for this.

An `Aggregator.Worker` supervises several `Aggregator.Wrapper` processes. Every `Aggregator.Worker` gets an open connection from the SSH application, and passes it to its children `Aggregator.Wrapper`. Each `Aggregator.Worker` will keep an open connection to its monitored `Target`, and recreate it if gets lost.

Every `Aggregator.Wrapper` executes a specific metric gathering loop. It will be one from the `Syscrap.Aggregator.Metric.*` namespace, where the actual gathering loop logic resides. The metric module will be passed by the underlying `Aggregator.Worker`, which will get it from `aggregation_options` collection on db. Metrics are one of:

* `Vitals`: regular CPU, RAM, swap & disk data.
* `Logs`: worth noting messages seen on logs.
* `Traffic`: traffic stats yielded by nginx.
* `POL`(Proof-Of-Life) data:
  * `File`: check files periodically touched by the apps.
  * `Port`: try to establish a TCP connection to a port.
  * `Socket`: try to establish a TCP connecction to a socket.
* ...

All these modules implement the `Syscrap.Aggregator.Metric` behaviour. They are the ones that actually get the data. Their processing loops look like:

1. Execute gathering command
2. Save to DB (if needed)
3. Sleep

Whether its command is a simple `free` or a `df -h`, every `Aggregator.Metric` is specialized on its task. They may write to different DB collections. Their loop period may also be different.


### Mongo DB

A `MongoWorker` is a `GenServer` wrapped around a connection to the underlying MongoDB server. `MongoWorker`s are pooled using a
[poolboy](https://github.com/devinus/poolboy) pool called `MongoPool`. The pool size is configurable to accommodate every `Metric` on the system and everything needed by every `Reaction` (which may be much). If the system scales, the underlying Mongo server must scale too.


### Reaction

The `Reactor` is a mere supervisor for every `Reactor.Worker`. It keeps alive one and only one `Reactor.Worker` for each entry on the `reaction_targets` collection on db. It uses a [Populator](https://github.com/rubencaro/populator) for this, just like the `Aggregator`.

Each `Reactor.Worker` starts the checking loop for the given `Reaction`. The complete `reaction_targets` db entry is passed to the worker, including all needed options. In general it analyzes data from the `aggregations` collection, and at any point of the process, a `Reaction` can queue a notification on the `notifications` db collection.

The actual `Reaction` logic can be just as simple as a threshold check over a DB stored value. But also can be much more complex. It may need to spawn and supervise its own pool of processes. That's totally up to the `Reaction` implementation. Every implementation obeys the `Syscrap.Reactor.Reaction` behaviour, and lays on the `Syscrap.Reactor.Reaction.*` namespace. Some may be:

* `Range`: Some value fits on the given range of values.
* `Presence`: Some value is present.
* `Regexp`: Some value matches the given regular expression.
* ...


### Notification

The `Notificator` supervises a limited pool of `Notificator.Worker` processes. The size of the pool is configurable. If the system scales, the pool of `Notificator.Worker`s must scale too.

The `Notificator` also provides helpers for any other process on the system to queue notifications. These are simple functions to properly add elements to the underlying Mongo queue. They add no load to the `Notificator` process itself.

A pending notification on DB contains a reference to the actual `Notification` module to use, and provides all the needed parameters for it to work.

Each `Notificator.Worker` lives in a loop consuming pending notifications. For each pending notification it gets, it starts a process and calls the `run` function for the right module from the `Syscrap.Notificator.Notification.*` namespace. Every notification module implements the `Syscrap.Notificator.Notification` behaviour. They may be:

* `Email`: Send a regular email.
* `API`: Call some API, which may be:
  * `Telegram`
  * `Asana`
  * `Slack`
  * ...
* `MessageQueue`: enqueue a message somewhere with db-like access.
* ...


## TODOs

* Consider using https://github.com/ericmj/mongodb when it matures
* ...


## Changelog

(...)
