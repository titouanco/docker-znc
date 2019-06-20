FROM alpine:3.10 as buildstage

ARG ZNC_VER="master"

# download build dependencies
RUN apk add --no-cache autoconf automake c-ares-dev curl cyrus-sasl-dev g++ gcc gettext-dev git icu-dev make openssl-dev perl-dev python3-dev swig tar tcl-dev git

# download znc
RUN git clone --recursive --depth 1 --branch $ZNC_VER https://github.com/znc/znc.git /tmp/znc

# download playback plugin
RUN curl -o /tmp/playback.tar.gz -L https://github.com/jpnurmi/znc-playback/archive/master.tar.gz
RUN tar xf /tmp/playback.tar.gz -C /tmp/znc/modules --strip-components=1

# download znc-push plugin
RUN curl -o /tmp/znc-push.tar.gz -L https://github.com/jreese/znc-push/archive/master.tar.gz
RUN tar xf /tmp/znc-push.tar.gz -C /tmp/znc/modules --strip-components=1

# download znc-clientbuffer
RUN curl -o /tmp/znc-clientbuffer.tar.gz -L https://github.com/CyberShadow/znc-clientbuffer/archive/master.tar.gz
RUN tar xf /tmp/znc-clientbuffer.tar.gz -C /tmp/znc/modules --strip-components=1

# compile znc
WORKDIR /tmp/znc
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"
RUN ./bootstrap.sh
RUN ./configure \
	--build=$CBUILD \
	--enable-cyrus \
	--enable-perl \
	--enable-python \
	--enable-swig \
	--enable-tcl \
	--host=$CHOST \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc
RUN make
RUN make DESTDIR=/tmp/znc install

# determine runtime packages
RUN scanelf --needed --nobanner /tmp/znc/usr/bin/znc \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	>> /tmp/znc/packages

FROM alpine:3.10
LABEL maintainer "Titouan Condé <hi+docker@titouan.co>"
LABEL org.label-schema.name="ZNC" \
      org.label-schema.vcs-url="https://code.titouan.co/titouan/docker-znc"

ENV UID="991" \
    GID="991"

COPY --from=buildstage /tmp/znc/usr/ /usr/
COPY --from=buildstage /tmp/znc/packages /packages

RUN RUNTIME_PACKAGES=$(echo $(cat /packages)) \
	&& apk add --no-cache ca-certificates runit tini ${RUNTIME_PACKAGES}

COPY root/ /
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6501
VOLUME /config

CMD ["/sbin/tini","--","/usr/local/bin/start.sh"]
