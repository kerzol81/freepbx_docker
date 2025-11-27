FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

RUN apt-get update && \
    apt-get install -y \
      systemd systemd-sysv dbus \
      build-essential wget git curl sudo tzdata ufw \
      apache2 mariadb-server mariadb-client \
      php php-mysql php-xml php-cli php-mbstring \
      php-curl php-zip php-intl php-bcmath php-gd \
      php-readline php-pear php-common libapache2-mod-php \
      php-soap \
      sox mpg123 libssl-dev libncurses-dev libnewt-dev libxml2-dev libsqlite3-dev uuid-dev \
      libjansson-dev libedit-dev libldns-dev libcurl4-openssl-dev libical-dev libsrtp2-dev \
      sqlite3 uuid-runtime net-tools nodejs npm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY install-freepbx.sh /root/install-freepbx.sh
RUN chmod +x /root/install-freepbx.sh

RUN mkdir -p /etc/systemd/system/multi-user.target.wants && \
    cat >/etc/systemd/system/freepbx-install.service <<'EOF'
[Unit]
Description=Run FreePBX/Asterisk installer once
After=network.target
ConditionPathExists=!/root/.freepbx-installed

[Service]
Type=oneshot
ExecStart=/root/install-freepbx.sh
ExecStartPost=/bin/touch /root/.freepbx-installed
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
RUN ln -s /etc/systemd/system/freepbx-install.service \
          /etc/systemd/system/multi-user.target.wants/freepbx-install.service

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
