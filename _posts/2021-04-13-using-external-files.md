---
layout: post
title: Using External Files
date: 2021-04-13T10:19:22.729Z
---

In my [previous post](/2021/scripting-sucks/), I talked about some of the "non-optimal" aspects of scripting for Dual Universe :)

The good news is that we can get around quite a few of them, _whilst we develop our scripts_, by putting our source code into external files.

Instead of typing Lua code directly into the Dual Universe script editor, we put most of it into one or more text files on disk. We then just type a small script into the editor which pulls the contents of the files in and uses them.

So how do we achieve this?

## Require

Most languages have a mechanism for importing code from elsewhere. In C it's `#include`, in many languages it's `import`, but for Lua, the magic invocation is `require`.

Find yourself a keyboard controller, or a hoverseat or cockpit that you don't mind messing up.

Open up editor and navigate to the `start` handler for the `unit` element. Replace any existing code with this:

```lua
myLibrary = require('myUtilities')
myLibrary.doSomething()
```

Now activate your controller, and it will completely fail to do anything!

What this code is _trying_ to do, however, is to load lua from a file called `myUtilities.lua`, execute it, and assign the result to a global variable called `myLibrary`. 

We are assuming that the result of executing `myLibrary` is an object (I use the term loosely) which has a function called `doSomething` -- which we are then trying to call.

So let's fix the errors by creating the file and making it do just that.

## Where To Put Your Code

When your script does `require('x')`, Lua looks for a file called `x.lua` in a specific folder in the game directory. Exactly where this is depends on where you've put the game. For me, it's something like `D:\Dual Universe\Game\data\lua\` - your mileage may vary, but it will always be in the `lua` folder of the `data` folder of the `Game` folder.

Navigate your way to this folder, create a file called `myUtilities.lua` using your favourite text editor, and enter the following text:

```lua
local module = { }

function module.doSomething()
    system.print("Hello DU!")
end

return module
```

If you (and I) have typed the right things and put them in the right places, activating your controller should now result in the string "Hello DU!" being printed to the Lua channel in the chat window.

Progress!

## The Good News

We have a very basic proof-of-concept working now, but there are some caveats.

The good news is that using this approach, you can now edit the bulk of your code in [a proper IDE](https://code.visualstudio.com).

With the addition of a couple of extensions, you can now benefit from syntax checking. I'll speak more on which extensions I use and how I set up VS Code in a future post.

## The Bad News

The bad news is that we've lost some things too.

The biggest problem is that this script **only exists on your machine**.

Any script in DU runs on the machine of the user who is interacting with the construct that it is attached to.

If other people encounter a construct that your script is attached to, the `require` statement _won't work_, since the `myLibrary.lua` file only exists on your hard drive.

A secondary problem is that DU does not report errors that occur in external scripts. 

If you mess up the file badly enough that it doesn't parse, then DU will correctly report an error at the line where the `require()` call is, since evaluating the file itself will fail. 

However, more often than not an error will only reveal itself at runtime - because you're calling a function that's misspelt, or accessing a property that isn't defined, or doing something bad like dividing a number by zero. When running your script in these situations, DU will tell you that a Script Error occurred, but not where.

This is a massive pain in the arse! It's also annoying, because it should be fairly easy for NQ to fix.

To be absolutely clear here, it is also worth noting that being able to edit the code in an IDE _does not mean that we can debug it there_! We're just editing the text files - it's still DU that's running them, and it won't know about any breakpoints we set!

## The Good News About The Bad News

Working with local files is useful enough to be worth it during development, and fortunately there are some workarounds for the problems.

When it comes to debugging script errors, there are some tricks you can use to narrow down where exactly it is that you failed.

When it comes time to distribute your code to other DU users, you can _bundle it up_ so that the `require` statements are replaced by the content of the external files. This is a trade-off; it's now harder to work with, but other people can use it.

If you structure your external files correctly, the bundling process can pretty much just be a case of copying and pasting from the external source file into the script editor. As it's something you may find yourself having to do repeatedly however, it is worth _developing some tooling_ to automate the process.

Tune in to my future posts to hear more about how to structure your external code to make it easier to debugging and bundle. I'll also cover the tooling I've developed for myself, and hopefully share it for others to use.