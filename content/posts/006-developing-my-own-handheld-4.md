+++
title = "[006] Developing My Own Gaming Handheld Part 4: Software Testing"
date = "2026-04-19T18:00:00-05:00"
author = "Christopher Coco"
cover = "/imgs/006/gamescope.jpg"
coverCaption = "Gamescope with CSS Loader Art Hero theme."
keywords = ["Projects", "Youyeetoo X1", "Steam", "Emulation", "Tech", "Electronics"]
description = "Results of testing some software I want to utilize for the project."
readingTime = true
+++

{{< handheld-toc >}}

After benchmarking the Youyeetoo X1 and getting some hardware situated, the next
step that I planned was to do some testing of software I wanted to use
on the project. The goal here was to get it as close to the Steam Deck
experience as possible. I talked about it in the first part, but let's
recap what my goals are.

For starters, I want the device to autoboot into Steam Big Picture mode.
This will make it easier to access my games and feel more like a console.
I also want to use Decky, a plugin loader, to allow for custom themes and
other nice plugins like customizing art, showing Proton DB status, and more.
The final thing that I need is an emulation frontend to use and I need that
emulation frontend to be accessible through Big Picture mode. I also want the
setup of all of this to be automated so I need to find out how to download
everything through the terminal. This will be packaged into a bootc image which
I will discuss a bit about how I decide to do that later. When that's done, I will
write a dedicated article about how it works.

## Software Used

The rest of this article will discuss the software I used and the setup process
I did for all of them. I will include commands and snippets for config that I used
as well to make replicating this easier. All of these will be combined into a bootc
image later in the project to make it so it's all installed along with the OS.

### Gamescope

