#!/bin/bash

# =============================================================================
# Script: oracle_health_check.sh
#
# Purpose:
#   Performs a top-to-bottom health check of the Linux and Oracle environment.
#
# OS Checks:
#   - Hostname and operating system
#   - CPU count and CPU model
#   - Memory utilization
#   - Swap utilization
#   - System load average
#   - Root filesystem utilization
#
# Oracle Checks:
#   - Oracle environment variables
#   - Database status, role, and ARCHIVELOG mode
#   - Oracle instance status
#   - CDB/PDB status
#   - Oracle listener and registered services
#   - Tablespace size, free space, % free, and % used
#   - Database sessions and processes
#
# Usage:
#   ./oracle_health_check.sh
#
# Run as:
#   Oracle software owner
# =============================================================================


echo "===== ORACLE HEALTH CHECK ====="
date


# =============================================================================
# HOST
# =============================================================================

echo
echo "===== HOST ====="

echo "Hostname:"
hostname

echo
echo "Operating System:"
cat /etc/redhat-release


# =============================================================================
# ORACLE ENVIRONMENT
# =============================================================================

echo
echo "===== ORACLE ENVIRONMENT ====="

echo "ORACLE_SID=$ORACLE_SID"
echo "ORACLE_HOME=$ORACLE_HOME"
echo "ORACLE_BASE=$ORACLE_BASE"


# =============================================================================
# OS STATISTICS
# =============================================================================

echo
echo "===== OS STATS ====="


echo
echo "--- CPU ---"

echo "CPU Count: $(nproc)"

lscpu | grep "Model name" | sed 's/^[[:space:]]*//'


echo
echo "--- MEMORY ---"

free -h


echo
echo "--- SWAP ---"

swapon --show


echo
echo "--- LOAD AVERAGE ---"

uptime


echo
echo "--- FILESYSTEM ---"

df -h /


# =============================================================================
# DATABASE
# =============================================================================

echo
echo "===== DATABASE ====="

sqlplus -s / as sysdba <<'SQL'

set lines 200
set pages 100
set feedback off
set heading on

column name format a12
column open_mode format a20
column database_role format a18
column log_mode format a12

SELECT
    name,
    open_mode,
    database_role,
    log_mode
FROM v$database;


column instance_name format a18
column status format a12
column host_name format a40

SELECT
    instance_name,
    status,
    host_name
FROM v$instance;

EXIT;

SQL


# =============================================================================
# PDBS
# =============================================================================

echo
echo "===== PDBS ====="

sqlplus -s / as sysdba <<'SQL'

set lines 200
set pages 100
set feedback off

SELECT
    con_id,
    name,
    open_mode
FROM v$containers
ORDER BY con_id;

EXIT;

SQL


# =============================================================================
# LISTENER
# =============================================================================

echo
echo "===== LISTENER ====="

lsnrctl status


# =============================================================================
# TABLESPACES
# =============================================================================

echo
echo "===== TABLESPACES ====="

sqlplus -s / as sysdba <<'SQL'

set lines 220
set pages 200
set feedback off
set heading on
set sqlblanklines on

column con_name        format a18
column tablespace_name format a25
column size_mb         format 999,999,990.00
column free_mb         format 999,999,990.00
column pct_free        format 990
column pct_used        format 990


WITH datafiles AS (
    SELECT
        con_id,
        tablespace_name,
        SUM(bytes) AS total_bytes
    FROM cdb_data_files
    GROUP BY
        con_id,
        tablespace_name
),
freespace AS (
    SELECT
        con_id,
        tablespace_name,
        SUM(bytes) AS free_bytes
    FROM cdb_free_space
    GROUP BY
        con_id,
        tablespace_name
)
SELECT
    c.name AS con_name,
    d.tablespace_name,
    ROUND(
        d.total_bytes / 1024 / 1024,
        2
    ) AS size_mb,
    ROUND(
        NVL(f.free_bytes, 0) / 1024 / 1024,
        2
    ) AS free_mb,
    NVL(
        ROUND(
            NVL(f.free_bytes, 0)
            * 100
            / NULLIF(d.total_bytes, 0)
        ),
        0
    ) AS pct_free,
    NVL(
        ROUND(
            (
                d.total_bytes
                - NVL(f.free_bytes, 0)
            )
            * 100
            / NULLIF(d.total_bytes, 0)
        ),
        0
    ) AS pct_used
FROM datafiles d
LEFT JOIN freespace f
    ON f.con_id = d.con_id
   AND f.tablespace_name = d.tablespace_name
JOIN v$containers c
    ON c.con_id = d.con_id
ORDER BY
    c.con_id,
    pct_used DESC;


PROMPT
PROMPT ===== TEMP TABLESPACES =====


SELECT
    c.name AS con_name,
    t.tablespace_name,
    ROUND(
        t.total_bytes / 1024 / 1024,
        2
    ) AS size_mb,
    ROUND(
        NVL(h.free_space, 0) / 1024 / 1024,
        2
    ) AS free_mb,
    NVL(
        ROUND(
            NVL(h.free_space, 0)
            * 100
            / NULLIF(t.total_bytes, 0)
        ),
        0
    ) AS pct_free,
    NVL(
        ROUND(
            (
                t.total_bytes
                - NVL(h.free_space, 0)
            )
            * 100
            / NULLIF(t.total_bytes, 0)
        ),
        0
    ) AS pct_used
FROM
(
    SELECT
        con_id,
        tablespace_name,
        SUM(bytes) AS total_bytes
    FROM cdb_temp_files
    GROUP BY
        con_id,
        tablespace_name
) t
LEFT JOIN
(
    SELECT
        con_id,
        tablespace_name,
        SUM(free_space) AS free_space
    FROM cdb_temp_free_space
    GROUP BY
        con_id,
        tablespace_name
) h
    ON h.con_id = t.con_id
   AND h.tablespace_name = t.tablespace_name
JOIN v$containers c
    ON c.con_id = t.con_id
ORDER BY
    c.con_id,
    pct_used DESC;

EXIT;

SQL


# =============================================================================
# SESSIONS / PROCESSES
# =============================================================================

echo
echo "===== SESSIONS / PROCESSES ====="

sqlplus -s / as sysdba <<'SQL'

set lines 200
set pages 100
set feedback off

column resource_name format a20
column current_utilization format 999999
column max_utilization format 999999
column limit_value format a15

SELECT
    resource_name,
    current_utilization,
    max_utilization,
    limit_value
FROM v$resource_limit
WHERE resource_name IN (
    'processes',
    'sessions'
)
ORDER BY resource_name;

EXIT;

SQL


# =============================================================================
# COMPLETE
# =============================================================================

echo
echo "===== HEALTH CHECK COMPLETE ====="
date
