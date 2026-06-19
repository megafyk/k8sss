-- The doctorkirk/oracle-19c image creates a NON-CDB named ORCLCDB (no PDBs),
-- so BANKPLUS is created directly as a normal user in that database.
-- In Oracle a USER and its SCHEMA are the same object, so this creates both.
CREATE USER BANKPLUS IDENTIFIED BY "bank#2016"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Allow the account to log in and do normal schema work.
GRANT CREATE SESSION TO BANKPLUS;          -- connect to the database
GRANT CONNECT, RESOURCE TO BANKPLUS;       -- create tables, sequences, etc.

-- Optional: let it create views and synonyms.
GRANT CREATE VIEW, CREATE SYNONYM TO BANKPLUS;
