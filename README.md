##Rngminion

The rngminion.lua is a 4th gen emulator RNG script will hit delay and perform Chatot frame advancements for you. This works even if you fast forward.

What the bot does upon execution:

1. Dismiss the intro and the start menu
2. Load your game save at the correct delay
3. Bring up the menu at the earliest time
4. Open the summary screen of the Pokemon in the 2nd slot of your party
5. Attempts to perform frame advancement (assuming the 2nd and/or 3rd pokemon in your party is a Chatot with a custom chatter)

##Requirements

You need to know how to use RNG Reporter:

* 4th Gen Time Finder where you pick your seed and get its frame
* 4th Gen Seed to Time where you get the date, time and delay to hit your seed

You need to understand how 4th gen RNG works. All the bot does is perform input for you.

###Software

* **RNG Reporter** - This script was used with version 9.96.6 BETA, but the latest version you can get your hands on should be fine
* **DeSmuME 0.9.9** - download from [here](https://sourceforge.net/projects/desmume/files/desmume/0.9.9/). This script has been tested on the 32-bit version.
* a **4th gen Pokemon ROM** of your choice
* **RunAsDate 1.30** - download from [here](http://www.nirsoft.net/utils/run_as_date.html). This script has been tested on the 32-bit version.

###Your party

1. one Pokemon (**any kind**) in the 1st slot of your party (maybe your synchronizer?)
1. one **Chatot** with the **Chatter** skill and **a custom chatter recorded** on the 2nd slot of your party
1. [OPTIONAL] a second **Chatot** that also has **Chatter** on the 3rd slot of your party

####Your setup *must* look like this:

```
+----------+----------+
+   Any    |  Chatot  +
+----------+----------+
+  Chatot  | Any/None +
+----------+----------+
+ Any/None | Any/None +
+----------+----------+
```
This is very important because the bot will assume that you have a Chatot in the 2nd slot of your party, and that there's a Pokemon on the 3rd slot that it can switch to for frame advancement.

##Usage instructions

1. Edit rngminion.lua with a plain text editor of your choice (Notepad, Notepad++, Sublime, etc.)
  * Change `targetdelay` to the delay you got from RNG Reporter's Seed to Time
  * Change `targetframe` to the frame you got from RNG Reporter's 4th Gen Time Finder
  * Change `hasjournal` to `true` if you expect the Journal to appear on DPPt `false` if not
1. Open RunAsDate
1. Set the following
  * Application to run - browse to select the DeSmuME executable (DeSmuME_0.9.9_x86.exe or DeSmuME_0.9.9_dev.exe)
  * Date/Time
    * Absolute date/time
    * The date you got from RNG Reporter's Seed to Time
    * The time you got from RNG Reporter's Seed to Time
  * Move the time forward according to the real time: UNCHECK
1. Click the Run button, and DeSmuME will open
1. Open the Pokemon ROM (File -> Open ROM -> browse to your ROM)
1. Open the Lua Script window (Tools -> Lua Scripting -> New Lua Script Window)
1. Click Browse, select rngminion.lua, then click Open
1. The emulator will restart and the bot will start running
1. You're done! now you can just watch the bot work its magic
  * In the Lua Scripting window, the script will print out what it has done so far
  * Once your save has been loaded (`Menu Opened` is printed in the Lua Scripting window), check the `Initial Seed` displayed at the bottom of DeSmuME's window. See troubleshooting section if you end up with the wrong seed.
  * Towards the end, the script will advance your frames for you.
  * [Optional] You can set the hotkey for fast forward or toggle fast forward on and you should still get the correct results!
1. Once the script is done, it will exit the Pokemon Summary screen and go back to the Pokemon list

###Troubleshooting

####Wrong `Initial Seed` value after your save is loaded?

* If the first few characters are wrong, there is a mistake in your RunAsDate date/time settings
* If the last few characters are wrong, then the delay wasn't hit.
  * If your seed is off by +1 or -1, then you are stuck with either all odd or all even seeds (depending on which you got)
    * To flip your odd-ness to even-ness (and vice-versa), you can attach a GBA game to DeSmuME's GBA slot
    * Config -> Slot 2, then assign a GBA ROM. Make sure that there is a save file (.sav) with the same name right beside the ROM
    * A, C, E are even. B, D, F are odd.
  * If the seed is off by a lot, make sure you are setting the correct value in `targetdelay`

####Wrong `PIDRNG Frame` value after advances are done?

* If you overshoot by 1 frame, just run the script again. If it consistently happens, adjust `target frame`
* If you are consistently overshooting by x frames, you can compensate by subtracting x from your `targetframe`
* If you are consistently under by x frames, you can compensate by adding x to your `targetframe`
* Depending on what you want to catch, you have to subtract several frames from the value you got from RNG Reporter

####Got stuck on the journal screen?

Set `hasjournal` to `true`

####My DeSmuME settings?

Config -> Frame Skip -> Limit Framerate
Config -> Frame Skip -> 0 (Never Skip)
Config -> Emulation Settings -> Use external BIOS images: UNCHECKED
Config -> Emulation Settings -> Use external firmware image: UNCHECKED
Config -> Emulation Settings -> Enable Advanced Bus-Level Timing: CHECKED
Config -> Emulation Settings -> Use dynamic recompiler: CHECKED
Config -> Emulation Settings -> Use dynamic recompiler -> Block Size: 100

####You think the bot is bugged?

If you are familiar with Lua scripting and you know how to fix the bug yourself, send a pull request.

If the player starts walking back and forth and this consistently happens, there's something wrong with the delay between button presses. The same goes for when the bot gets stuck in a menu somewhere. Let me know.

Otherwise, send me a detailed description of what happens. Also send specific replication instructions on how to make the bug happen (I can't fix the bug if I can't replicate it), which game (and where you got the ROM), along with which versions of software you are using.

##Credits

This script is a modification of the Lua\_Script\_4thGen\_USA lua script by [Real.96](http://pokerng.forumcommunity.net/?act=Profile&MID=9270606) (known as [Feder96](https://www.reddit.com/user/Feder96) on reddit) of the [Noob (New Order Of Breeding)](http://pokerng.forumcommunity.net/) forum. The original scripts can be found [here](http://pokerng.forumcommunity.net/?t=56443955&p=396434984).
