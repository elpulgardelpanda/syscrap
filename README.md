
# Syscrap

Syscrap aims to be a systems monitor application with a minimum logic on the
monitored machines. The figure is a scraper. Surgically visit the machine,
collect data, and leave.

It's a centralized system from the point if view of the monitored machines, but
it's really distributed and scalable internally. Don't be fooled by that.

The minimum needed to monitor a machine is a ssh connection. Only with that
many metrics can already be gathered, so we can work with it.

(...)


## Development

We will try to use `git pull --rebase`.
Run this once the project is cloned, from the root directory of the project:

```
git config branch.autosetuprebase always
```
( Taken from http://stevenharman.net/git-pull-with-automatic-rebase )


## Map

![Map](/doc/syscrap.dot.png)

## Application structure

The main supervisor ensures an `Aggregator`, a `Reactor`, a `Notificator`,
and the Mongo pool, are all alive. The Erlang system also ensures
[SSH](http://www.erlang.org/doc/man/ssh.html),
[Logger](https://github.com/elixir-lang/elixir/tree/master/lib/logger) and
[Harakiri](https://github.com/rubencaro/harakiri) are running.


### Aggregation

The `Aggregator` is a mere supervisor for every `Aggregator.Worker`. It keeps
alive one and only one `Aggregator.Worker` for each monitored `Target`. It uses
a [Populator](https://github.com/rubencaro/populator) for this.

An `Aggregator.Worker` supervises several `Aggregator.Wrapper` processes. Every
`Aggregator.Worker` gets an open connection from the SSH application, and passes
it to its children `Aggregator.Wrapper`. Each `Aggregator.Worker` will keep
an open connection to its monitored `Target`, and recreate it if gets lost.

Every `Aggregator.Wrapper` executes a specific metric gathering loop. It will
choose one from the `Syscrap.Aggregator.Metric.*` namespace, where the
actual gathering loop logic resides. The choice will be made based on the
request made by the underlying `Aggregator.Worker`. Metrics are one of:

* `Vitals`: regular CPU, RAM, swap & disk data.
* `Logs`: worth noting messages seen on logs.
* `Traffic`: traffic stats yielded by nginx.
* `POL`(Proof-Of-Life) data:
  * `File`: check files periodically touched by the apps.
  * `Port`: try to establish a TCP connection to a port.
  * `Socket`: try to establish a TCP connecction to a socket.

All these modules implement the `Syscrap.Aggregator.Metric` behaviour. They are
the ones that actually get the data. Their processing loops look like:

1. Execute gathering command
2. Save to DB (if needed)
3. Sleep

Whether its command is a simple `free` or a `df -h`, every `Aggregator.Metric` is
specialized on its task. They may write to different DB collections. Their loop
period is also different.


### Mongo DB

A `Mongo` worker is a wrapper around a connection to the underlying MongoDB
server. `Mongo` workers are pooled using
[poolboy](https://github.com/devinus/poolboy). The pool size is configurable
to accomodate every `Metric` on the system and everything needed
by every `Reaction` (which may be much). If the system scales, the
underlying Mongo must scale too.


### Reaction

The `Reactor` only supervises a limited pool of `Reactor.Worker` processes.
It keeps alive one worker process for each `Reaction` defined in the
`Syscrap.Reactor.Reaction.*` namespace.

Each `Reactor.Worker` starts the checking loop for the given `Reaction`. The
actual `Reaction` logic can be just as simple as a threshold check over a DB
stored value. But also can be much more complex. It may need to spawn and
supervise its own pool of processes. That's totally up to the `Reaction`
implementation.

At any point of the process, a `Reaction` or one of its derivatives can
queue a notification on the `Notificator`, read/write DB data using the `Mongo`
pool.


### Notification

The `Notificator` supervises a limited pool of `Notificator.Worker`
processes. The size of the pool is configurable. If the system scales, the
pool of `Notificator.Worker`s must scale too.

The `Notificator` also provides helpers for any other process on the system
to queue notifications. These are simple functions to properly add elements
to the underlying Mongo queue. They add no load to the `Notificator`
process itself.

A pending notification on DB contains a reference to the actual `Notification`
module to use, and provides all the needed parameters for it to work.

Each `Notificator.Worker` lives in a loop consuming pending notifications. For
each pending notification it gets, it starts a process and calls the `run`
function for the right module from the `Syscrap.Notificator.Notification.*`
namespace.


## TODOs

* Consider using https://github.com/ericmj/mongodb
* Pass minimal hierarchy test
* ...


## Changelog

(...)
