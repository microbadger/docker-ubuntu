FROM ubuntu:xenial

LABEL vendor=stackfeed \
      version_tags="[\"xenial\",\"16.04\"]"

RUN apt-get -y update && apt-get install -y openssh-server sudo

# tweaks for systemd
RUN systemctl mask -- \
    -.mount \
    dev-mqueue.mount \
    dev-hugepages.mount \
    etc-hosts.mount \
    etc-hostname.mount \
    etc-resolv.conf.mount \
    proc-bus.mount \
    proc-irq.mount \
    proc-kcore.mount \
    proc-sys-fs-binfmt_misc.mount \
    proc-sysrq\\\\x2dtrigger.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    tmp.mount \
&& \
    systemctl mask -- \
    console-getty.service \
    display-manager.service \
    getty-static.service \
    getty\@tty1.service \
    hwclock-save.service \
    ondemand.service \
    systemd-logind.service \
    systemd-remount-fs.service \
&& ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target \
&& ln -sf /lib/systemd/system/halt.target /etc/systemd/system/sigpwr.target

# Enabling daemon startup (by default docker disables daemon startup policy
# ==> ERROR: invoke-rc.d: policy-rc.d denied execution of start)
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

VOLUME ["/sys/fs/cgroup", "/run"]

# run: docker run -d --name xxx -v /tmp/cgroup:/sys/fs/cgroup:ro -v /tmp/run:/run:rw ubuntu-systemd
# stop: docker kill --signal SIGPWR xxx && docker stop xxx

CMD ["/sbin/init"]
