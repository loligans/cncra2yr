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

### Running RA2
All the steps prior set your machine up to be able to run RA2 inside a docker container. I don't have the instructions for setting up the RA2 Wine Prefix, but am open to a contribution here that utilizes an automation for copying the necessary data files from `/opt/data`

`cd ~/.ra2wine/drive_c/RA2`  
`WINEARCH=win32 WINEPREFIX="/home/commander/.ra2wine/" wine ./CnCNetYRLauncher.exe`