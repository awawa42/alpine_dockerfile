FROM alpine:edge

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

COPY appconf /opt/mygoapp/
COPY etc /etc/

#COPY --from=golang:alpine /usr/local/go/ /usr/local/go/
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH

RUN \
    # Print executed commands
    set -x ; \
    apk add --update --no-cache \
                runit \
                nginx \
                ca-certificates wget curl \
                openssh \
                htop ncdu mtr \
                screen zsh bash \
                nano nano-syntax \
                git \
                vnstat \
#                make \
                python3 py3-pip \
                ; \
    ssh-keygen -A ; \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh ;\
    rm -rf /etc/nginx/http.d/default.conf ;\
    chmod +x /etc/runit.2 ; \
    #enable runit services
    mkdir -p /etc/service/ ; \
    rm -rf /usr/sbin/policy-rc.d ; \
    ln -s /etc/sv/cron /etc/service/ ; \
    ln -s /etc/sv/vnstatd /etc/service/ ; \
    ln -s /etc/sv/nginx /etc/service/ ; \
    ln -s /etc/sv/mygoapp /etc/service/ ; \
    ln -s /etc/sv/ssh /etc/service/ ; \
    #download custom service binary
    mkdir -p /opt/mygoapp && \
    wget -O- https://woi1.awawa.cf/pxe/mygoapp.tar.xz|tar -xJ -C /opt/mygoapp ; \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed 's/^\s*ZSH_THEME="robbyrussell"/ZSH_THEME="fino"/g' ~/.zshrc -Ei ; \
    echo 'export GOPATH=/go' >> ~/.zshrc ; \
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.zshrc ; \
    echo 'export GO111MODULE=on' >> ~/.zshrc ; \
    sed '/root/s#/bin/ash#/bin/zsh#g' -i /etc/passwd ; \
    echo 'include "/usr/share/nano/*.nanorc"' >> /etc/nanorc ; \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

EXPOSE 22
EXPOSE 443/udp
EXPOSE 443/tcp
EXPOSE 2220-2230/udp
EXPOSE 2220-2230/tcp
EXPOSE 17999/udp
EXPOSE 17999/tcp

CMD ["/etc/runit.2"]
