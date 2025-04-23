# Use the official Nginx image as base
FROM nginx:alpine

# Copy the static website to Nginx's default serving directory
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# The default command starts Nginx
CMD ["nginx", "-g", "daemon off;"]