# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.14 as builder

# Copy local code to the container image.
WORKDIR /app

RUN git clone https://github.com/Andrews-Shi/knative-eventing-helloworld.git ./

# Retrieve application dependencies using go modules.
# Allows container builds to reuse downloaded dependencies.
COPY ./knative-eventing-helloworld/go.* ./
RUN go mod download

# Copy local code to the container image.
COPY ./knative-eventing-helloworld/*.* ./

# Build the binary.
# -mod=readonly ensures immutable go.mod and go.sum in container builds.
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly  -v -o helloworld

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/helloworld /helloworld

# Run the web service on container startup.
CMD ["/helloworld"]
