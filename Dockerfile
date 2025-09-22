# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

FROM golang:1.24.5-bookworm AS builder

RUN go install github.com/go-task/task/v3/cmd/task@latest

WORKDIR $GOPATH/src/upfadapter

COPY go.mod .
COPY go.sum .
COPY Taskfile.yml .

RUN task mod-start


COPY . .
RUN task build

FROM alpine:3.22 AS upfadapter

LABEL maintainer="Aether SD-Core <dev@lists.aetherproject.org>" \
    description="ONF open source 5G Core Network" \
    version="Stage 3"

ARG DEBUG_TOOLS

RUN apk update && apk add --no-cache -U bash

# Install debug tools ~ 50MB (if DEBUG_TOOLS is set to true)
RUN if [ "$DEBUG_TOOLS" = "true" ]; then \
        apk update && apk add --no-cache -U vim strace net-tools curl netcat-openbsd bind-tools; \
        fi

# Copy executable
COPY --from=builder /go/src/upfadapter/bin/* /usr/local/bin/.
