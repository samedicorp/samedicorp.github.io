---
layout: post
title: Introducing Modula
---
In my previous posts I described some of the issues I encountered when developing Dual Universe scripts.

In this post I'd like to start to introduce my solution: [Modula](https://github.com/samedicorp/modula).


Modula is a modular script framework for Dual Universe.

It is actually a rewrite of a private framework that I developed during the beta-years of Dual Universe. 

The private framework is pretty extensive - with around 30 modules covering flight, industry and user interface - it also got a bit gnarly.

So what I'm doing with Modula is slowly cleaning up and porting across my old code. For this reason the code in the public repository may look incomplete - but don't worry, it should keep being updated until it catches up, then hopefully overtakes, my old framework.

(_Why Modula? Cos it is a modular framework, and the word has DU in it, obviously..._)

## Introduction

Modula is designed to take some of the tedium out of writing complex Dual Universe scripts, in a way that allows the code to:

- remain clean and modular
- be reused across different scripts and constructs
- be managed cleanly in source control
- be automatically packed into `.conf` and `.json` files (and potentially compacted)

## Modules

Modula is based around the idea of combining modules.

Each module in Modula is a Lua object that provides some functionality to the overall script. 

Modules are registered with the core. During registration a module can ask to respond to certain events and actions. They can also publish their services, to be used by other modules. 

The idea here that each module has a clearly defined tasks - such as showing an altimeter, managing auto-braking, managing the landing gear, controlling flight, etc. 

You can combine these modules in different ways to make the overall script that you want. 

You can also share these modules between multiple scripts.

If you want a different style of altimeter, you simply replace the altimeter module. If your ship doesn't have a warp drive, you don't bother with the warp module. Etc. 

When the script is finally packed up for distribution, only the code for the modules that were used is actually included.

## Core

The core is the glue that holds everything else together. It:

- loads and registers modules
- handles all events from DU, and sends them out to any module that has registered an interest
- detects all elements connected to the construct, in a way that makes it easy for a module to access the ones it needs.
- tracks the state of the keyboard and sends actions to modules in a clean way
- provides various utility scripts

With the exception of `unit.onStart`, all of the event handlers that are actually registered in DU are just stubs which call on to the core (the `unit.onStart` handler is a little more complex, as it is the one that sets up the core).

## Events

Modules can register for events with the Modula core:

```lua
    modula:registerForEvents({"onStart", "onStop"}, self)
```

When the event occurs, the corresponding handler on the module will be called. 

Modules can also _generate_ events:

```lua
    modula:call("onMyEvent", "some parameter")
```

Any other modules that have registered will be called. 

This ability is useful for modules that need to synchronise their actions with other modules. 

For example, the screen module manages creating html screen content. It calls `onUpdateScreen` to ask other modules to update their content. Any module interested in displaying screen content registers for this event. When a module gets the event, it calls the screen module back to provide some content. The screen module then combines it all into the final screen html.

## Services

Some modules provide services to other modules, but don't do so using events.

These modules can register themselves with the core:

```lua
    modula:registerService("panels", self)
```

Any other module that needs the "panels" service can find it, without having to know exactly what module is providing it:

```lua
    local panels = self.modula:getService("panels")
```

This provides full decoupling between the service and its implementation. 

Your construct script can be configured to use one implementation of the "panels" service, then changed later to use a different one. As long as both services provide the same API, everything will continue to work.


## Actions

For the most part, keyboard handling with modula just requires add some configuration to the `actions` property of the settings.

For each of the actions that you want to handle, you specify a record. 

The `target` property of this record specifies the service name that will be called when the action happens.

The other properties specify the name of the handler to call, and when to call it:

- `start`: calls the named handler on action start
- `stop`: calls the named handler on action stop
- `onoff`: calls the named handler on start and stop
- `loop`: calls the named handler on whilst the action is looping
- `long`: calls the named handler if the action is long-pressed

Here's a full example:

```lua
actions = {
        brake = {
            target = "test",
            start = "startTest",
            stop = "stopTest"
        },


        option1 = {
            target = "test",
            onoff = "startStopTest",
        },

        option2 = {
            target = "test",
            loop = "loopTest"
        },

        gear = {
            target = "test",
            stop = "normalPressTest",
            long = "longPressTest"
        },
    }
```

## Stay Tuned

That's enough for a brief introduction.

I'll post a bit more about Modula as work on the port progresses.

If you have any feedback, I'd love to hear it. Please add issues to [the Github repository](https://github.com/samedicorp/modula/issues). 