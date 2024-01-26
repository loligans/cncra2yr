FROM ubuntu:22.04 AS base
ARG PASS=lolhaha
RUN apt update && apt install -y \
    curl \
    wget \
    git \
    zsh \
    vim \
    sudo \
    gnupg \
    openssl \
    x11-apps \
    software-properties-common \
    dbus \
    dbus-x11 \
    file \
    pulseaudio-utils \
    pciutils \
    xz-utils \
    zenity \
    libsndfile1 \
    unzip

RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt update

# Install Wine + Mesa
RUN sudo add-apt-repository ppa:kisak/kisak-mesa -y \
    && sudo apt update \
    && sudo apt upgrade -y \
    && sudo apt install --install-recommends -y \
    winehq-staging \
    winetricks \
    libgl1-mesa-dri:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    libgl1-mesa-glx:i386 \
    wine64 \
    wine32 \
    libsdl2-2.0-0:i386 \
    libdbus-1-3:i386 \
    libsqlite3-0:i386

# Install Steam Dependencies
RUN sudo apt install -y \
    libc6-i386 \
    libgl1:i386 \
    libxtst6:i386 \
    libxrandr2:i386 \
    libglib2.0-0:i386 \
    libgtk2.0-0:i386 \
    libpulse0:i386 \
    libva2:i386 \
    libbz2-1.0:i386 \
    libvdpau1:i386 \
    libva-x11-2:i386 \
    libcurl4-gnutls-dev:i386 \
    libopenal1:i386 \
    libsm6:i386 \
    libice6:i386 \
    libsdl2-image-2.0-0:i386 \
    mesa-utils \
    lsof

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
RUN chsh -s /usr/bin/zsh

RUN useradd -u 1000 -m -s /usr/bin/zsh commander
RUN mkdir -p /etc/sudoers.d && \
    echo 'commander ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/commander && \
    chmod 0440 /etc/sudoers.d/commander
RUN usermod -p "$(openssl passwd $PASS)" commander \
    && gpasswd -a commander audio

# Enable audio
COPY pulse-client.conf /etc/pulse/client.conf

USER commander
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
