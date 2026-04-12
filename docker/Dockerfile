# Use the official MySQL image from the Docker Hub
FROM mysql:8.0

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_DATABASE=xiso_db

# Create directory to hold SQL scripts and copy them 
RUN mkdir -p /docker-entrypoint-initdb.d/
# Copy final build.sql builder and use it in entry point of init
COPY db/06_build/build.sql /docker-entrypoint-initdb.d/

# Expose MySQL port
EXPOSE 330

# Start the MySQL server when the container is run
CMD ["mysqld"]
