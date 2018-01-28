# Set nginx base image
FROM nginx

# Copy custom configuration file from the current directory
#COPY docker/nginx.conf /etc/nginx/nginx.conf
#RUN mkdir -p /etc/nginx/sites-enabled/
#COPY docker/daphne-reed.io /etc/nginx/sites-enabled/daphne-reed.io


# Copy files from Jekyll
COPY _site/ /usr/share/nginx/html/
#RUN whoami
