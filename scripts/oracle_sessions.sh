#!/bin/bash

# =============================================================================
# Script: oracle_sessions_check
#
# Purpose:
#   Performs an Oracle session and process health check to identify
#   connection utilization, active/inactive sessions, application
#   connections, and blocking sessions.
#
# Checks:
#   - Oracle process utilization
#   - Oracle session utilization
#   - Current and maximum utilization
#   - Active and inactive session counts
#   - Application/database sessions
#   - Client program and machine
#   - Oracle service associated with each session
#   - Blocking sessions and database waits
#
# Usage:
#   ./oracle_sessions_check
#
# Run as:
#   Oracle software owner with access to SQL*Plus / Oracle views
#
# Exit:
#   Displays session information for troubleshooting and performance
#   analysis. An INACTIVE application session is not automatically
#   considered a problem; WebLogic JDBC connection pools commonly
#   maintain idle connections for reuse.
# =============================================================================


echo "===== SESSION / PROCESS CHECK ====="
set -u
echo "===== SESSION / PROCESS CHECK ====="
sqlplus -s / as sysdba <<'SQL'
set pages 100 lines 220 feedback off
prompt === SESSION / PROCESS UTILIZATION ===
select resource_name,current_utilization,max_utilization,limit_value
from v$resource_limit
where resource_name in ('sessions','processes');

prompt === SESSION STATUS ===
select status,count(*) sessions from v$session group by status order by status;

prompt === APPLICATION SESSIONS ===
select username,status,service_name,program,machine
from v$session where username is not null
order by username,status;

prompt === BLOCKING SESSIONS ===
select blocking_session,sid,serial#,username,event,wait_class,seconds_in_wait
from v$session
where blocking_session is not null
order by seconds_in_wait desc;
SQL
