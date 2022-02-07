```PowerShell
cd .\Downloads\
Invoke-WebRequest https://download-installer.cdn.mozilla.net/pub/devedition/releases/97.0b9/win32/en-US/Firefox` Installer.exe -OutFile firefox.exe
# (grave for escape)
# (as admin)
wsl --install
```

BIOS:

Tweaker > Extreme Memory Profile (X.M.P)
    [Disabled] -> [Profile1]
because free mhz

Settings > AMD CPU fTPM
    [Disabled] -> [Enabled]
for win11

Tweaker > Advanced CPU Settings > SVM Mode
    [Disabled] -> [Enabled]
for virt

Setup:

Windows 11 Pro
delete all partitions (let default)
Region United States
Keyboard Layout US, & skip
"I don't have internet" (skip account bother), continue w/ limited setup
Privacy settings -> toggle all to OFF

no pass means no security questions

timezone sync
Win + I; turn off Wi-Fi because mobo
DNS ...
power saving
taskbar unpin, items all to off, alignment
x select the far corner of the taskbar to show the desktop
lock screen spotlight -> picture
x get fun facts

VS Code
win terminal newest
WSL remote