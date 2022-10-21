# CloneToolX for macOS
Disk cloning software for macOS Big Sur 11.5.2+
ClonetoolX has officially reached Beta stage.

On a supported Mac this now works on macOS 11.5.2. 
While the command line is not hard, CloneToolX with its GUI makes things way more simple.

#### Note: The current version does not support a helper agent for running as admin or root
There are two workarounds for this. Open in Xcode. Go to Edit Scheme. Make sure it is set to root. Then run from Xode
The second workaround, `sudo .../CloneToolX.app/Contents/MacOS/CloneToolX`

Hope to add a helper agent soon.

_____

Don't want to use CloneToolX but still want to create a bootable backup? Try this

sudo asr -s / -t /Volumes/nameOfTarget -er -nov -nop

-s = source
-t = target

-er = erase target partition (always backup to a partition, recommend not backing up to a volume group, cuz you can only have one live backup per a single volume group on a partition. This may seem ok, but you are better off making a partion for each backup with multiple partitions per disk (IE can have multiple backups, provided enough space is allowed).

-nov = no verify, usually a faster backup especially on clean systems with an intial macOS app setup
-nop = no prompt for erase

Works best with APFS freshly erased partitions

Works best with 130 megs of data or less. Less is preferred. Due to sealed volumes since macOS 11 Big Sur, live backups are now required. Try not to modify your system when during a live backup.

To boot the live backup. Enter recovery mode and make sure you can boot external startup disks. It is off by default since 2019 in Apple's Macs. Then reboot, open System Preference and open the Startup disk utility, select the startup disk, select the owner when asks, enter your owner password and one final authorization admin prompt, then reboot!

Hope all goes well. ASR used to be killer, today, it's still cool but it doesn't like large volumes over 130 megs anymore. Just gets to be unreliable. I used to backup 500 megs with it all the time and it was much faster then.
