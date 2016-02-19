
# Syscrap
[![Build Status](https://travis-ci.org/rubencaro/syscrap.svg?branch=master)](https://travis-ci.org/rubencaro/syscrap)

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
  * `Socket`: try to establish a TCP connection to a socket.
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

Notifications should ensure the message is actually sent, implement retry logic, and even alternate notification methods.


## Deploy models

The main purpose of `Syscrap` is to monitor servers to ensure its fitness within specified conditions. It can be thought to be deployed in many different ways, all with pros and cons. Some tools ([Bottler](https://github.com/rubencaro/bottler), exrm, etc.) may make it easier to deploy in one way or another, but here we expose some theoretical deploy layouts. Not the tools that do it.

### Single server deployment

This is the simplest way to deploy `Syscrap`. One single server with the app running on it. It's the easiest way to do it, but it has some clear limitations.

* The first one is that you need some external monitoring tool to monitor the `Syscrap` server itself.
* The number of monitored servers is limited to the actual capacity of that server. Typically on a regular 4 CPU core, 4GB RAM, 20GB disk you should be able to monitor several hundreds of servers and keep the history data of many months.
* If the server where `Syscrap` is deployed goes down, then everything is down. There is no backup.

![](/doc/deployment.dot.png)

### Distributed application on Erlang nodes

This deploy layout takes advantage of [Erlang Application Distribution](http://erlang.org/doc/design_principles/distributed_applications.html) machinery. It consists on keep two or more servers connected, and deploy `Syscrap` to all of them. Then Erlang manages to keep `Syscrap` alive on any of those servers, but only on one of them. The main advantage is that if the server where the app is running goes down, Erlang will detect it and start a new instance of the app on one of the other servers, so there is always one and only one copy of the app running as long as at least one of the target servers is up.

![](/doc/deployment2.dot.png)

This gives a backup mechanism, but still has some of the caveats of the single server deploy layout:

* One is the need of an external monitor to look for the `Syscrap` servers. Not only to control that the app is up, but to see it goes on nicely. Now that there is the failover/takeover Erlang mechanism it is much less likely to see the app down because the hosting server goes down, but it still needs some health monitoring.
* The other is the limited capacity, for the app is still limited to one single server.

### Herd network

This layout is based on the idea of having several _single_server_ deployments monitoring each other. This way each `Syscrap` server is monitoring its targets and at least one other `Syscrap` server, and each `Syscrap` server is being monitored at least by one other `Syscrap` server.

If a Syscrap server goes down you can react to it (be notified, restart the broken server, etc.), just like any other target server. If it has any other health problem (CPU, RAM, disk, etc.) you can react as well.

The size of a server is no longer a limit, because you can have as many Syscrap servers as you need, each monitoring as many targets as it can fit.

![](/doc/deployment3.dot.png)

The main problem is the deployment setup, which would need of a flexible enough tooling ([Bottler](https://github.com/rubencaro/bottler) + [Harakiri](https://github.com/rubencaro/harakiri) are enough). It would have to deploy each release to every server, and then setup the database configuration for each one of them to lay down the actual self watching network.

## TODOs

* Generate notifications when SSH connection fails:
    * Remove the connection establishment code from the hierarchy building sequence. The worker itself cannot depend of whether the connection can be established. Worker successful start means the connection is _trying_ to be established, not necessarily established.
    * Instead it should have some kind of connection handler that creates aggregation entries on db notifying of every retry for the connection, up until it gets to connect. That enables the event of _not being able to connect_ to be notified as any other.
    * => Use a simple `spawn_link`.
* Define a DeferredStarter
* Generate notifications when hierarchy finds trouble
* Implement basic Aggregations
* Implement basic Reactions
* Implement basic Notifications
* Use Populator also with Notificator, based on notifications queue length
* Implement more Aggregations, Reactions, Notifications
* Notification retries and alternations
* Aggregations history limits.
* Get stable on production, bump to 1.0
* Consider using https://github.com/ericmj/mongodb when it matures
* ...


## Changelog

(...)
