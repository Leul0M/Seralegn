# Backend PostgreSQL Database Container
FROM postgres:16-alpine

# Set default environment variables
ENV POSTGRES_DB=seralegn
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

# Copy database schema initialization script into Postgres init directory
COPY database_structure.sql /docker-entrypoint-initdb.d/01_database_structure.sql

EXPOSE 5432
