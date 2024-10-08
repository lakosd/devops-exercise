ARG NODE_VERSION=22.8.0

FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV production

#
WORKDIR /usr/src/app

# Run the application as a non-root user.
USER node

# Copy the rest of the source files into the image.
COPY . .

# Expose the port that the application listens on.
EXPOSE 8198

# Run the application.
CMD node service2.js
