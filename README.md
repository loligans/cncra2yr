# cncra2yr
Running Command and Conquer: Red Alert 2 YR within a Docker Container

## Building the Docker Image
Setting your CWD to the directory containing the Dockerfile run:  
`docker build --build-arg PASS=<yourpassword> --tag 'ra2' .`

Note: The container's default user is named `commander` and the password is `lolhaha`. I recommend changing the password by specifying the build arg `--build-arg PASS=<password>`

## Running the Docker Image
```shell
sudo docker run -it \
                --rm \
                --device /dev/snd \
                --device /dev/bus/usb \
                --device /dev/dri/renderD128:/dev/dri/renderD128 \
                -v /run/user/$(id -u)/pulse:/run/user/1000/pulse:ro \
                -e XDG_RUNTIME_DIR=/tmp \
                -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
                -e DISPLAY=$DISPLAY \
                -e XAUTHORITY=$XAUTHORITY \
                -e SOCK=/tmp/.X11-unix \
                -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY:ro \
                -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
                -v ./home:/home/commander \
                -v ./data:/opt/data \
                -v $XAUTHORITY:$XAUTHORITY:ro \
                ra2 /usr/bin/zsh
```

### Audio Support
The following devices are needed in order for audio to work and also the RA2 start menu to not crash.  
`--device /dev/snd`  
`--device /dev/bus/usb`  
`-v /run/user/$(id -u)/pulse:/run/user/1000/pulse`

### 3D Acceleration
The following device is needed in order for 3D acceleration to work. Note: Only tested with iGFX (YMMV with AMD and NVIDIA and might require additional tweaks)  
`--device /dev/dri/renderD128:/dev/dri/renderD128`

### Forwarding Wayland and XWayland
In order to get the UX to appear we need to forward Wayland and XWayland (X11)

#### Wayland
`-e XDG_RUNTIME_DIR=/tmp`  
`-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY`  
`-v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY:ro`

#### XWayland
`-e DISPLAY=$DISPLAY`  
`-e XAUTHORITY=$XAUTHORITY`  
`-e SOCK=/tmp/.X11-unix`  
`-v /tmp/.X11-unix:/tmp/.X11-unix:ro`  
`-v $XAUTHORITY:$XAUTHORITY:ro`

Note: If you are running X11, I think you can just pass the XWayland variables and it'll work the same.

### Persisting Data and Wine Prefix's
In order to persist the data we bind a home directory to the container's user account home directory. The user name is `commander`. In addition we mount a data directory in `/opt/data` for any data files you'd like to bring into the container (like install scripts, etc)
`-v ./home:/home/commander`  
`-v ./data:/opt/data `

## Installing and Running RA2
In order to get RA2 running inside your docker container, you need to set up your Wine Prefix as follows:

### Installing RA2 + CnCNet
The below script shows you how to set up your Wine Prefix. You will probably have to adapt it to meet your needs, but it should get you most the way there.
```shell
export WINE_PREFIX_NAME=.ra2wine
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" wine winecfg -v win7
# Remove Wine Mono Runtime
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" wine uninstaller --remove {4D7015F4-AD93-593F-9B93-598FEC29D419}
# Install dotnet40
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" winetricks -q -f dotnet40
# Install xna40
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" winetricks -q -f xna40
# Set Virtual Desktop to 1080p
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" winetricks vd=1920x1080

### The following steps are all about installing your RA2 files into the Prefix. This is highly variable
### and depends on how you attain your RA2 installation. If you manually install the game, be sure to 
### put it somewhere inside ~/$WINE_PREFIX_NAME/drive_c
### For me I install it in ~/$WINE_PREFIX_NAME/drive_c/RA2

# Install CnC-RA:YR
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" wine /opt/data/Red\ Alert\ 2\ Yuri\'s\ Revenge.exe
# Optional: Install CnCNet
WINEARCH=win32 WINEPREFIX="/home/commander/$WINE_PREFIX_NAME/" wine /opt/data/CnCNet5_YR_Installer.exe

# Optional: Install Mental Omega (Installation steps)
cp /opt/data/MentalOmega336Patch.zip /home/commander/$WINE_PREFIX_NAME/drive_c/RA2
cd /home/commander/$WINE_PREFIX_NAME/drive_c/RA2
unzip -o MentalOmega336Patch.zip
```

### Running RA2/CnCNet
Running CnCNet:
`WINEARCH=win32 WINEPREFIX="/home/commander/.ra2wine/" sh -c 'cd ~/.ra2wine/drive_c/RA2; wine ./CnCNetYRLauncher.exe'`

Running RA2:
`WINEARCH=win32 WINEPREFIX="/home/commander/.ra2wine/" sh -c 'cd ~/.ra2wine/drive_c/RA2; wine ./RA2.exe'`

Running RA2-YR:
`WINEARCH=win32 WINEPREFIX="/home/commander/.ra2wine/" sh -c 'cd ~/.ra2wine/drive_c/RA2; wine ./RA2MD.exe'`

Running Mental Omega:
`WINEARCH=win32 WINEPREFIX="/home/commander/.ra2wine/" sh -c 'cd ~/.ra2wine/drive_c/RA2; wine ./MentalOmegaClient.exe'`

> If you update CnCNet, The Mental Omega client won't work anymore. Simply follow the install steps to fix again.