# Use a multi-architecture base image
FROM --platform=$BUILDPLATFORM golang:1.21 AS build

# Specify the author
LABEL authors="hra42"

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app for the target platform
ARG TARGETPLATFORM
RUN GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
    GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
    GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
    go build -o main .

# Start a new stage from scratch
FROM scratch

WORKDIR /app

# Copy the binary from build stage
COPY --from=build /app/main .

# Command to run when starting the container
CMD ["./main"]