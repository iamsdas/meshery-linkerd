FROM golang:1.15 as build-env
ARG VERSION
ARG GIT_COMMITSHA

WORKDIR /github.com/layer5io/meshery-linkerd
COPY go.mod go.sum ./
RUN go mod download
COPY main.go main.go
COPY internal/ internal/
COPY linkerd/ linkerd/

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -ldflags="-w -s -X main.version=$VERSION -X main.gitsha=$GIT_COMMITSHA" -a -o meshery-linkerd main.go

FROM gcr.io/distroless/base:nonroot-amd64
ENV DISTRO="debian"
ENV GOARCH="amd64"
ENV SERVICE_ADDR="meshery-linkerd"
ENV MESHERY_SERVER="http://meshery:9081"
WORKDIR /
COPY templates/ ./templates
COPY --from=build-env /github.com/layer5io/meshery-linkerd/meshery-linkerd .
ENTRYPOINT ["./meshery-linkerd"]
