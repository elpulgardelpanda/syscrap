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

We will try to use pull --rebase.
Run this once the project is cloned, from the root directory of the project:

```
git config branch.autosetuprebase always
```
( Taken from http://stevenharman.net/git-pull-with-automatic-rebase )


## Project components

* SSH Connector
* Mongo Workers
* Mongo Pool
* SMTP Mailer helper
* Aggregator
* Aggregator Workers
* Metric Workers
* Target
* Reaction
* Reactor
* Reactor Workers
* Main supervisor


## Map

```
+--------------+  +--+     +--+  +-----------------+  +--+     +--+
|Reactor.Worker|  |RW| ... |RW|  |Aggregator.Metric|  |AM| ... |AM|
+-----------+--+  +-++     +-++  +--------+--------+  ++-+     ++-+
           |       |        |            |            |        |
           |       |        |            |            |        |
           +----------------+            +------------+--------+
                   |                     |
                 +-+-----+           +---+-------------+  +--+      +--+
                 |Reactor+------+    |Aggregator.Worker|  |AW|  ... |AW|
                 +-------+      |    +----+------------+  +-++      +-++
                                |         |                |         |
                                |         |                |         |
       +-----+     +-+          |         +----------------+---------+
       |Mongo| ... |M|          |         |
       +--+--+     +++          |    +----+-----+
          |         |           | +--+Aggregator|
          +---------+           | |  +----------+
                    |           | |
                    |           | |      +---+       +-----------+
              +-----+---+       | |      |SSH|       |Notificator|
              |MongoPool|       | |      +-+-+       +-----+-----+
              +----+----+       | |        |               |
                   |        +---+-+-+      |               |
                   +--------+Syscrap+------+---------------+
                            +-------+

```

## Application structure

The main supervisor ensures an `Aggregator`, a `Reactor`, the
[SSH](http://www.erlang.org/doc/man/ssh.html) application, and the Mongo pool,
are all alive.


### Aggregation

The `Aggregator` is a mere supervisor for every `Aggregator.Worker`. It keeps
alive one and only one `Aggregator.Worker` for each monitored `Target`.

An `Aggregator.Worker` supervises several `Aggregator.Metric` processes. Every
`Aggregator.Worker` gets an open connection from the SSH application, and passes
it to its children `Aggregator.Metric`. Each `Aggregator.Worker` will keep
an open connection to its monitored `Target`, and recreate it if gets lost.

Every `Aggregator.Metric` executes a specific metric gathering loop. It will
choose which one to run based on the request made by the underlying
`Aggregator.Worker`. That means the actual gathering loop executed resides
on one module from the `Syscrap.Aggregator.Metric.*` namespace. Those can be:

* Vitals: regular CPU, RAM, swap & disk data.
* Logs: worth noting messages seen on logs.
* Traffic: traffic stats yielded by nginx.
* POL(Proof-Of-Life) data:
  * File: check files periodically touched by the apps.
  * Port: try to establish a TCP connection to a port.
  * Socket: try to establish a TCP connecction to a socket.

These 

its commands through that very same connection.
They are the ones that actually get the data. Their processing loops look like:

* Execute gathering command
* Save to DB
* Sleep

Whether its command is a simple `free` or a `df -h`, every `Aggregator.Metric` is
specialized on its task. They may write to different DB collections. Their loop
period is also different.

A `Mongo` worker is a wrapper around a connection to the underlying MongoDB
server. `Mongo` workers are pooled using
[poolboy](https://github.com/devinus/poolboy). The pool size is configurable
to accomodate every `Aggregator.Metric` on the system. If the system scales, the
underlying Mongo must scale too.


### Reaction

The `Reactor` only supervises `ReactorWorker` processes. It keeps alive one
process for each `Reaction` defined in the system.

Each `ReactorWorker` is specific for its `Reaction`. The actual `Reaction`
logic can be so simple, like a threshold check over a DB stored value. But also
can be much more complex. It may need to spawn and supervise its own pool of
processes.

At any point of the process, a `ReactorWorker` or one of its children can use
the SMTP helpers to send email notifications.

(...)


## TODOs

* ...


## Changelog

(...)
