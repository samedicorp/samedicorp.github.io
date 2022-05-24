---
layout: post
title: Keeping Things Organised
date: 2021-05-18T10:14:50.992Z
---
In my last post, I discussed how to place your Lua code into external files during development, and why it can be helpful.

In this post I want to follow that up with some suggestions about how exactly you might want to organise these files.

## Organising Your Disks

To keep things simple, my first example created a file called `myUtilities.lua` in the root `lua` folder of the game, and used it by doing `require('myUtilities')`.

In the real world, I'd suggest making a folder and putting your lua files in there.

In theory the name of the folder can be anything you like, but I would suggest that you pick the name of your Dual Universe login.

You then import the script with `require('foldername.scriptname')`.

There are (at least) two reasons why this is a better idea.

### Source Control

Most importantly, it lets you put your scripts under source control. You can commit your folder to  your source control tool of choice, document your changes, roll them back if necessary, and make sure that they are always backed up. 

I will dedicate a future post to talking about how I use Git and Github for my scripts, but for now let me just say that you _really, really_ ought to do this. The game sometimes wipes out the contents of the `lua` folder when it does an update. If you don't have your work backed up, you will lose it! 

More generally, anyone serious about any sort of development should be using source control anyway -- and that goes double if you're part of a team working on something together.

### Namespaces

A second, slightly related reason to put everything in a folder is that it lets you share your scripts with others, and take scripts from other people, without them clashing.

If your scripts are in a folder with your name, mine are in a folder with my name, then they can safely co-exist. If you have a file called `utilities.lua` and I do too, then I can do `require('samedi.utilities')` and know that I'll be getting my one, or `require('yourname.utilities)` and get yours.

To be clear, I'm not suggesting that you actually share scripts this way for general consumption. There are better ways to share scripts with normal users, and it's probably not a good idea to force someone to install external files to use your stuff.

However, if someone has developed some Lua code that you want to make use of, then it's good to be able to set things up during development so that you can update their code at any point. Hopefully their code is also in source control, and you can fetch it to a folder with their name and pull new versions at any time. Even if that's not the case and you are having to fetch it manually, putting it in a folder of its own makes sure that it it doesn't get muddled up with yours.

### Libraries

If you start developing complex scripts you may want to split things across multiple files, or develop libraries of related scripts.

The `require` syntax generalises to subfolders. If you do `require('samedi.utilities.strings')`, it will look for  `lua/samedi/utilities/strings.lua`.

## Conclusion

In the scripts that I've made for DU, I have made extensive use of this approach during development. 

I split the code up into multiple files. Some contain general utilities, other focus on a specific area of functionality like braking, or navigation.

This way, I can pull in the bits that I need for any given task.

All of this should come naturally if you've done any coding before; it's good to know that we don't have to completely abandon modular code and re-use just because we're working in DU.

Eventually, of course, if you want to distribute your script to other people, you will need to take all of this code out of your source files and package it up into a single in-game controller.

I'll explore the best ways to tackle that in a future post. I'm most of the way towards a completely automated solution, and there are some other ones out there. 

If you are careful about how you structure your individual files though, and don't need to package things up very frequently, simply copying & pasting the code from them may be enough.
