# Syscrap DB

## Queries


Queries principales previstas en el sistema, y dónde:


* FIND all Targets (Aggregator start)
* FIND all AggregationOptions for a target (Aggregator.Worker start)
* UPDATE detected_specs for a Target (Aggregator.Worker start)
* INSERT Aggregation for a metric,target,type,tag (Aggregator.Metric.* loop)
* DELETE size capped Aggregations for a metric,target,type,tag
(Aggregator.Metric.* loop)
* FIND the ReactionOptions for a reaction (Reactor.Worker start)
* FIND all ReactionTargets for a reaction (Reactor.Worker start)
* FIND last Aggregation for a metric,target,type (Reactor.Reaction.* loop)
* FINDandMODIFY some Aggregations for a metric,target,type (Reactor.Reaction.*
loop)
* INSERT Notification for a target,type (Reactor.Reaction.* loop)
* FINDandMODIFY first pending or stranded Notification (Notificator.Worker loop)
* FIND NotificationOptions for a target,type (Notificator.Worker loop)
* DELETE Notification (Notificator.Worker loop)


## ReactionOptions


Key fields:  reaction
Data fields:  updated, options


Example:
```
    { "reaction":"range",
      "updated":ISODate("2015-02-15T09:16:24.848Z"),
      "options":{
        "metrics":["cpu","ram","disk"],
        "ram_max":0.8
      } }
```

Collection para mantener las reactions y sus opciones. Pueden no existir. Los
valores por defecto en código deberían ser razonables.


## ReactionTargets


Key fields:  reaction, target
Data fields:  updated, options


Example:
```
    { "reaction":"range","target":"1.1.1.1",
      "updated":ISODate("2015-02-15T09:16:24.848Z"),
      "options":{
        "metrics":["cpu","ram","disk"],
        "ram_max":0.8
      } }
```

Collection para mantener la vinculación y las opciones de cada Reaction para un
Target. Opcionalmente se pueden fijar opciones para ese target en particular.
Por defecto se usarán las opciones del Reaction.


## Notifications

Key fields:    reaction, target, type
Data fields:    payload, updated


Email Notification example:
```
    { "reaction":"range","target":"8.8.8.8","type":"email",
      "payload":{"from":"asdf@sdf","to":"asfgadfg@sdfgsd",
                 "subject":"...","body":"..."},
      "updated":ISODate("2015-02-15T09:16:24.848Z") }
```

El módulo Reactor.Reaction genera un Notification en base de datos cuando se cumplen las condiciones para ello, usando los módulos del namespace Notification para ello. El módulo Notificator.Worker lee y consume la Notification de base de datos usando los mismo módulos.


## Aggregations


Key fields:    metric, target, type, tag
Data fields:    value, updated


Values for type:
* numeric:
  * RT                        capped by size(*)
  * variable (5min)          capped by TTL(*)
  * hour                        "
  * day                        "
* event                                capped by size



CPU RT example:
```
    { "metric":"cpu","target":"8.8.8.8","type":"RT","tag":20150215091624,
      "value":60.43,"updated":ISODate("2015-02-15T09:16:24.848Z") }
```

Log error example:
```
    { "metric":"log_error","target":"8.8.8.8","type":"event",
      "tag":20150215091624,"updated":ISODate("2015-02-15T09:16:24.848Z"),
      "value":{
        "data":"This is an error line in logs blah blah",
        "line":1234,
        "file":"production.log",
        "context":["njsdfkjbsdfgkjsbdfg","fasdfasd",...]
      } }
```

El módulo Aggregation que genera los datos es el que sabe qué necesita guardarse
para su métrica específica. Del mismo modo el Reaction que los lee también sabe
en qué formato se han guardado.


Todos los tipos de Aggregation están limitados, ya sea por size o TTL. Dada una
configuración y el tiempo suficiente, el sistema debe llegar un tamaño máximo
estable.


## AggregationOptions


Key fields:    metric, target(default: "generic")
Data fields:    options, updated


Example:
```
    { "metric":"cpu","target":"generic",
      "updated":ISODate("2015-02-15T09:16:24.848Z"),
      "options":{
        "limits":{"RT":100,"variable":3600,"hour":72*3600,"day":30*86400},
        "variable":300
      } }
```

Collection para mantener las opciones de cada Aggregation para un Target, en
caso de que los necesite. Por ejemplo los límites ( size o TTL ) de cada type.
Por defecto el target puede ser generic para tener opciones comunes a todos
ellos. Opcionalmente los parámetros se pueden fijar para algún target en
particular. Podría estar vacía. Los valores por defecto en código deberían ser
razonables.


## Targets


Key fields:   target(IP)
Data fields:    user, detected_specs, updated


Example:
```
    { "target":"8.8.8.8","user":"myuser",
      "updated":ISODate("2015-02-15T09:16:24.848Z"),
      "detected_specs":{
        "ram":4096,
        "cpu_cores":4,
        "disk":50000,
        "swap":512
      } }
```

Los detected_specs se irán actualizando periódicamente, y pueden ir ampliándose
cuando se implemente la detección de más (ej. nginx version, kernel version, OS
distribution, etc.)
