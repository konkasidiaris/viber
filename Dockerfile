FROM ubuntu:22.04

# -------------------------------
# Environment & Non-interactive
# -------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    QT_QUICK_BACKEND=software \
    LIBGL_ALWAYS_SOFTWARE=1 \
    MESA_LOADER_DRIVER_OVERRIDE=swrast \
    QT_XCB_GL_INTEGRATION=none \
    QT_LOGGING_RULES="qt5ct.debug=false;qt.qpa.*=false;qt.labs.platform.systray=false"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Core
        ca-certificates \
        wget \
        gdebi-core \
        locales \
        # X11 & Input
        libx11-6 libxext6 libxrender1 libxtst6 libxi6 \
        libxcb1 libxcb-shm0 libxcb-render0 libxcb-shape0 \
        libxcb-render-util0 libxcb-xfixes0 libxcb-randr0 libxcb-image0 \
        libxcb-util1 libxcb-xrm0 libxcb-keysyms1 libxcb-icccm4 libxcb-sync1 \
        libxcb-composite0 libxcb-xkb1 libxkbcommon0 libxkbcommon-x11-0 \
        libxcb-damage0 libxcb-cursor0 libxcb-xinerama0 \
        # Graphics (Software Rendering)
        libgl1 libglx0 libegl1 libopengl0 libgbm1 \
        libgl1-mesa-dri libglx-mesa0 mesa-utils \
        libosmesa6 libdbus-1-3 \
        # Audio
        libasound2 libpulse0 gstreamer1.0-pulseaudio \
        gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav \
        # GUI & Fonts
        libgtk-3-0 libgdk-pixbuf2.0-0 libpango-1.0-0 \
        libpangocairo-1.0-0 libcairo2 libfontconfig1 \
        libfreetype6 libatk1.0-0 libatk-bridge2.0-0 \
        libfontconfig1 \
        # SSL & Web
        libcurl3-gnutls libnspr4 libnss3 libexpat1 \
        libxslt1.1 libwebp7 libwebpdemux2 \
        # Misc
        libdrm2 libmng2 xdg-utils \
        libsm6 libice6 libxt6 \
        libxss1 libevent-2.1-7 \
        zlib1g libglib2.0-0 libstdc++6 libxcomposite1 \
        libxdamage1 libxfixes3 libxrandr2 libxkbfile1 \
        libxcb-xinput0 x11-xserver-utils && \
    # Locale
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# -------------------------------
# the reason that we run viber dockerized. The library at fault
# -------------------------------
ARG SSL_DEB="/tmp/libssl1.1.deb"
RUN wget --user-agent="Mozilla/5.0" \
        "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb" \
        -O "${SSL_DEB}" && \
    dpkg -i --force-depends "${SSL_DEB}" && \
    rm -f "${SSL_DEB}"

ARG VIBER_DEB="/tmp/viber.deb"
RUN wget --user-agent="Mozilla/5.0" \
        "https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb" \
        -O "${VIBER_DEB}" && \
    gdebi -n "${VIBER_DEB}" && \
    rm -f "${VIBER_DEB}"

# -------------------------------
# Disable GPU & Force Software Rendering
# Otherwise the container should run as privileged
# -------------------------------
RUN mkdir -p /etc/X11/xorg.conf.d && \
    echo 'Section "Device"\n  Identifier "dummy"\n  Driver "dummy"\nEndSection' > \
         /etc/X11/xorg.conf.d/dummy.conf

RUN useradd -m -s /bin/bash viberuser && \
    chown root:viberuser /opt/viber/Viber && \
    chmod 750 /opt/viber/Viber && \
    mkdir -p /home/viberuser/.ViberPC && \
    chown viberuser:viberuser /home/viberuser/.ViberPC

RUN apt-get purge -y wget gdebi-core ca-certificates && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/*

USER viberuser
WORKDIR /home/viberuser

VOLUME /home/viberuser/.ViberPC

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

