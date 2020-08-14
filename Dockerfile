FROM golang:1.12-alpine3.10 as builder

RUN apk update && apk add sqlite-dev build-base

WORKDIR $GOPATH

ADD perkeep/.git src/perkeep.org/.git
ADD perkeep/app src/perkeep.org/app
ADD perkeep/clients src/perkeep.org/clients
ADD perkeep/cmd src/perkeep.org/cmd
ADD perkeep/config src/perkeep.org/config
ADD perkeep/dev src/perkeep.org/dev
ADD perkeep/doc src/perkeep.org/doc
ADD perkeep/internal src/perkeep.org/internal
ADD perkeep/pkg src/perkeep.org/pkg
ADD perkeep/server src/perkeep.org/server
ADD perkeep/vendor src/perkeep.org/vendor
ADD perkeep/website src/perkeep.org/website
ADD perkeep/make.go src/perkeep.org/make.go
ADD perkeep/VERSION src/perkeep.org/VERSION

WORKDIR $GOPATH/src/perkeep.org
RUN go run make.go --sqlite=true -v

FROM alpine:3.10.2 as runner

RUN apk update
RUN apk --no-cache add tini=0.18.0-r0 su-exec=0.2-r0 sqlite-dev ca-certificates
RUN update-ca-certificates

RUN adduser -D keepy

WORKDIR /perkeep
COPY --chown=root:root entrypoint.sh .
COPY --chown=root:keepy --from=builder /go/bin/pk* ./bin/
COPY --chown=root:keepy --from=builder /go/bin/perkeepd ./bin
COPY --chown=root:keepy --from=builder /go/bin/publisher ./bin
COPY --chown=root:keepy --from=builder /go/bin/scancab ./bin
COPY --chown=root:keepy --from=builder /go/bin/scanningcabinet ./bin

ENV PATH /perkeep/bin:$PATH
ENV CAMLI_CONFIG_DIR /etc/perkeep

EXPOSE 80 443 3179 8080

ENTRYPOINT ["tini", "--", "/perkeep/entrypoint.sh"]
CMD ["server"]
