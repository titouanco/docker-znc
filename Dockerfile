FROM alpine:3.12 as buildstage

ARG ZNC_VER="master"

# download build dependencies
RUN apk add --no-cache boost-dev build-base cmake curl cyrus-sasl-dev gettext-dev git icu-dev libressl-dev perl-dev python3-dev swig tar tcl-dev zlib-dev

# download znc
# don't shallow clone or cmake won't add git commit id to znc version string
RUN git clone --recursive --branch $ZNC_VER https://github.com/znc/znc.git /tmp/znc

# download playback plugin
RUN curl -o /tmp/playback.tar.gz -L https://github.com/jpnurmi/znc-playback/archive/master.tar.gz
RUN tar xf /tmp/playback.tar.gz -C /tmp/znc/modules --strip-components=1

# download znc-push plugin
RUN curl -o /tmp/znc-push.tar.gz -L https://github.com/jreese/znc-push/archive/master.tar.gz
RUN tar xf /tmp/znc-push.tar.gz -C /tmp/znc/modules --strip-components=1

# download znc-palaver plugin
RUN curl -o /tmp/znc-palaver.tar.gz -L https://github.com/cocodelabs/znc-palaver/archive/master.tar.gz
RUN tar xf /tmp/znc-palaver.tar.gz -C /tmp/znc/modules --strip-components=1

# download znc-clientbuffer
RUN curl -o /tmp/znc-clientbuffer.tar.gz -L https://github.com/CyberShadow/znc-clientbuffer/archive/master.tar.gz
RUN tar xf /tmp/znc-clientbuffer.tar.gz -C /tmp/znc/modules --strip-components=1

# compile znc
WORKDIR /tmp/znc/build
RUN cmake -DWANT_PERL=YES -DWANT_PYTHON=YES -DWANT_TCL=YES ..
RUN make
RUN make install

# determine runtime packages
RUN scanelf --needed --nobanner /usr/local/bin/znc \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	>> /tmp/znc/packages

FROM alpine:3.12
LABEL maintainer "Titouan Condé <hi+docker@titouan.co>"
LABEL org.label-schema.name="ZNC" \
      org.label-schema.vcs-url="https://github.com/titouanco/docker-znc"

ENV UID="991" \
    GID="991"

COPY --from=buildstage /tmp/znc/packages /packages
COPY --from=buildstage /usr/local/bin/znc* /usr/local/bin/
COPY --from=buildstage /usr/local/include/znc /usr/local/include/znc
COPY --from=buildstage /usr/local/lib64/znc /usr/local/lib64/znc
COPY --from=buildstage /usr/local/share/znc /usr/local/share/znc
COPY --from=buildstage /usr/local/share/locale /usr/local/share/locale

RUN RUNTIME_PACKAGES=$(echo $(cat /packages)) \
	&& apk add --no-cache ca-certificates runit tini ${RUNTIME_PACKAGES}

COPY root/ /
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6501
VOLUME /config

CMD ["/sbin/tini","--","/usr/local/bin/start.sh"]
