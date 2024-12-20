FROM alpine:3.21.0 as build
LABEL maintainer="Luke Tainton <luke@tainton.uk>"
LABEL org.opencontainers.image.source="https://github.com/luketainton/docker-radius"

FROM build as webproc
ENV WEBPROCVERSION 0.4.0
ENV WEBPROCURL https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROCURL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as radius
RUN apk --no-cache add freeradius
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ADD clients.conf /etc/raddb/clients.conf
ADD users /etc/raddb/users
ADD radiusd.conf /etc/raddb/radiusd.conf
RUN chmod -R o-w /etc/raddb/
ENTRYPOINT ["webproc","-o","restart","-c","/etc/raddb/users","-c", "/etc/raddb/clients.conf", "-c", "/etc/raddb/radiusd.conf","--","radiusd","-f","-l","stdout"]
EXPOSE 1812/udp 8080/tcp
