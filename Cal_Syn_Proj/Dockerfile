FROM golang:1.22-alpine AS builder
WORKDIR /app
# Install build dependencies for CGO
RUN apk add --no-cache git gcc musl-dev
RUN git clone https://github.com/bobuk/gcalsync.git .
RUN go mod download

# PATCH 1: Prevent copying event notes (Description)
RUN sed -i 's/blockerDescription := event.Description/blockerDescription := ""/' sync.go

# PATCH 2: Change event title to "O_o [Calendar Name]" instead of original event title
# We use the 'accountName' variable which is passed into the syncCalendar function
RUN sed -i 's/blockerSummary := fmt.Sprintf("O_o %s", event.Summary)/blockerSummary := fmt.Sprintf("O_o %s", accountName)/' sync.go

# Enable CGO for sqlite3
RUN CGO_ENABLED=1 GOOS=linux go build -o gcalsync

FROM alpine:latest
WORKDIR /root/
# Install runtime dependencies for CGO
RUN apk add --no-cache ca-certificates libc6-compat
COPY --from=builder /app/gcalsync .
VOLUME /root/.config/gcalsync
ENTRYPOINT ["./gcalsync"]
