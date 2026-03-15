+++
title = "[003] Developing My Own Gaming Handheld Part 2: SBC Benchmarking"
date = "2026-03-15T13:00:00-05:00"
author = "Christopher Coco"
cover = "/imgs/003/setup.webp"
coverCaption = "Setup used while testing"
keywords = ["Projects", "Youyeetoo X1", "Steam", "Emulation", "Tech", "Electronics"]
description = "Discussion of some benchmarks I ran on the Youyeetoo X1 SBC to see what games it could play."
readingTime = true
+++

{{< handheld-toc >}}

With the plans for my homebrew handheld laid out I started to get to work on
the actual implementation of the project. The first and foremost thing that I
had to do was find a Single Board Computer (SBC) that would work for this device.
As mentioned in the previous article, something that I wanted to use was Gamescope.
This is to give the device a Steam Deck like experience. From my little bit of research,
it seems that it was recommended to use Gamescope on a x86 device so I went to go find
an SBC with decent specs that also wasn't too big to use for the device.

For the SBC's specs besides having an x86 processor, I decided I wanted to get 8 GB of RAM
and have some sort of integrated graphics on the chip as well. My laptop (Samsung Galaxy Book 2)
has that sort of set up and I've had no issues running games that I wanted to play to kill some
time. When researching boards I came across a few that seemed alright but would not have integrated
graphics on the CPU. Very quickly came across the [Youyeetoo X1](https://www.youyeetoo.com/products/youyeetoo-x1-x86-single-board-computer?VariantsId=13094).
This board seemed to be a really good fit for what I was trying to do based on reviews I was reading.
I was able to find it on Amazon for $150 for the 8GB of RAM and 128 GB of eMMc which was nice (At
the time of writing this the price went up to $227.12 so I guess I made out here). So I
ordered it and it came in about after a week after ordering.

## The Youyeetoo X1

The Youyeetoo X1 was really advertised for its ability to run Windows well.
This could be considered a good thing because if it can handle the bloat then it
for sure would be able to really run Linux nicely.

The board itself is pretty decent size being 115 mm x 75 mm x 20mm. It has 4 USB ports,
HDMI, ethernet, slots for a SATA, NVME, and Micro SD card, an audio jack, a ton of GPIO.
It also comes with a heat sink so I found that as a plus. A lot of other boards I saw did not have
one so saves me from having to find one. So it is pretty well equipped for most small projects 
you would be trying to do. A picture of the board can be seen below.

![Youyeetoo X1 SBC](/imgs/003/youyeetoox1.jpg)

For the actual specs of the processor it has an Intel 11th N5105 with 4 cores and a clock frequency
up to 2.9 GHz. As I mentioned before I got the 8 GB of RAM option. I honestly would
recommend this board for someone who is trying to start a homelab. Probably would just get the
higher GB of RAM option. It seems to go up to 16 GB. The board having 128 GB of eMMc was also
nice because I did not need to buy another drive or SD card for it. I do have a spare 256 NVME drive
laying around that used to be in my laptop before I upgraded it to 1 TB. So if I do need more storage at
some point I can always install that. Below is a screenshot of a `fastfetch` run after everything was
tested.

![Fastfetch on the Board](/imgs/003/fastfetch.png)

Overall, for the price the device is solid.

## Device Setup

Getting the device set up was incredibly easy. All I had to do was installed Linux like normally,
didn't have to do anything fancy just plug in my Ventoy USB and select the OS I wanted to install.
I decided to go with Fedora for this testing because I plan to use a bootc managed system with a
Fedora base. An image can be seen below of the setup I had during the install (it was not comfortable).
It was to the right of my desk on the floor... I did make it more comfortable as seen in the cover image
with a smaller spare monitor I have instead of a small TV. It was also at this moment I realized that the
device did not have on-board WiFi and Bluetooth. From reading the description I thought it did but it has
a slot for a card of one. I still need to get one at the time of writing this but I started doing the hardware stuff.

![Setup During Install](/imgs/003/setup-install.webp)

I honestly did not have much to install on here. First thing I did on the system was install Steam and get
signed into that to start downloading all the games I wanted to benchmark. I also had to find a software to
gather performance data with as well. After installing Steam I did play one Balatro run and it went really
well it was orange stake gold deck and I had a banger straights build.

![Balatro run after install](/imgs/003/balatro-win.jpg)

For a program to gather metrics, I found out about [MangoHud](https://github.com/flightlessmango/MangoHud). This
is a really useful overlay that lets you monitor all sorts of data while a Vulkan or OpenGL program is running.
It can collect all sorts of data from FPS, to load, temperatures, and even battery if you have one. I will talk
more about the metrics I paid attention to in the benchmarking section of this post. 

![MangoHud Example](/imgs/003/mangohud-example.jpg)

Getting MangoHud to work on both Steam games and the emulators was really easy. For Steam, all you had to do
was go to the properties of the game then, change the launch command to be `mangohud %command%`. For the emulators,
I mainly used [RetroArch](https://www.retroarch.com/) (I will talk more about which emulators were used in the section
about it in the benchmarking). To get it to work with that all you have to do was run `mangohud retroarch` in your terminal.
I did have a problem where the downloader for the cores (basically the emulators themselves inside RetroArch) not showing up
by default so I had to figure out how to get that working. All I had to do was go to the UI settings and enable a few options
under UI elements. For the emulators that weren't on RetroArch it was just do `mangohud [program]` so it really was not that hard.
MangoHud also exports all the data to a csv file so perfect for parsing with Python to make some nice graphs which will show up
later.

## Benchmarking

Now for the actual benchmarking, my main goal here was to actually get some visuals on how the games ran on this board.
When picking out Steam games and systems to test for emulation, I picked things that I would see myself potentially playing
on here.

The data that I concerned myself with was, FPS, frametime, CPU load, CPU temperature, GPU load, total RAM used, and RAM
used by the game's process. MangoHud could collect all of these metrics and as mentioned, nicely output it to a csv file.

For visualization, I have created some plots with all the metrics on there. I did do some data processing on the data as well
because plotting it raw looked very noisy. I do not know much about data science so please forgive me if my techniques are wrong.
The two techniques I used to make there be more of a trend visual was smoothing then downsampling. From my understanding, smoothing
is used to get rid of spikes and remove the noise that may be there. I used a rolling window mean for this. Downsampling is
reducing the data to make trends be more noticeable. For downsampling, I did a mean over 10 seconds. The polling rate from MangoHud
was about 100 readings per second. On each chart I also plotted the raw data and smoothed data before downsampling in grey. The
stuff that I picked for the postprocessing I feel visually fits with how the games felt to play.

The below section will display all the metrics I mentioned above for each game I tried. There also will be a short little blurb
about how it felt to play and anything I picked up on.

The raw csv files can be download from the below links along with the Jupyter notebook I used to create the charts.

- [`Balatro.csv`](/files/003/Balatro.csv)
- [`Stardew_Valley.csv`](/files/003/Stardew_Valley.csv)
- [`puyopuyotetris.csv`](/files/003/puyopuyotetris.csv)
- [`Mewgenics_actualgameplay.csv`](/files/003/Mewgenics_actualgameplay.csv)
- [`Mewgenics_runprep.csv`](/files/003/Mewgenics_runprep.csv)
- [`P5R_attempt1.csv`](/files/003/P5R_attempt1.csv)
- [`P5R_attempt2.csv`](/files/003/P5R_attempt2.csv)
- [`P3R.csv`](/files/003/P3R.csv)
- [`DevilMayCry5.csv`](/files/003/DevilMayCry5.csv)
- [`pokemon-crystal.csv`](/files/003/pokemon-crystal.csv)
- [`marioadvance4.csv`](/files/003/marioadvance4.csv)
- [`supermarioworld.csv`](/files/003/supermarioworld.csv)
- [`mario64.csv`](/files/003/mario64.csv)
- [`zelda-windwaker.csv`](/files/003/zelda-windwaker.csv)
- [`mariokartwii.csv`](/files/003/mariokartwii.csv)
- [`fe-awakening.csv`](/files/003/fe-awakening.csv)
- [`mgs3.csv`](/files/003/mgs3.csv)
- [`monkeyball_deluxe.csv`](/files/003/monkeyball_deluxe.csv)
- [`sbc_benchmarking.ipynb`](/files/003/sbc_benchmarking.ipynb)

#### Steam Games

For steam games I would want to play on this device it would be roguelikes and whatever
RPG/Singleplayer game I'm playing at the moment. So that is mainly what I tested. I also
set Steam to offline mode during this to make sure these games did work while offline.

**Slay the Spire II**

This was the first game that I went to try on the device because it released a couple days
before starting this. The first Slay the Spire is one of my favorite games of all time so I
was really anticipating the sequel. The game ran fine in the menus however whenever I would
start a combat it would just freeze when cards were drawn. I tried Proton GE as well and still
no luck. The game is currently in early access so this might end up working later and I will
continue to try it on the device as the game gets updated.

**Balatro**

Honestly was not surprised this game ran so well on the board. The reason that the FPS is so high here
is because I did turn VSync off. I tried to do yellow deck gold stake while this data was collecting
and that run did not win...

![Balatro Benchmarks](/imgs/003/Balatro.png)

**Stardew Valley**

Going to be honest, I don't even know why I tested this game of course it was going to work. It ran
flawlessly. I haven't played this game in awhile so I forgot what I was doing on my farm so I just went
and did the get to the perfection early glitch.

![Stardew Valley Perfection Early Glitch](/imgs/003/stardew_glitch.jpg)

For those that don't know, this glitch involves going to where you would climb to get to the mountain summit
once perfection is reached. Perfection is just 100 percenting the game. If you swing your sword over and over
towards the bottom loading zone you won't trigger it and you'll be able to walk around the sides of the map 
and get into the loading zone for the area. The developer added a special cutscene if you do this which I find 
funny because they could have just patched the glitch.

![Stardew Valley Benchmarks](/imgs/003/Stardew_Valley.png)

**Puyo Puyo Tetris**

This game ran well as well. However I did make an interesting discovery about it that I should probably test more.
You cannot boot the game for the first time while offline. Once you boot it with a connection you can boot it offline.
However, the game runs really bad and it lags. My assumption is that its making network pings for whatever reason for
the online mode. I have played the Switch version offline many of times and that does not happen on there. I should have collected
data of it while offline but I did not. It could run fine offline on stronger devices so I'll have to test that at some point
with my Steam Deck.

![Puyo Puyo Tetris Benchmarks](/imgs/003/puyopuyotetris.png)

**Mewgenics**

Out of all the Steam games I tried this one was probably the most interesting. The performance felt a bit flaky while it was running.
You can see that there is some variance in the frametime and FPS so that could contribute to it. There is two charts for this game
because after I did the run prep and went to actually start a run it did soft lock when getting to the map. The funny part about
games crashing is that on the charts you can just see the GPU load go right to 0. The game really well during actual combat though so that was good. I can see this game being really playable.

*Run Prep Before Soft Lock:*
![Mewgenics Benchmarks](/imgs/003/Mewgenics_runprep.png)

*Actual Gameplay:*
![Mewgenics Benchmarks](/imgs/003/Mewgenics_actualgameplay.png)

**Persona 5 Royal**

These next three games were stretch goals. I did not think they would work but wanted to try it anyway. Reason for this was
I saw a video of someone playing Rocket League at the lowest settings on this board so you never know.

This game would load for about 20 seconds with the Phantom Thieves logo at the bottom and then just crash. The animation on the loading
icon was incredibly smooth for what it was though. I did collect data for this game but when I went to make the plots the 10 second
down sampling was too much and when lowering it the charts did not even look that interesting not really much to show besides the game
crashing.

**Persona 3 Reload**

I currently am playing through the Episode Aigis DLC for the game right now so I wanted to test it.

This game did not run well. I was able to get into the game and actually play though however it did not feel good and it was
at like 10 FPS. You probably could play the whole game like this if you really were insane. It would not be fun at all for sure though.
I did lower all the settings that I could as well. There was also this weird flashing white light that was off one of the reflections
of a shiny thing on the wall. I'm sure these sorts of artifacts would show up on other parts of the game as well.

![Weird rendering artifact in P3R](/imgs/003/p3r-rendering.jpg)

![Persona 3 Reload Benchmarks](/imgs/003/P3R.png)

**Devil May Cry V**

So even though P3R ran terribly, I was able to get into the game and actually move around at 7 FPS. Devil May Cry V was so laggy
that I did not even get past the menus. I did lower all the graphics settings and there was barely any improvement. So yeah, this
game was just a huge fail and it wasn't even interesting like P3R was no weird rendering artifacts or at least laughing at how
slow it was.

![Devil May Cry 5 Benchmarks](/imgs/003/DevilMayCry5.png)

#### Emulation

For emulators, I mainly targeted Nintendo systems because that's what I would want to emulate. I was pleasantly suprised by
the emulation capabilities of the board. I tried to test as many 3D consoles as I could. It was hard for me to find a game in my
Steam library that was 3D but not like super crazy 3D so a lot of older systems helped with this. Below is the list of emulators I
used for each system.

- Gameboy Color: Visualboy Advance
- Gameboy Advance: Visualboy Advance
- Super Nintendo: RetroArch (Snes9x Core)
- Nintendo 64: RetroArch (ParaLLEI N64 Core)
- Gamecube: RetroArch (Dolphin Core)
- Wii: RetroArch (Dolphin Core)
- 3DS: RetroArch (Citra Core)
- Playstation 2 (PCSX 2)
- Wii U (CEMU)

**Gameboy Color**

For this console, I played Pokémon Crystal. It ran really well but this was expected its Gameboy Color. I played about
20 minutes of the game and that FPS spike that is there is from when I activated speed up to test that. I also found out
that Visualboy Advance was built using SFML which was funny because I had to use this in University for one of my classes.

![Pokemon Crystal Benchmarks](/imgs/003/pokemon-crystal.png)

**Gameboy Advanced**

I played Super Mario Advance 4 for this test. These first three consoles are a case of I don't know why I tested these of 
course they work sort of deal so again no surprises here. I played the first world of the game. It's funny to see as
similar RAM pattern for the two consoles.

![Super Mario Advance 4 Benchmarks](/imgs/003/marioadvance4.png)

**Super Nintendo**

Again, no surprises for this console of course it was going to run well. I played the first world of Super Mario World.

![Super Mario World Benchmarks](/imgs/003/supermarioworld.png)

**Nintendo 64**

Mario 64 ran great. However, I did notice a bit of input delay which would be explained by the high frametime. I could
probably alter some settings to make this better. There as another N64 core listed for RetroArch but for some reason I got a
black screen from that one so I went with the one I used. I collected three stars and it was very playable.

![Super Mario 64 Benchmarks](/imgs/003/mario64.png)

**Gamecube**

This is where I thought the performance would start dropping. However, Gamecube ran great. I played a little bit of The Legend
of Zelda: Wind Waker because this was a game that I've wanted to play for awhile so seeing how it did was a good idea. There
were a few stutters here and there but I assume that was from shaders or something compiling which I know is pretty common with
3D emulation.

![Zelda Windwaker Benchmarks](/imgs/003/zelda-windwaker.png)

**Wii**

The Wii is just a slightly more powerful Gamecube so I was not suprised with how well Mario Kart Wii played. I did one Grand Prix
and I did have a few stutters similar to the Gamecube games. For example, on Toad's Factory the section right before you
go back outside has red lights shining down. On the first lap when I went into that room there was a slight stutter but on the
other laps it did not happen.

![Mario Kart Wii Benchmarks](/imgs/003/mariokartwii.png)

**3DS**

Fire Emblem Awakening is the next game I want to play after I finish the P3R DLC so I decided to test out how it ran on here.
I still do have my 3DS so I was not worried if it didn't run well. To my surprise 3DS ran great. I originally was going to
test DS as well but I decided it was a waste of time and would run fine if this did. Same as Gamecube and Wii though there was 
some stutters, specifically when a unit would attack for the first time in a combat animation. All times after that though it
ran smoothly so I'm happy to say 3DS is playable. I'm curious if you can pre-compile shaders to make things run better.

![Fire Emblem Awakening Benchmarks](/imgs/003/fe-awakening.png)

**Playstation 2**

This is the console on this list that I do not know much about however, there are games on here that I'm interested in playing.
The first being Metal Gear Solid 3: Snake Eater. The game was able to boot and the first cutscenes played out pretty well with
some lag in certain sections. However, after getting to what I'm assuming was the first gameplay section the game would just
freeze.

![MGS 3 Benchmarks](/imgs/003/mgs3.png)

I also wanted to try another PS2 game that wasn't as graphically intense as MGS 3 so I thought of Monkeyball. This game ran
great. Only stutters I got were on the level select screen when going through the levels. It would have the level's model pop out 
of a little capsule and it would freeze right before that happened. Looking at the graphs it honestly looks like this could just
be a problem that is present on the actual hardware too. This is the hard part about trying a game that you haven't played on actual
hardware or in a perfect emulation setup. So for PS2, I'm assuming its going to be a game by game basis of what works.

![Super Monkeyball Deluxe Benchmarks](/imgs/003/monkeyball.png)

**Wii U**

This was the biggest stretch that I tried because if I was going to play Zelda Windwaker I could play the HD version on Wii U.
However, these games just did not want to work it would get stuck on the splash screen. I thought it could be something wrong with my
emulator's setup so I tried it on my gaming PC and it worked fine there so I think these were just unplayable unfortunately.

## Conclusion

So there's the results of my benchmarking on the Youyeetoo X1 SBC. I like this board a lot and I think it's going to do really well
for this little console I'm building. The Steam games I would want to play work well minus Slay the Spire 2. I'm really hoping it
wasn't a problem with the board's power and it was a problem with the game that will get patched later in early access. The emulation
worked well too. There honestly could be some Gamecube, Wii, and 3DS games that could have problems too but that's a case by case basis
I can't realistically test every game on those platforms.

This was a fun experience of just trying out games on some hardware. It was cool to learn about MangoHud and I'm pretty sure its used
on SteamOS for the Steam Deck too the UI looked familiar when I was playing around with the performance overlay on there. Making the
charts were fun (who doesn't like looking at numbers on a chart) and I got to learn some basic data processing techniques.

Overall, a good first part of the actual work on this project. It's crazy that this article is over two times as long as the first
part. The next part in this is probably going to be trying out Gamescope and settling on an emulation frontend so that article probably
won't be as long. See you all in the next one!