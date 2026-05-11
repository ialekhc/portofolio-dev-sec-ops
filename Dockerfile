# Use lightweight official Nginx image.
FROM nginx:alpine

# Copy static website files into Nginx default web root.
COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css
COPY script.js /usr/share/nginx/html/script.js
COPY assets /usr/share/nginx/html/assets
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Ensure the Nginx user can read site files.
RUN chown -R nginx:nginx /usr/share/nginx/html

# Drop root privileges for runtime.
USER nginx

# Expose non-privileged HTTP port.
EXPOSE 8080

# Run Nginx in foreground so the container stays alive.
CMD ["nginx", "-g", "daemon off;"]
