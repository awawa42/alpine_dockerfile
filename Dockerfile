FROM alpine:edge

# Enable init.
RUN apk add --update --no-cache openrc && \
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab && \
    sed -i \
      -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
      -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
      -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
      -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
      -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
      /etc/rc.conf && \
    rm -f /etc/init.d/hwdrivers \
      /etc/init.d/hwclock \
      /etc/init.d/hwdrivers \
      /etc/init.d/modules \
      /etc/init.d/modules-load \
      /etc/init.d/modloop && \
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

RUN apk add --no-cache ca-certificates wget openssh htop ncdu mtr screen zsh && \
    ssh-keygen -A

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    test -n "$sshkey1" && echo "$sshkey1" > /root/.ssh/authorized_keys ; \
    test -n "$sshkey2" && echo "$sshkey2" >> /root/.ssh/authorized_keys ; \
    chmod 644 /root/.ssh/authorized_keys

RUN rc-update add sshd

EXPOSE 22
EXPOSE 80/tcp
EXPOSE 80/udp
EXPOSE 17999/udp


VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
