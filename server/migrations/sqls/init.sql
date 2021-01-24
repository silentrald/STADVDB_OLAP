CREATE DATABASE stadvdb_db2;
CREATE ROLE stadvdb_user WITH LOGIN PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE stadvdb_db2 TO stadvdb_user;

-- psql -h localhost -p 5432 -U stadvdb_user -W -d stadvdb_db2
