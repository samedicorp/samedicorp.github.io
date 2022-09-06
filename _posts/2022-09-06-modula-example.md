---
layout: post
title: Modula Example
published: true
---
To continue my introduction of [Modula](https://github.com/samedicorp/modula), here's [a simple example script](https://github.com/samedicorp/container-monitor), which makes use of a couple of built in modules.

## Container Monitor

This script runs on a programming board, with a screen and some containers attached. It draws a little bar chart showing how full the containers are.

It isn't intended to be beautiful or particularly clever, but it illustrates how to set up a script project and how to pull in and use other modules.

### Configuration

There is really only one standard file that you need in a script. It is called `configure.lua`, and it lives at the root of the script folder.

In our example, it looks like this:

```lua
modulaSettings = { 
    name = "Container Monitor",
    version = "1.0",
    modules = {
        ["samedicorp.modula.modules.containers"] = { },
        ["samedicorp.modula.modules.screen"] = { },
        ["samedicorp.container-monitor.main"] = { }
    },
    templates = "samedicorp/container-monitor/templates"
}
```

This does a few things. It gives the module a name and version number, that the pack tool can use later.

The `modules` property lists the modules that the tool uses. Notice that two of these modules are standard ones that are part of Modula, so they are prefixed with `samedicorp.modula.modules`. The other one is the module that defines the code that drives our script.

The `templates` property is optional. If you supply it, it should contain the path to template `.conf` and `.json` files that the pack tool will use. If you omit it, the defaults will be used instead.

### Main Module

A script built with Modula can use modules from Modula itself, or from other libraries (supplied by other people).

However, it also needs at least one custom module which wires everything together and drives the script along.

By convention this is called `main.lua` and like the configuration file, it lives at the root of the script folder.

Note that a script can have multiple modules of its own if it wants. Often having a single one is enough though.

### Registration

There is only one function that a module _must_ define: `register`.

There's what our one looks like:

```lua
local Module = { }

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onContainerChanged")
end
```

The register function is called early on during startup. Modula doesn't yet know about all of the modules that have been configured, so you can't access other services at this point.

Things you can do, however, include:

- register as a service
- register for events
- example the connected elements

In our case, the only thing we want to do is to register for a few events.

### Event Handlers

In our registration function, we registered for the `onStart`, `onStop` and `onContainerChanged` events.

So the next thing our script needs to contain is handlers for these three events:

```lua

function Module:onStart()
    debugf("Container Monitor started.")

    self:attachToScreen()
    local containers = modula:getService("containers")
    if containers then
        containers:findContainers("ContainerSmallGroup", "ContainerMediumGroup", "ContainerLargeGroup", "ContainerXLGroup")
    end
end

function Module:onStop()
    debugf("Container Monitor stopped.")
end

function Module:onContainerChanged(container)
    self.screen:send({ name = container:name(), value = container.percentage })
end
```

This code illustrates a few points:

The `debugf` function is a global supplied by Modula, which you can use for debug logging. Output from this will only be logged to the console if Modula's `logging` option is set to true.

There is also `printf` function, which always logs.

In our `onStart` handler, we're using `getService` to find a service supplied by another module. This is the `samedicorp.modula.modules.containers` module that we mentioned in our configuration file.

If we find it, we call `findContainers` on it. That's a function that the service implements, which uses Modula to find any linked contains of the types specified. Once we've done this, the containers module will send us a `onContainerChanged` event every time one of these containers changes.

In our `onStop` handler, we're not actually doing anything useful. Quite often this is the case, since you get this handler when everything is being shut down, and mostly you can just safely leave everything alone -- any resources that you are using will be automatically freed up.

Finally, in our `onContainerChanged` handler, we're calling a method on `self.screen`. This property was set up by the `attachToScreen` method that we called during `onStart`, so we should probably look at that next...

### Screens

The other built in module we're using is the `screen` module, which supplies a service with the same name:


```lua
function Module:attachToScreen()
    -- TODO: send initial container data as part of render script
    local service = modula:getService("screen")
    if service then
        local screen = service:registerScreen(self, false, self.renderScript)
        if screen then
            self.screen = screen
        end
    end
end
```

During startup with look for this service, and if we find it, we register a screen with it.

We pass a reference to the current module, so that the screen module can call us back when the screen produces output.

If we pass a name as the second parameter, we will get attached to the screen element with that name. Alternatively we can pass false (as we are doing here), and we're attached to the first screen connected to the programming board.

Finally, we pass a render script. This is lua code, using the DU rendering API. We'll look at our render script in a minute, but for now, that's enough detail. 

Now the line of code in our `onContainerChanged` handler makes more sense:

```lua
    self.screen:send({ name = container:name(), value = container.percentage })
```

We send some data to the attached screen. The data contains the name of the container that changed, and a percentage value of how full it is.

The render script uses this information on the screen to draw a bar for the container.

### All Over, Bar The ~~Shouting~~ Rendering

That's about it, for our script. It shows how simple things can be, when you can split the code up into small reusable models.

Most of the cleverness stuff is happening elsewhere, in the `containers` and `screen` modules, and in the rendering script.

The bit of code we wrote, which made this particular script what it is, is quite clean and simple.

Which is nice...

### Rendering

Of course, there is one major detail still to come, which is the rendering code.

```lua
Module.renderScript = [[
containers = containers or {}
if payload then
    local name = payload.name
    if name then
        containers[name] = payload
    end
    reply = { name = name, result = "ok" }
end
local screen = toolkit.Screen.new()
local layer = screen:addLayer()
local chart = layer:addChart(layer.rect:inset(10), containers, "Play")
layer:render()
screen:scheduleRefresh()
]]
```

But hang on... this looks suspiciously simple too.

It is, of course, too simple by half.

That's because of two things.

Firstly, the script that you pass to the `screen` module is just part of the code it sends to the actual screen. It adds some code for you, which handles passing data to the screen, and getting responses back. The details of that could be a post in themselves, so I'll skirt over them for now.

Secondly, this script we've written above is using another technology, which is a companion of Modula. It's called Toolkit, and it's a user interface library.

It defines a set of standard user interface widgets that you can use to display information. It's pretty simple right now, but like Modula itself, it is growing fast.

As you can see from the code above, it lets you operate at quite a high level. We're adding a single widget, which is a chart, and passing it a list of records, that are sent from the main script. Each record consists of a name and a value (between 0 and 1). The chart widget draws a bar for each record, with a label showing the name and value.

This description is deliberately light on detail - again, Toolkit needs multiple posts in its own right.

## Summary

To wrap things up.

What you've seen here is a little example, showing how you can write modula scripts.

If you look at the [Github repo] you will see that there's a bit more to it than I've described here, but not much. There a bit of configuration which lets VSCode automatically pack the script which you hit Ctrl-B. There are some templates used to make autoconf and json files when you pack.

That's about it though!

In future posts I'll go into all of this in more detail, but I hope that's whetted your appetite in the meantime.


return Module
```