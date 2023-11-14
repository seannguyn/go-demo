FROM golang:1.21

# Set destination for COPY
WORKDIR /app

# Copy files
COPY ./app .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o go-demo main.go

# Expose port
EXPOSE 8080

# Run
CMD ["./go-demo"]