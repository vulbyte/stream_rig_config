# stream_rig_config

here's the tldr is this is meant to be a rig hyper specifically optimized for streaming 4k@60, and the point of this whole system is to get the rig running quickly, consistently, and reliably.

this is a rig for my streaming rig with the following core utils and what not, this likely will not work on your system but hopefully will offer help to others attempting to do the same [i trimmed irrelivant info]:
```
          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             vulbyte@nixos
          ▜███▙       ▜███▙  ▟███▛             -------------
           ▜███▙       ▜███▙▟███▛              OS: NixOS 25.11 (Xantusia) x86_64
            ▜███▙       ▜██████▛               
     ▟█████████████████▙ ▜████▛     ▟▙         Kernel: Linux 6.18.2
    ▟███████████████████▙ ▜███▙    ▟██▙        Shell: bash 5.3.3
           ▄▄▄▄▖           ▜███▙  ▟███▛        Display (WAC1056): 1920x1080 in 24", 60 Hz [External]
          ▟███▛             ▜██▛ ▟███▛         DE: KDE Plasma
         ▟███▛               ▜▛ ▟███▛          WM: KWin (Wayland)
▟███████████▛                  ▟██████████▙    Font: Noto Sans (10pt) [Qt], Noto Sans (10pt) [GTK2/3/4]
▜██████████▛                  ▟███████████▛    Terminal: konsole 25.8.3
      ▟███▛ ▟▙               ▟███▛             
     ▟███▛ ▟██▙             ▟███▛              CPU: Intel(R) Core(TM) i5-8400 (6) @ 4.00 GHz
    ▟███▛  ▜███▙           ▝▀▀▀▀               GPU: Intel UHD Graphics 630 @ 1.05 GHz [Integrated]
    ▜██▛    ▜███▙ ▜██████████████████▛         Memory: 3.93 GiB / 11.44 GiB (34%)
     ▜▛     ▟████▙ ▜████████████████▛          Swap: 0 B / 12.63 GiB (0%)
           ▟██████▙       ▜███▙                Host: Inspiron 5680 (2.2.0) [motherboard && bios version]
          ▟███▛▜███▙       ▜███▙               Disk (/): 15.08 GiB / 924.41 GiB (2%) - ext4
         ▟███▛  ▜███▙       ▜███▙              
         ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘              
```

here's the software and packages added that will be added to the system:
```
[

]
```

---

loading the config onto the system: 
```
sudo ./install_config
```

---

saving: [this is for me in the future]
assuming a blank install of nixOS [graphical]:

get the ssh key configured and what not first with:
```
sudo ./init_system 
```
then go to:
[https://github.com/settings/keys](https://github.com/settings/keys)
and add the key located at: [file://~/.shh/


then to save run:
```
sudo ./save_config
```
