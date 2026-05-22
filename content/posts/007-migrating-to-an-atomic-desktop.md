+++
title = "[007] Migrating to an Atomic OS"
date = "2026-05-21T18:00:00-05:00"
author = "Christopher Coco"
cover = "/imgs/007/ultrawide_terminal.png"
coverCaption = "Screenshot of my desktop with Fastfetch."
keywords = ["Fedora", "Hyprland", "Bootc", "Atomic Desktops", "Linux", "Linux Ricing"]
description = "Article about migrating my personal workstations from Manjaro with KDE to Fedora Bootc with Hyprland."
readingTime = true
+++

This last month I have been quite busy with various different things and with the next step of my handheld project being
starting to learn electronics to build the controller, I decided to take a step back and work on something I've been meaning to
for awhile. This little project is migrating my personal workstations from Manjaro with KDE to Fedora Bootc with Hyprland.
Fedora Bootc with Hyprland is an atomic desktop setup and these are really powerful for people who like playing around with declarative
configs and automation. This article is going to go into what is an atomic desktop, how I created my own atomic desktop image, and discuss
some problems I ran into so people hopefuly don't hit the same things that I did.

The repository for this small project can be [here](https://github.com/cjcocokrisp/the-karma-os) if you are looking to view the setup. I will be
referencing things in the repo throughout the article.

## What and Why an Atomic Desktop?

An atomic desktop is a Linux desktop with a read-only, immutable root file system where things either update as a whole system
or not as all. These are incredibly powerful because if a bad update breaks your system you can easily rollback to a previous version.
These use [bootc](https://github.com/bootc-dev/bootc) (I'm not sure if there are any other similar tools I think RPM ostree is one) and are usually based on Fedora at the moment. The `/etc` directory remains writable along with
your `/home` directory. The rest of the system needs to be written too at the time the image is built. [Fedora](https://fedoraproject.org/atomic-desktops/) has a few atomic desktops like Silverblue and Kionite.

Another big atomic desktop project is [Universal Blue](https://universal-blue.org/). They have a few projects like Aurora and Bluefin but their most
popular by far is Bazzite. Bazzite is an atomic desktop aimed at making Linux gaming more accessible. A lot of people use Bazzite as an alternative
OS on Valve's Steam Deck and I'm sure the same will be true on the Steam Machine when that launches. To me the coolest part of the UBlue project is
the image template that they provide. More on this later though in the article because its the template I used to get started.

One thing you might be thinking is how do you install packages if everything is read only. Well you can use tools like brew to install packages and flatpak for apps.
Bootc also allows you to have a transient overlayfs over `/usr` so you can temporarily install things and they will get removed on reboot. So if
you really need something through `dnf` you can use that until you reboot after updating the base image.

As a final note, a lot of this stuff is managed in a cloud native way which in this case is just a fancy way of saying containers. I find containers
incredibly awesome and they're probably one of my favorite pieces of technology so I was really looking to start managing my operating system with a
similar workflow.

## What I Wanted Out of This?

The main things that stood out was rollbacks and reproducability. Before this I used Manjaro on my workstations. Last October, a major Manjaro upgrade bricked grub
and while trying to fix it I wiped my drive on accident and lost all my data (luckily it was my desktop PC so nothing too important was lost). Seeing that major upgrade cause such a big problem and made me want to switch over to having this set up.
I ended up tagging images by commit and then nightly so I have good rollback points. I also wanted the reproducability of it as well. I don't get new devices often but setting up
Manjaro again took me awhile to get everything back to the way that I wanted it to be. Being able to easily
get my system back to how I wanted it was really appealing.

Beyond bootc I wanted to switch desktop environments as well. I was using KDE on Manjaro but got used to using a tiling window manager with Aerospace on my work Macbook.
I found this window script for Manjaro that adds tiling window manager like things called [Krohnkite](https://github.com/esjeon/krohnkite). It was working well but I think it would be better
to switch to a native tiling window manager because there was some jank every now and then. I tried Hyprland back during
my freshman year of college wanting to go from a minimal system in Arch to Hyprland. At the time, I
didn't realize all of the things that would be missing and it was really hard to use. So after using
Manjaro for about two years I finally felt comfortable about knowing what I would need. I also created
a quick doc before hand that listed everything I wanted to be in the image so creating it was more
managable.

## The "Lab" Environment

To get started with all of this, I split my laptops drive and installed Fedora.
I referred to this as the "lab" environment. I used this for testing
out various software that I wanted to use on this image. The big one being Hyprland. I spent sometime
getting all my settings in order. I used Pywal to get colors from my wallpaper and all that fancy 
ricing stuff you see on Reddit. For cool Hyprland things, I set Spotify to always be in a special
workspace so I can overlay it over things when I'm doing stuff. Thought that was really cool. I also
set some keybinds to open up apps that I use almost everytime I use my machines.


I also tried out [eww](https://github.com/elkowar/eww) to make a really simple 
dashboard that would appear when pressing the super key. The dashboard I created was simple.
It just contains the uptime of the system, user and hostname, the systray, and volume percentage.
I orignally wanted this to be more complex with lots of widgets like weather, maybe some stocks once
I start investing, common folders, etc but I decided that was just overkill for stuff I would barely
use. I also did not like the config for eww the syntax was pretty terrible. Apparently it's similar
to lisp so I do not know how lisp programmers do it you guys are crazy. Below is a screenshot of the
eww widget. You can also see on the systray I have WiFi and Bluetooth applets there. Clicking on the
volume brings up an audio mixer too.

![Eww Widget with systray and volume being the two useful pieces of info](/imgs/007/eww.png)

Some other apps I set up is mako for notifications, hyprlock for a lockscreen, waybar which I already
used on KDE just adjusted the colors and made the middle show the window when Spotify is not playing.
After playing around with everying and getting it how I wanted it I was ready to start building
the image. Going to end this section with some random screenshots from the set up just to show it
off a bit.

My script that prints a random image and Trails song name when I open a new terminal and what my
terminal prompt looks like:

![Terminal](/imgs/007/term.png)

Btop which I have set to a keybind to see my system stats at all times, it also launches by clicking
on CPU or RAM on the status bar. It will be useful to just see my system stats when I'm doing things of load. 

![Btop](/imgs/007/btop.png)

Spotify in the special workspace while I was writing this article!

![Spotify](/imgs/007/spotify.png)

All of this stuff just reminds me so much of why I love using Linux. Infinite customizability that
the only limitation is my creativity. Building a desktop environment that fits my style and looks
awesome in the process was so much fun.


## Creating the Bootc Image

Creating the bootc image was a long process. This mainly came down to how long it took for the image
to build. About 10 minutes for it to build everytime and then another 15 to build the ISO. I probably
should not have tested by doing it with a fresh install everytime but my goal was to have everything
there on install so that was fine to do. I would create a new VM with the ISO everytime to test it
and the only thing that wouldn't work in the VM was hyprlock for some driver reason.

For making the image I used [Universal Blue's custom image template](https://github.com/ublue-os/image-template).
This template is so awesome! It gives you so much configured right away like image building pipelines,
container signing, disk ISO builds, a justfile with a ton of commands, and more. If you want to
create your own I highly recommend using it because it helped a ton with stuff you probably would
have ended up copy and pasting from somewhere anyway. The CI pipeline they provide to build the
ISO images is currently broken in the template. I see some PRs open to fix it but they don't include
everything I had to fix so I might contribute those upstream at some point when I get the time.

The first thing that I did was figure out what packages I needed. I found these by running `dnf list --installed`
on the testing install I used to get everything I thought I needed. After getting the packages down,
I put all my dotfiles into the repo and then had a script create the `/etc/skel` directory so all
new users will have the dotfiles. Unfortunately, some of the paths in the configs are hardcoded by my username. I
could probably write some script that runs on first launch of Hyprland that replaces everything but
if I find people start using my configs that's something I could do.

I also wrote a script to start hyprland and then greetd with tuigreet for the login screen. Right 
now systemd bleeds through but eventually I will fix that or set systemd to silent.

Installing the packages, placing the dotfiles, and enabling hyprland are the three big parts of the
image. The other big part is the CI which I briefly touched upon already. The CI pipeline builds a
new image on each commit to the repo and then pushes it to GHCR so it can be deployed on the system.
An edit I made was to tag it based on the commit hash like `commit-XXXXXXX` and also commit nightly
scheduled builds to be taged with `nightly-%Y.%m.%d`. The nightly
builds will catch package updates to keep them update to date. I like this convention because if
anything goes wrong I have good restore points to go to.

Overall, I'm happy with the structure of the image right now I don't really know what I would change
here.

## Problems I Ran Into

In this section of the article I'm going to briefly talk about some challenges I ran into while making the
image.

#### Terra Repo Flakiness 

The first is Terra repo flakiness. Some of the packages I install are from this repo. While building the image
it would sometimes just fail out right and also when building the ISO it wouldn't allow it because the repo didn't have a
GPG key. I tried to put one in but kept running into issues so I just solved this by disabling the repo after installing the
packages.

#### Initramfs Breaking

I broke the initramfs while working on the image. It would cause a kernel panic everytime on boot without the cool penguin 
ASCII art (so sad). This was caused by running `dnf upgrade` while building the image. My guess is that it was installing some
update for the kernel and not updating the initramfs and using the one in the base image so there was a mismatch. Removing that
fixed it and its probably better practice to use whats in the base image for the base packages.

#### The Dual Boot Problem

Installing the image onto my PC did take some time. My PC has two drives. One had Windows on it and the other Manjaro. I was
going to split the Manjaro drive to have both but that wasn't working. The ISO install would fail midway through and it seemed to be
from there already being a bootloader and using bootc requires a different one. Which would make sense. I don't know enough about
bootloaders to give a good explaination here but wiping my Windows drive once and for all after backing up the files on there it 
installed fine.

## Future Work

I also want to briefly touch on some future work I want to do on this. I'll do it in a bullet point style.

- Theme switcher, auto change colors and wallpapers on the fly.
- Better path replacement for users so my username isn't hardcoded anywhere.
- More stylized apps off of pywal colors.
- More widgets, I want to do local AI at some point so having a way to quickly pull up a chat for that would be cool.
- Try out Quickshell, I've seen some cool Reddit posts with this so I got to give it a shot.

## Should You Set Something Like This Up?

I think setting up something like this is really great for people who like containers or want the benefits that I listed earlier. I do
think for people who have never used Linux before or are still new this might be pretty difficult to do. If you still want the benefits
of having an atomic desktop I think that using a premade one like Bazzite or Silverblue would be good you just wouldn't be able to add
your own packages but things like brew will help with that.

## Conclusion

Overall, this was a really fun little project to do and I'm happy that I'm finally using an atomic desktop. This did take longer then
I wanted to but I had a lot of stuff going on so there were some weekends where I didn't work much on it. I'm sure I'll be making
changes to this as time goes on so I will defintely write another article about it if I do something major. Anyway, that's all for
this article. Thanks for reading and I will see you all in the next one!