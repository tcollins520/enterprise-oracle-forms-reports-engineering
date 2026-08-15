#!/bin/bash

# =============================================================================
# Script: rman_backup_validate.sh
#
# Purpose:
#   Performs an Oracle RMAN backup and validates that the database can be
#   successfully validated for restore operations.
#
# Backup Operations:
#   - Enables RMAN control file autobackup
#   - Cross-checks existing RMAN backups
#   - Removes expired backup metadata
#   - Performs a full database backup
#   - Includes archived redo logs in the backup
#   - Backs up the current control file
#   - Displays an RMAN backup summary
#
# Validation:
#   - Performs RESTORE DATABASE VALIDATE
#   - Verifies that Oracle can validate the required backup pieces
#     for database recovery
#
# Logging:
#   - Creates timestamped RMAN backup logs
#   - Creates timestamped RMAN validation logs
#
# Default Locations:
#   Backup files: /u01/app/oracle/rman_backup
#   RMAN logs:    /u01/app/oracle/rman_logs
#
# Environment Variables:
#   BACKUP_DIR
#       Optional backup destination.
#
#       Example:
#       BACKUP_DIR=/backup/oracle ./rman_backup_validate.sh
#
#   LOG_DIR
#       Optional RMAN log destination.
#
#       Example:
#       LOG_DIR=/backup/logs ./rman_backup_validate.sh
#
# Usage:
#   ./rman_backup_validate.sh
#
# Run as:
#   Oracle software owner with access to RMAN and the target database.
#
# Exit Codes:
#   0 = RMAN backup and restore validation completed successfully
#   1 = Backup or restore validation requires review
#
# Notes:
#   This script is intended for the lab/interview environment. Production
#   implementations should define backup retention, storage requirements,
#   encryption, monitoring, and recovery objectives before automation.
# =============================================================================


set -u


# =============================================================================
# CONFIGURATION
# =============================================================================

BACKUP_DIR="${BACKUP_DIR:-/u01/app/oracle/rman_backup}"
LOG_DIR="${LOG_DIR:-/u01/app/oracle/rman_logs}"
TS=$(date +%Y%m%d_%H%M%S)


# =============================================================================
# PREPARE DIRECTORIES
# =============================================================================

mkdir -p "$BACKUP_DIR" "$LOG_DIR" || exit 1


# =============================================================================
# BACKUP
# =============================================================================

echo "===== RMAN BACKUP / VALIDATION ====="
echo "ORACLE_SID=${ORACLE_SID:-NOT_SET}"
echo "BACKUP_DIR=$BACKUP_DIR"


rman target / log="${LOG_DIR}/rman_${TS}.log" <<RMAN

CONFIGURE CONTROLFILE AUTOBACKUP ON;

CROSSCHECK BACKUP;

DELETE NOPROMPT EXPIRED BACKUP;

BACKUP DATABASE
PLUS ARCHIVELOG
FORMAT '${BACKUP_DIR}/%d_%T_%U.bkp';

BACKUP CURRENT CONTROLFILE
FORMAT '${BACKUP_DIR}/control_%d_%T_%U.bkp';

CROSSCHECK BACKUP;

LIST BACKUP SUMMARY;

RMAN


rc=$?


# =============================================================================
# RESTORE VALIDATION
# =============================================================================

rman target / log="${LOG_DIR}/validate_${TS}.log" <<RMAN

RESTORE DATABASE VALIDATE;

RMAN


vr=$?


# =============================================================================
# RESULT
# =============================================================================

if [ "$rc" -eq 0 ] && [ "$vr" -eq 0 ]; then

    echo
    echo "RESULT: Backup and restore validation succeeded."
    echo "Backup log: ${LOG_DIR}/rman_${TS}.log"
    echo "Validation log: ${LOG_DIR}/validate_${TS}.log"

    exit 0

fi


echo
echo "RESULT: Review RMAN logs."
echo "Backup return code: $rc"
echo "Validation return code: $vr"
echo "Backup log: ${LOG_DIR}/rman_${TS}.log"
echo "Validation log: ${LOG_DIR}/validate_${TS}.log"

exit 1
