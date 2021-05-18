---
layout: post
title: Module Structure
date: 2021-05-18T10:28:55.250Z
published: false
---

In previous posts, I've talked about the advantages to be gained by keeping your script code on disk during development.

## One Big File

The simplest approach is just to make one file on disk for your script, and `require` it in response to the `unit.start` event.

Any code that you place in this file will be interpreted when the `require` statement is executed, so if you define global functions or variables, they will be available for use in your other scripts once the `require` statement has completed.

This works fine, as far as it goes, but one of the main advantages of putting your code into external files is the ability to share code between scripts - and you defeat that completely if all the code for a script lives in a single file.

So I prefer to go for a more modular approach.

## Splitting Things Up

Most scripts share some common functionality. 

You usually perform some setup on `unit.start`, and some cleanup on `unit.stop`. 

Flight scripts pretty much always perform some work on `system.update` and `system.flush`.

If you're displaying any sort of user interface, you will probably register one or more timers, and perform some work when you get the `unit.tick` event for them.

So the approach that I've adopted is to create a core controller script which handles these common events, and also defines a number of utility functions that pretty much any other script will need.

This controller then supports registering one or more _modules_ - each of which lives in its own file. These do the actual work - flying the ship, reporting on the factory, drawing things on the screen.

Splitting things up in this way allows us to share the essentials between all scripts, and to share specific functionality between any scripts that need it, but avoid cluttering the core up by stuffing it full of stuff that most scripts won't need.

Whilst in theory it would be possible to do all of the above and still just use global functions and values, it could get messy. What if two modules accidentally use the same function name, and you want to use both modules? 

It is cleaner to treat the controller and each of the modules as _objects_. When we want to access the functionality of a module, we do it by calling a function _on the module_, rather than just a global function. 

This approach won't come as a surprise to most people with coding experience, but if coming from a background with something like C++ or C#, you may be surprised at just how vague a concept "object" actually is in the Lua context.

This is a [deep rabbit hole](https://www.lua.org/pil/16.html) that we could spend a long time down. 

I'm going to skip all of that, and just say that in Lua, object-orientation is sort of something you implement yourself, and there are lots of choices you can make when you do it. For my use case, I've pretty much gone for the approach of _the simplest thing that works_. 

Each of my lua files can be thought of as defining a _class_ which is returned by `require` when you import the module. Calling `new()` on this class results in a new instance of the class. 

Although it would be trivial to add inheritance to this picture, in pretty much all cases I've encountered so far it has been unnecessary as each module is quite standalone. Furthermore, we typically only instantiate each module once, so although I go to the trouble of making it possible to call `new()` and create multiple objects of each class, really the modules and controllers can be thought of as _singletons_.

## Object Orientation