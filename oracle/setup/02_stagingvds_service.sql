-- Create an additional listener service name "stagingvds" on the (non-CDB) ORCLCDB.
-- A service is just a connection target; clients reach the BANKPLUS schema by
-- connecting to //host:1521/stagingvds and logging in as BANKPLUS.
--
-- Idempotent: skip creation if the service already exists.
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_services WHERE name = 'stagingvds';
  IF v_count = 0 THEN
    DBMS_SERVICE.CREATE_SERVICE(
      service_name => 'stagingvds',
      network_name => 'stagingvds');
  END IF;
  DBMS_SERVICE.START_SERVICE('stagingvds');
END;
/

-- Auto-start the service on every database open (services created via
-- DBMS_SERVICE are persistent but are NOT started automatically on restart).
CREATE OR REPLACE TRIGGER start_stagingvds_service
  AFTER STARTUP ON DATABASE
BEGIN
  DBMS_SERVICE.START_SERVICE('stagingvds');
END;
/
