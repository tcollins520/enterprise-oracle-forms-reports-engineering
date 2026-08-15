#!/bin/bash

# =============================================================================
# Script: rman_backup_validate.sh
#
# Purpose:
#   Validates that the existing RMAN backup chain can be used
#   for database restore and recovery.
#
# Validation:
#   - Cross-checks existing RMAN backups
#   - Removes expired backup metadata
#   - Displays RMAN backup summary
#   - Performs RESTORE DATABASE VALIDATE
#
# Oracle Version:
#   23.26.1.0.0 Enterprise Edition
# =============================================================================

set -u

# =============================================================================
# ORACLE ENVIRONMENT
# =============================================================================

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/23.0.0/dbhome_1
export ORACLE_SID=FORMSCDB
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

# =============================================================================
# CONFIGURATION
# =============================================================================

BACKUP_DIR=/u03/backup/FORMSCDB
LOG_DIR=/home/oracle/scripts/logs

TS=$(date +%Y%m%d_%H%M%S)

# =============================================================================
# PREPARE DIRECTORIES
# =============================================================================

mkdir -p "$BACKUP_DIR" "$LOG_DIR" || exit 1

# =============================================================================
# BACKUP VALIDATION
# =============================================================================

echo "========================================================="
echo "RMAN BACKUP VALIDATION"
echo "========================================================="
echo "ORACLE_SID : ${ORACLE_SID}"
echo "BACKUP_DIR : ${BACKUP_DIR}"
echo "Started    : $(date)"
echo

rman target / log="${LOG_DIR}/rman_backup_validate_${TS}.log" <<RMAN

CONFIGURE CONTROLFILE AUTOBACKUP ON;

CROSSCHECK BACKUP;

DELETE NOPROMPT EXPIRED BACKUP;

LIST BACKUP SUMMARY;

RESTORE DATABASE VALIDATE;

EXIT;

RMAN

RMAN_STATUS=$?

# =============================================================================
# RESULT
# =============================================================================

echo
echo "========================================================="

if [ "$RMAN_STATUS" -eq 0 ]; then
    echo "Status         : SUCCESS"
else
    echo "Status         : FAILED"
fi

echo "Database       : ${ORACLE_SID}"
echo "Backup Folder  : ${BACKUP_DIR}"
echo "Log File       : ${LOG_DIR}/rman_backup_validate_${TS}.log"
echo "Finished       : $(date)"

echo "========================================================="

exit "$RMAN_STATUS"
