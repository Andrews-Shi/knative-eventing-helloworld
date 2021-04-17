# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.14 as builder

# Copy local code to the container image.
WORKDIR /app

RUN git clone https://github.com/Andrews-Shi/knative-eventing-helloworld.git && mv ./knative-eventing-helloworld/go.* ./ && go mod download && mv ./knative-eventing-helloworld/go.* ./ && CGO_ENABLED=0 GOOS=linux go build -mod=readonly  -v -o helloworld

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/helloworld /helloworld

# Run the web service on container startup.
CMD ["/helloworld"]
