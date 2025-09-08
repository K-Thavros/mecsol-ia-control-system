# Use the official NGINX image as a base
FROM nginx:1.25-alpine

# Install the 'gettext' package which provides the 'envsubst' utility.
# We update the package list, install the package, and then clean up the cache
# to keep the image size small.
RUN apk update && apk add --no-cache gettext

# Copy the startup script into the container
COPY start-nginx.sh /docker-entrypoint.d/start-nginx.sh

# Make the startup script executable
RUN chmod +x /docker-entrypoint.d/start-nginx.sh

# The entrypoint will automatically execute scripts in /docker-entrypoint.d/
# before starting the main NGINX process.
# We don't need to override the CMD or ENTRYPOINT.
