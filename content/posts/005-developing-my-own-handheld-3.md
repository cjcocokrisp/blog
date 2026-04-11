+++
title = "[005] Developing My Own Gaming Handheld Part 3: Display, WiFi, Bluetooth, Oh My!"
date = "2026-04-11T16:00:00-05:00"
author = "Christopher Coco"
cover = "/imgs/005/setup.webp"
coverCaption = ""
keywords = ["Projects", "Youyeetoo X1", "Steam", "Emulation", "Tech", "Electronics"]
description = "A little bit of a hardware side quest to make testing out the software easier."
readingTime = true
+++

{{< handheld-toc >}}

It has been almost a month since my last article about this project. With Easter and skiing a
couple of weekends I have not had the most time to work on it. I began testing some of the software
I want to use on the device like Gamescope until I started getting annoyed with having to move an
extra monitor over to go and test the device along with unplugging my Switch's ethernet cable to use.
This made me realize that I probably should figure out wireless WiFi and Bluetooth along with a 
display before I continue the software testing. So that is exactly what I did. This article won't be
as long or that technical but it will discuss the hardware that I bought so far.

## Wireless WiFi + Bluetooth

Getting wireless WiFi and Bluetooth on the device was incredibly easy. All I needed to get was an
M.2 Key. The one that I got was an [Intel AX210](https://a.co/d/0gcSIu4v). I also had to get
antennas for it. So [these](https://a.co/d/043VmAlf) were the ones that I got. 

Installing it was really easy, all you needed to do was remove the screw that was there. Then,
put the card in and rescrew the screw back in to keep the card in place. Placing the antennas on
was a tad bit annoying due to the connectors just being small. Once I booted up the device it just
worked as well nothing needed to be configured after the install.


![WiFi card installed on the back of the Youyeetoo X1](/imgs/005/wifiinstall.webp)

The antennas have adhesive on the back of them so it will be really easy to install them into the
case once I create it.

## Display

The display was quite the struggle. I got one that for some reason just did not work and then ended up
having to get another one. The first one that I got was [this](https://a.co/d/0h7eG8yS). It was a 5 inch
1280 x 720 display with touch screen. 

![The first display that I got](/imgs/005/displaybad.webp)

I already set Gamescope up on the board so the device boots into Steam
Big Picture mode. It would boot into that fine and then when I would switch to go to KDE Plasma it would 
flash no signal to a black screen over and over. I tried some messing around with display settings and that
was no help. I then tried X11 because right now Wayland was being used and that worked fine. Sticking with
X11 is not an option because Gamescope is a Wayland Compositor. I tried booting up games cause it did at
least get to Gamescope and they would just crash not even a second after trying to load.

I then thought maybe it was the power. There were two ways to power the display, 5v USB C or 12v DC power. 
I got a 12v DC adapter for the display and still nothing. It only took micro HDMI and it came with an 
adapter to regular HDMI so I tried another one that I had maybe that one was bad. When I tried the 
other one I have it gave me a OUT OF RANGE error. After that I tried some more things to troubleshoot 
and that was no help at all so I gave up and decided to just get a different display...

![Insides of the case for the first display](/imgs/005/baddisplaycase.webp)

This display was also in a case and there were a lot of components inside of it which was not really a suprise.
It also had audio built into this. I think putting all of these parts along with the SBC would have been a
really hard task so it's probably good that I went with another display. I also think text was going to be way
too tiny on that display too. 720p on a 5 inch screen was already bad.

The [second display](https://a.co/d/067MLk29) is 1024x600 still with touchscreen just no audio on this one.

![The second display that I got](/imgs/005/gooddisplay.jpg)

This one worked perfectly when I plugged it in and tried to do everything so not complaints from this one.
This one will be easier to install into the case as well just get a ribbon like HDMI cable and it will be all
set.

![The back of the display that works](/imgs/005/backofgooddisplay.jpg)

## Conclusion

Now that I have display, WiFi, and bluetooth on the device it will make testing a lot easier. This article was
pretty short the next one should be longer. The next two steps for this project will be finishing up the
software testing and then I'm going to start learning the electronics for building the controller. For software,
I just need to find an emulator frontend and see how to set it up. I'm thinking Emulation Station due to me
liking the UI for that. I want to do the controller before the bootc image so I tell if there are any
dependencies that I need for it. My goal is to make it just plug in via USB and work but I think getting that
out of the way no or at least having a prototype will be good. Anyway that's all for this article and I will
see you all in the next one!