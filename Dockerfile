# Use lightweight official Nginx image.
FROM nginx:alpine

# Copy static website files into Nginx default web root.
COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css
COPY script.js /usr/share/nginx/html/script.js
COPY assets /usr/share/nginx/html/assets

# Expose HTTP port.
EXPOSE 80

# Run Nginx in foreground so the container stays alive.
CMD ["nginx", "-g", "daemon off;"]
