FROM alpine:latest
MAINTAINER Henrik Hansson <h@rwx.nu>

LABEL org.label-schema.name="alpine" \
        org.label-schema.vendor="Dockage" \
        org.label-schema.description="openRC + rtorrent" \
        org.label-schema.vcs-url="https://github.com/dockage/alpine"

COPY rtorrent.service /etc/init.d/rtorrent.service
COPY .rtorrent.rc /root/.rtorrent.rc
COPY startup-rtorrent.sh /root/startup-rtorrent.sh

RUN apk add --no-cache openrc su-exec ca-certificates curl findutils rtorrent screen \
    # Disable getty's
    && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    && sed -i \
        # Change subsystem type to "docker"
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        # Define extra dependencies for services
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop \
    # Can't do cgroups
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
    && /root/startup-rtorrent.sh \
    && rc-update add rtorrent.service default

EXPOSE 50001 5001
VOLUME /downloads

WORKDIR /etc/init.d
CMD ["/sbin/init"]