The first part of software that I wanted to test is [Gamescope](https://github.com/ValveSoftware/gamescope).
Gamescope is a mirco Wayland compositor that's used in the Steam Deck and SteamOS to boot into Steam's
big picture mode. It's a really neat piece of software that I was really excited to try out with this project.
I think that Gamescope will provide some performance benefits due to not needed the whole desktop environment
to play games and just having the window compositor have Steam and the game that I'm currently playing.
The install and setup were easy to complete.

The first step was to install it. As a reminder, I am using Fedora as the distro on this machine so `dnf` is
the package manager that I have.

```bash
# Installation command
dnf install -y gamescope
```

After the install was complete, a desktop session entry for Gamescope needed to be created. A desktop session entry
is read by the login system (in this case SDDM) to know what program to start for the desktop session. By default on this
system it is KDE Plasma. Other Linux distros might use something like Gnome. I personally like KDE better which is why I went
with Fedora with KDE. The final image is going to use that as well but it will boot to Steam first so the full desktop environment
shouldn't be needed in the first place.

Anyway, creating the desktop entry was easy. The below file needed to be created and then placed in `/usr/share/wayland-sessions/`.
I named the file `steam-big-picture.desktop`.
For the actual Gamescope command, the `-e` flag tells Gamescope to expose the Wayland socket to the launched app allowing it to have
better input and output handling. After that is the actual application to open up in Gamescope in our case being Steam. The `-tenfoot`
flag tells Steam to open in Big Picture mode.

```toml
[Desktop Entry]
Name=Steam Big Picture Mode
Comment=Start Steam in Big Picture Mode
Exec=/usr/bin/gamescope -e -- /usr/bin/steam -tenfoot
Type=Application
```

With the desktop session entry created, we now needed to set it as the default session. This is done by changing things under the
`[Autologin]` section in the SDDM config. The SDDM config is found at `/etc/sddm.conf`. The section was changed to be the following:

```toml
[Autologin]
Relogin=false # If not false, will loop into Big Picture mode when trying to switch to desktop mode
Session=steam-big-picture # Whatever you named the desktop entry file without .desktop
User=cjcocokrisp # Whatever your username is
```

After changing the default SDDM session, there is one more step that needs to be completed. By default, Gamescope does not know what
to do when you click the "Switch to Desktop mode" button. According to [this](https://gist.github.com/Rishikant181/e26fb23d4c57db74bddaa0a57b26cd26#5-creating-a-script-to-switch-back-to-desktop-mode-close-steam) 
GitHub Gist, a simple script just needs to be created. The script needs to be named `steamos-session-select` and be placed inside
`$HOME/.local/bin/`. All the script needs to do is call `steam -shutdown`. If all the above steps have been completed, when you 
reboot the device you should see Steam launch in Big Picture mode and be allowed to go back to the SDDM login screen after clicking
"Switch to Desktop mode" in the menu. 

Desktop sessions can be selected by pressing the button on the bottom left of the SDDM login screen. So if you didn't want to reboot
the device you could just log out and select one. It should look like below.

![Desktop Sessions after Gamescope setup](/imgs/006/sessions.webp)

### Decky

Now that we can easily get to Steam, I wanted to install [Decky](https://github.com/SteamDeckHomebrew/decky-loader). Decky, is a plugin
manager for Steam Big Picture mode and it allows for you to install some cool stuff. I use it on my Steam Deck and it allows for some
awesome customization with themes and more. The cover image of this article shows all I setup for themes at the moment but more will
be done in the future to make it match what I have on Steam Deck which you can see in Part 1 of this series. Installing Decky is also
easy and is done by running the following command.

```bash
# Install Decky
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
```

I really hate this way of installing things (download a bash script and then run it). It's super insecure and if you are an application
developer and are reading this please never do this...

Decky's plugins can be installed via their GUI within Big Picture mode but also can be installed manually by downloading the zip for the
plugin, extracting it, and then placing it in `$HOME/homebrew/plugins/`. This is how I plan to install all of the plugins that I want to use.
More details on which plugins I include will be talked about when I write the article on the bootc image. 

One other thing I needed to test was installing themes for CSS Loader through commands. This was weird because the site where you can
install them does not let you copy the download links when you right click the button. So I got the URL for downloading by inspecting
the network traffic after pressing the button. So that's how I will download them automatically. Once they're downloaded they just need
to be placed in the `$HOME/homebrew/themes/`.

This was the part of the testing I was most worried about being tough to automate but I'm happy that it seems like it won't be too
difficult.

### EmulationStation DE

Next up is an emulation frontend to use. I decided to choose EmulationStation DE. This is the only one that I have used but it has
really nice theme options and was really easy to setup so I decided to use it here as well. I looked into some other options and none
of them really stood out.

To install ES-DE on Fedora you can either do it through Flatpak, manually, or use a repo called Terra. The Terra repo included some
packages that the default does not. I went with the Terra repo because something that I use later also is installed through it.
The repo can be enabled and ES-DE can be installed through the following commands.

```bash
# The no gpg check is risky but it will do for now
dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terrael$releasever' terra-release
dnf install -y es-de
```

Once it is installed, opening up the application will create two folders in your home directory `ES-DE` and `ROMs`. The `ES-DE`
directory is where all the config lives for the application and then the `ROMs` directory is where ROMs are placed. It automatically
creates a ton of folders for all the systems as well making it really easy to add ROMs. I placed all the ROMs I used during
benchmarking for testing and it seemed like most of the emulators were also picked up automatically so that is nice.

I also installed a theme for it which is the DS theme. This theme is based on the home menu from the DS Lite. 
I like this one a lot, it's really nostalgic for me because I grew up using the DS. There's tons of theme options and they all can be
seen through [this list](https://gitlab.com/es-de/themes/themes-list). I'm going to have this one automatically be installed with the
image so luckily you just need to clone the theme and place it into the themes directory in the `ES-DE` directory that was created.
Below is an image of how it looks.

![The ES-DE DS Theme that I decided to use](/imgs/006/esde.jpg)

The final part of this was adding it to Steam as a non Steam game through commands. When googling how to do this, I came across
[Steam Tinker Launch](https://github.com/sonic2kk/steamtinkerlaunch). This tool lets you do a ton of stuff with Steam through the CLI
which is really nice. It can also be downloaded through the Terra repo and the below commands installs it and adds ES-DE to Steam.

```bash
dnf install -y steamtinkerlaunch
steamtinkerlaunch ansg -ep="/usr/bin/es-de" -an="EmulationStation DE"
```

The other thing that I wanted to do was add the art in automatically but that I could not figure out how to do easily. 
Steam Tinker Launch has a command for it but it requires the AppID. There's also a command for that but I could not get it to work.
That might be something to look more into when creating the bootc image but there's a plugin that will allow for that really easily
with Decky so I'm not too concerned if that needs to be setup manually.

With that figured out, all of the software I wanted to test was setup!

### Plans for Bootc Image

Before closing this article out, I want to talk a bit about how I want to setup the bootc image after this. I think setting up 
a lot of the things that I mentioned in this article will need to be day 2 operations. A day 2 operation is the stuff that comes
after the OS is installed. I was originally hoping that everything would be able to be done in the bootc image. That will not be
possible because that is the day 0 operation. If you have no clue what I'm talking about here are the three phases in an OS deployment.

- Day 0 - Planning
- Day 1 - Deployment
- Day 2 - Configuration

A bootc image is a day 0 operation because it's basically setting up what will be on the system. A lot of the stuff here requires there
to be a user created and you to also be signed into Steam. Automating Steam sign in would be really tricky so here is what I'm thinking.
I'll probably create a day 2 setup script that will automate all of this stuff and it will be ran by either SSHing into the device or
doing it manually. I'll have it boot to KDE by default to make doing this even easier. The bootc image's point will be to place
everything will it should be. I'll also include an upgrade script and probably some local config file to compare with as well.
Still need to do more planning on this. Doing it this way will also probably be helpful because you could get the software stack for
this device ran on any system and if I template it properly then you can easily switch out the package manager. Thinking about it now 
I think that I'll probably break down the bootc article into maybe two parts so it's more digestable and not super long haha.

## Conclusion

Another step of the project finished! Before doing the bootc image stuff, I plan to start working on the controller. I ordered a micro
controller and a beginners bread board kit today to get started. I want to do this first so I know if there's an dependencies for the
controller itself. I hope this article showed off some cool gaming software you can use on Linux and I'm looking forward to how all of
this is turning out because it feels like the project is finally starting to come together! 

Anyway that's all for this one and I'll see you guys in the next one.