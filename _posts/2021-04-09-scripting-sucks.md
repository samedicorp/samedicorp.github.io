---
layout: post
title: Scripting Sucks
date: 2021-04-09T14:55:27.398Z
categories: tools
---

I've been coding professionally for 30+ years (oh god I'm old), and in that time I've grown fat and lazy...

I have become accustomed to such luxuries as IDEs, linters, helpful warnings, visual debuggers, symbolic breakpoints, unit tests and source control.

Suffice to say that none of that niceness is available when developing DU code.

Oh no, we have to suffer for our art!

But hey - what's not to like about printf debugging?

In this post, I'm going to take a brief overview of what the basic scripting experience is like, at face value.

This is, of necesssity, going to sound a bit negative. 

To be fair, it _is_ a bit negative. 

I should say that I've worked as a senior coder on a big, popular game, so I do see where NQ are coming from. I understand that there will have been a very large number of competing priorities that came above fancy features for scripters. Nonetheless, there's no getting away from the fact that the scripting tools in DU are pretty bare bones. They are no worse than many other games, and better than some - compared to Skyrim modding, writing DU scripts is a cakewalk. However, **if you believe as I do that scripting in DU is a force-multiplier which has the power to turn a good game into a really great game**, then there's no excuse for the lack of love shown to the scripting environment.

DU can and should fix this stuff.

The good news though is that in the meantime, there are workarounds for quite a few things. 

In future posts on this blog I intend to go into what I have done / am doing to make my own scripting life a little less horrible. I also intend to share my tools and techniques too, where I can.

I expect that a lot of what I've done will turn out to be not as good as someone else's solution. That's fine by me, and if this blog helps to bring those better solutions to light, then that's a job well done as far as I'm concerned.

Anyhoo, if I try to include all of my solutions here, I'll be writing forever. 

So to start with, lets look at one or two of the problems.

## (Roughly) The Way It Works Out Of The Box

This is not a tutorial and I'm not going to describe the entire scripting process, but here's a brief overview.

In Dual Universe, scripts are added to controllers, which are elements that form part of your construct (vehicle, building, etc). 

A controller can be linked to a limited number of other elements, including a few default hidden ones.

Each of these elements can be thought of as providing one or more services via an API, and emitting one or more events which you can respond to.

To program a controller, you can open the script editor on it.

This gives you a way to click on one of the linked elements, identify an event that you're interested in, and attach some lua code which will be run when the event occurs.

So far, so good.

It soon becomes apparent that there are some fairly major holes...

### Is This One Script, Or A Bunch Of Scripts?

As mentioned above, your "script" is actually composed of a number of little Lua fragments - one for each event you handle. The editor lets you view and edit the code attached to a particular event, but only one event at a time.

Conceptually though, the script is one entity. 

Those handlers make little sense in isolation. It's the combination of them together which flies your spaceship, or runs your factory, or whatever. At runtime, all of these handlers share the same environment and namespace - you can define a global variable or function in one handler, and use it in another.

What's more, there are two mechanisms which do actually support bundling up your script into a single entity. You can copy the script attached to a controller as a blob of JSON, and later paste that blob back onto another controller, and the game will do its best to set up all the same event handlers. There's also another similar mechanism (autoconf files) - more of them at a later date.

Most of us are used to being able to hop around our code, and group chunks of it together. Sure, we split things up into multiple source files, but it would be normal to do it at a fairly high level of granularity. If you have a bunch of functions to respond to different key presses, you might well expect to be able to put them into a single file so that you can flip around in it when browsing the code.

The basic script editing experience in DU doesn't support this. There are some workarounds, of which more, later.

### This Code Makes No Sense...

To err is human, but to really fuck up, you need a compu... no, actually you need a human for that too.

We all make mistakes with our code. We run it, and things fall over, or don't do anything, or silently overwrite vital files causing major economic crises.

The most fundamental mistakes result in code that doesn't even run. Most programming environments do their best to warn you about this before you even run the code. They parse what you've written as you write it, and highlight things that don't make sense. Incidentally they also help you out by offering to auto-complete what you're typing with code that does make sense.

In Dual Universe, you're pretty much on your own, on this front. There is syntax colouring, but that's your lot. No auto-complete. No linting or attempt to tell you that you've written nonsense.

Oh well...

### I'm Sorry Dave, I'm Afraid I Can't Do That

The way we find out about our scripting mistakes in Dual Universe is by activating the controller (running the code).

If it goes wrong, you get told there's a script error. At which point you can open up the editor again (you had to close it to run the code), and if you're lucky, you'll get told which line of which event hander had a problem.

The script is dead at this point. You have no state. No variable values.

So you fiddle a bit, and try again.

It would be lovely if you could set a breakpoint, pause your code, and see what's going on - but you can't. 

This is not a limitation in Lua, by the way (which is good news - more on that in a while). It's just a limitation in the integration of Lua with Dual Universe.

### Print, And Indeed, Eff.

So what's left?

Printf-debugging, of course. Much beloved of gnarly old greybeards everywhere. I may in fact resemble that description, but we'll move swiftly on.

So basically to find out what's going on, you litter your code with judicious print statements. 

The syntax is actually `system.print()`, and no, it doesn't support printf formatting.

### In Summary

I want to keep these blog posts reasonably brief, so I'll stop there.

To sum up the out-of-box experience: 

- Your code is split into little bits, that you can't get a good overview of. 
- You can't navigate or analyse your code in any meaningful way.
- You can't set breakpoints, or inspect variables at runtime.
- You have to close the editor to test your code, and the first time you know about a problem is when it doesn't do what it's supposed to - probably by silently crashing.
- Your only clue to what is going on is to log stuff to the console. Which by the way doubles up as an (extraordinarily clumsy and annoying) chat window that you can't move or resize.

Are we having fun yet?

In future posts, I will attempt to lay out some of my approaches to fixing these problems.

As a teaser, here are some of them in brief:

- a small set of utility functions (for things like formatted printing, table printing, etc)
- using `require` to pull them in from disk during development, so that they only have to be defined once
- making almost all event handlers in a script just one-line calls to controller objects
- using `require` to pull in that controller object from disk in the start handler
- use [an actual IDE](https://code.visualstudio.com) to browse and edit the code during development
- utilities which can unpack the JSON representation of a script into source files as a way of getting code out
- utilities which can re-pack the source code into JSON
- utilities which pack a development version of a script (that uses `require`) into a compact form (that doesn't) for distribution
- a simulation environment which can run scripts externally in VS Code, allowing them to be breakpointed, inspected, etc
- a modular architecture which allows the creation of plug-and-play components which just handle one aspect of control, or display one kind of instrument
- a reusable set of the above plug-ins for various different purposes
- all of the above is kept under source control using git/github at all times

None of these are particularly original ideas, and I know for a fact that other people are doing some or all of them.

The community can (and should) share this stuff of course. Unfortunately there are some major disincentives for doing so. In a game that includes a large element of competition, being able to run with your script development whilst other people can only walk is a hard thing to give away. 

If we could all agree to share some of the basics though, everyone would benefit. 

Everything I've done is in private Github repos, and I intend to open most of it up. The main reason for not doing so now is simply that it would be too hard for others to use without more support than I can probably give.

This blog is part of my way of tackling that, by trying to slowly document what I've created, and release bits of it as I do.

Incidentally, a lot of this infrastructure is stuff that Dual Universe should be providing out of the box. Even if they don't make it themselves, I would really like to see them support a community effort in this direction.

I shan't be holding my breath, however...




