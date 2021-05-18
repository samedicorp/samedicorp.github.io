---
layout: post
title: Module Structure
date: 2021-05-18T10:28:55.250Z
---

In previous posts, I've talked about the advantages to be gained by [keeping your script code on disk](https://samedicorp.github.io/2021/structuring-external-files/) during development.

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

## Modular Code

Whilst in theory it would be possible to do all of the above and still just use global functions and values, it could get messy. What if two modules accidentally use the same function name, and you want to use both modules?

It is cleaner to treat your controllers and modules as separate _classes_. When we want to access the functionality of a module, we create an object which is an _instance_ of the module's class, and we call a method (function) on that, rather than just a global function. 

This approach won't come as a surprise to most people with coding experience, but if coming from a background with something like C++ or C#, you may be surprised at just how vague a concept things like "class" and "object" actually are in the Lua context.

This is a [deep rabbit hole](https://www.lua.org/pil/16.html) that we could spend a long time down. 

I'm going to skip all of that, and just say that in Lua, object-orientation is sort of something you implement yourself, and there are lots of choices you can make when you do it. For my use case, I've pretty much gone for the approach of _the simplest thing that works_. 

Each of my lua files can be thought of as defining a _class_ which is returned by `require` when you import the module. Calling `new()` on this class results in a new instance of the class. 

Although it would be trivial to add inheritance to this picture, in all cases I've encountered so far it has been unnecessary as each module is quite standalone, and really shares no behaviour with other modules.

Furthermore, we typically only instantiate each module once, so although I do go to the trouble of making it possible to call `new()` and create multiple objects of each class, really the modules and controllers can be thought of as _singletons_.

This isn't to say that you won't also find it useful to make helper classes which really do get instantiated multiple times; just that it's not essential.

## An Object Oriented Template For A Module

Here's the basic pattern I have adopted for each `.lua` file.

Let's say that I have a module called "Foo", defined in a file `foo.lua`, which is inside my `samedi` folder in the game's `lua` folder:


```lua

local FooModule = { class = "FooModule" }

function FooModule.new()
    local instance = {}
    setmetatable(instance, { __index = FooModule })
    return instance
end

function FooModule:bar()
    -- do something
end

return FooModule

```

The way I would use this in my main `unit.start` event handler is as follows:

```lua

-- import the Foo class and make an instance
local FooModule = require('samedi.foo')
foo = FooModule.new()

-- use it
foo.bar()
```

I'm declaring `FooModule` as local here, because I'm only going to make one instance, and once I've done that I don't need to access it again.

On the other hand I've made the `foo` instance global, so that I can access and call it from any handler that the script defines.

For example, maybe my foo model is actually supposed to be handling some code which controls the landing gear. 

I load the module in the `unit.start` handler, but I need to call it in the `system` handlers which respond to the keyboard events for whatever key is mapped to the `gearDown` event. By making it a global, in the `system.actionStart(gearDown)` handler, I can call `foo.gearDownStart()`, and in the `system.actionStop(gearDown)` handler I can call `foo.gearDownStop()`.

## Why Are We Doing This Again?

As an aside, it might be worth remembering what the point of all of this is.

There are a few things we want to achieve:

- editing with a real IDE during development
- sharing common code between scripts
- easily combining everything back into a single script for distribution
- minimal dependencies with the game

By putting the code into one or more external lua files, we achieve the first objective.

By splitting common functionality into separate lua files, we achieve the second. By making each of these files define a class, we ensure that they don't clash with each other, regardless of which ones we use together in a particular script.

The third objective is crucial, and we can't lose sight of it (unless we're only building scripts for ourselves).

By defining the code the way we do inside each file, we also make it easy to reassemble everything into a single file for distribution. In our packaged-up version of the script, we can replace:

```lua
local FooModule = require('samedi.foo')
```

with:

```lua
local FooModule = (function()
  -- paste in the contents of `foo.lua` here
end)()
```

This works really nicely. 

The code for `FooModule` is still encapsulated cleanly, can't clash with anything else, and can be used in exactly the same way by doing `FooModule.new()`.

Furthermore, it's pretty easy to see how this packing-up-for-distribution process lends itself to being automated. It's quite easy to write something that looks for `require('xxx')` and replaces it with `(function() ... ` and the content of `xxx.lua`. More on that in another post later...

The fourth objective sounds a bit weird - we're writing the script for the game, why would we want to avoid dependencies with it? The answer is that it is potentially very useful ability to be able to import and test modules directly in your IDE (or from the command line). This is a complex topic which I'll touch on in a later post, and it's not massively relevant here except to say in passing that it's something we don't want to complicate if we can avoid doing so.

## Conclusion

In this post I've gone through the basic layout I use for my lua files on-disk.

There are lots of other variations possible, but this layout works for me. It keeps the code modular during development, but the code is easy to re-assemble into a single script when it is time to distribute it.

Other layouts are available. More sophisticated object orientation is available (take a look at `pl/class.lua` in the game folder, for one example of this). However, for our purposes right now this does enough and keeps dependencies minimal.

In later posts I'll start fleshing out the controller/modules architecture that I've built on top of this basic file organisation pattern.