---
layout: post
title: Using External Files
date: 2021-04-13T10:19:22.729Z
---

In my [previous post](/2021/scripting-sucks/), I talked about some of the... non-optimal aspects of scripting for Dual Universe.

The good news is that we can get around quite a few of them, _whilst we develop our scripts_, by putting our source code into external files.

Instead of typing Lua code directly into the Dual Universe script editor, we type it into one or more text files on disk, and just type a small script into the editor which pulls the contents of the files in and uses them.

So how do we achieve this?

## Require

Most languages have a mechanism for importing code from elsewhere. In C it's `#include`, in many languages it's `import`, but for Lua, the magic invocation is `require`.

Find yourself a keyboard controller, or a hoverseat or cockpit that you don't mind messing up.

Open up editor and navigate to the `start` handler for the `unit` element. Replace any existing code with this:

```lua
test = require('test')
test.doSomething()
```

Now activate your controller, and it will completely fail to do anything!

What it's _trying_ to do, however, is to load the contents of file called `test.lua`, evaluate it, and assign the result to a global variable called `test`. 

It is also assuming that `test` has a function called `doSomething`, which it tries to call.

So let's fix the errors by creating the file.

## Where To Put Your Code

When your script does `require('x')`, Lua looks for a file called `x.lua` in a specific folder in the game directory. Exactly where this is depends on where you've put the game. For me, it's something like `D:\Dual Universe\Game\data\lua\` - your mileage may vary.

Navigate your way to this folder, create a file called `test.lua`, and enter the following text:

```lua
```





