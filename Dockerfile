# Use Node.js 22 on Alpine
FROM node:22-alpine
LABEL maintainer="jm <github@timbrust.de>"

# Argument for refreshing Docker image
ARG REFRESHED_AT
ENV REFRESHED_AT $REFRESHED_AT

# Update packages and install necessary dependencies
RUN apk -U upgrade \
    && apk add --no-cache \
    git \
    openssh

# Set the working directory
WORKDIR /code

# Install ESLint globally
RUN npm install -g eslint

# Expose the working directory for Jenkins
VOLUME /code