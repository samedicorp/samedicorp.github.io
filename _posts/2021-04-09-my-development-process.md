---
layout: post
title: My Development Process
date: 2021-04-09T14:55:27.398Z
categories: tools
---

I've been coding professionally for well over 30 years, and in that time I've grown fat and lazy - getting used to such luxuries as IDEs, liters, helpful warnings, visual debuggers, symbolic breakpoints, unit tests and source control.

Suffice to say that none of that niceness is available when developing DU code.

Oh no, we have to suffer for our art.

But hey - what's not to like about printf debugging?

## (Roughly) The Way It Works Out Of The Box

In Dual Universe, scripts are added to controllers, which are elements that form part of your construct (vehicle, building, etc). 

A controller can be linked to a limited number of other elements, including a few default hidden ones.

Each of these elements can be thought of as providing one or more services via an API, and emitting one or more events which you can respond to.

To program a controller, you can open the script editor on it.

This gives you a way to click on one of the linked elements, identify an event that you're interested in, and attach some lua code which will be run when the event occurs.

So far, so good.

It soon becomes apparent that there are some fairly major holes...

### Is This One Script, Or A Bunch Of Scripts?

Your "script"  is actually composed of a number of little Lua fragments - one for each event you handle. The editor lets you view and edit the code attached to a particular event, but only one event at a time.

Conceptually though, the script is one entity. 

Those little handlers make little sense in isolation. It's the combination of them together which flies your spaceship, or runs your factory, or whatever. At runtime, all of these handlers share the same environment and namespace - you can define a global variable or function in one handler, and use it in another.

What's more, there are two mechanisms which do actually support bundling up your script into a single entity. You can copy the script attached to a controller as a blob of JSON, and later paste that blob back onto another controller, and the game will do its best to set up all the same event handlers. There's also another similar mechanism (autoconf files) - more of them at a later date.

Most of us are used to being able to hop around our code, and group chunks of it together. Sure, we split things up into multiple source files, but it would be normal to do it at a fairly high level of granularity. If you have a bunch of functions to respond to different key presses, you might well expect to be able to put them into a single file so that you can flip around in it when browsing the code.

The basic script editing experience in DU doesn't support this. There are some workarounds, of which more, later.

### What 




### There Must Be A Way To...


There is syntax colouring, but no debugging, and no breakpoints.

You can log to the console, and that's your lot pretty much your lot.



