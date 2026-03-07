+++
title = "[002] Developing My Own Gaming Handheld Part 1: The Plan is Simple?"
date = "2026-03-07T01:00:00-05:00"
author = "Christopher Coco"
keywords = ["Projects", "Gaming", "Handhelds", "Tech", "Electronics"]
description = "First part in a series of posts where I discuss a side project I'm starting up: building my own gaming handheld!"
showFullContent = false
readingTime = true
cover = "/imgs/002/my-mockup.png"
coverCaption = "Mockup of Handheld"
+++

One project that I've always had in the back of my mind is creating my own gaming
handheld. There's been multiple versions of this in my head varying in complexity.
There was a point where I thought if I ever did this project I would want to write
my own OS, emulators, and all that fun stuff. That was back when I was younger so
you know a lot more ambitious. At some point I do want to write an emulator for an
early Nintendo console. The list of things to do keeps getting bigger...

## The Problem

Last December, I graduated from university and I'm now working full time. The company I'm 
working for has two offices, one I can get to easily by driving and the other I need
to take the subway to get to. I currently do not go to the office where I need to take
the subway to that often because you need to walk after taking it and the weather is not
the greatest right now so I would rather not walk twenty minutes in the freezing cold.
I do want to start going there more often though because once the weather is nicer there's
more to do around it. While on the subway, I want to play games instead of just sitting there
doom scrolling on my phone. For handhelds that I currently own, I have my 3DS, DS Lite, Switch,
and Steam Deck. All of those are great options, however each has a flaw:

- My 3DS is old, the battery life is pretty bad I tried replacing the battery and its still bad
so I'm not really sure. It is modded so I do have a lot of access to games on there.

- The DS Lite, has a pretty limiting library even with a flash cart.

- My Switch is on its last legs, I got it in 2017 two months after launch and that think has survived
so many hours of using it, multiple trips, going to Smash events, and so much more that it
honestly deserves a purple heart medal. 

- Those three also have the fatal flaw of not being able to play my Steam library.

- Steam Deck sounds like the silver bullet here. It can play Steam games, emulators
(it can even do Switch emulation and my Switch is modded so I can legally dump the games
and not risk getting a virus for games I already own), and pretty much play anything
as long as there's no Kernel level anti-cheat. HOWEVER, I believe that it is too big for
this sort of commute. I do need to transfer lines on the subway so you'd have to zip it 
up and put it in your bag. Not being able to just throw it in your pocket would hurt a lot.

So this made me think, I should create my own gaming handheld. One of the things I wanted
to learn post uni was electronics for little tinkering projects and I think this was the
perfect way to do it.

## The Solution

So what do I want this console to look like and actually do. Let's talk at a high level.
First and most importantly, I want it to be pocketable or at least smaller then the Steam Deck. 
So the vision I have in mind is like the Playstation Vita. Below is a mock up that I had Chat GPT
make. I kind of like how that looks so I'm hoping that it can come out similar to like that. As
you can tell from the mockup on the cover, my art skills are not the greatest... so AI 
slop will need to do for now. Below is a comparison with the Steam Deck. I don't think it 
will be that small but we'll see.

![ChatGPT Mockup compared to Steam Deck](/imgs/002/chatgpt-mockup.png)

For games, I want it to be able to emulate a decent amount of consoles. Main emulation
games I can think I would want to play is like GBA for Pokémon but I have been thinking about
playing some more Zelda recently so like Gamecube to Wii would be nice. I also want it to be able
to play some lower end games from Steam.

Other hardware stuff, I would want a full set of buttons that an Xbox controller would have, speakers
for audio, USB C charging, a power light, potentially ability to mirror display to TV with HDMI for
easy co-op games on the go. So that's what I would say would be the high level idea of what I have.
How to actually accomplish the hardware stuff that's what I'm going to need to learn but because I
know I decent chunk of software stuff I have put some thought into how I'm going to do that.

So for starters, I want it to be run through Linux. It's just less resource intensive which is good
for a device like this. Linux gaming with Proton has just come such a long way so it's really a no
brainer to use it. My distro of choice for this is going to be Fedora, specifically using an
immutable spin like Bazzite or just coming up with my own universal blue image. I use immutable
Fedora with bootc on my homelab machines and its really nice. It will also keep the packages up to
date without me needing to manually do it as long as I make a CI workflow to build the container image
at least once a day. Another cool thing I learned while researching, is the software that the
Steam Deck uses to go right to big picture mode is actually open source and you can use it on your
device. It's called [Gamescope](https://github.com/ValveSoftware/gamescope). So I do plan to use this
to make it a lot nicer.

If you don't know what bootc is, it is building and managing Linux using standard OCI container
images. I would highly recommend looking into it. It's very neat technology.

On my steam deck I use Decky and CSS loader to make the UI look a lot nicer (see image below) 
and being able to add non Steam apps to big picture is really nice too so I can utilize all of
that to basically get a really similar Steam Deck experience.

![My layout with Decky's CSSLoader plugin](/imgs/002/steam-cssloader.jpg)

I need to also find a emulation frontend that I like. Right now on Steam Deck, I use EmuDeck
which uses Emulation Station and I like that one but I want to explore that and see. So the
point I'm getting to here is I want to make a Fedora bootc image that will automatically set all
of this up for me including installing Decky (with plugins), the emulation frontend, putting it
on Steam as a non Steam app, setting up Gamescope, and more. This is probably more then overkill
for my setup but I think it will be good for if this thing ever breaks or I decide to make a new
model I can easily have the software ready to go. Also I wanted to document this as much as possible
so people can replicate the set up and make their own if they really wanted to!

## Am I In Over My Head?

The big thing I'm asking myself here is am I in over my head with all this? Is this too ambitious
for a first time electronics project? The answer, probably. From the research I've did into actually
doing the hardware stuff, it seems like it won't be too bad. I'm mainly just worried about the power
related stuff and then also making the case for it which I want to get a 3D printer for and model
myself. We'll see how that goes. 

For things that I have started, I got a single board computer to use. Proton seems to only work with
x86 right now so I found an SBC that seems pretty strong for its size. I just got it yesterday so
I'm going to start benchmarking it for what I want to do. It was spoiled above but its the
Youyeetoo X1.

I broke this project down into a few parts. Part 1 being the software stuff. Finding an SBC to fit my
needs, making the bootc image and all that fun stuff. Part 2 being the hardware related stuff. Making
the controller, doing the speakers, and all the other stuff. Then Part 3 being modeling the case and
assembly. Even though I feel like I'm in over my head, I do feel like I broke this down pretty well
and as long as I take my time and research everything throughly I should be able to do this.

## Conclusion

So that concludes my yap about my plans for this project. I hope this makes sense and my idea comes
across I just kinda through everything I wrote down and have been thinking about into this article.
The plan might seem simple but we'll see if I can figure this out. Stay tuned for the next article in
this series which will most likely be about the SBC benchmarking. See you all in the next one. 

