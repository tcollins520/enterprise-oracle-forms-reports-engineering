#!/bin/bash
###############################################################################
#
# Script Name : rman_incremental.sh
#
# Purpose:
# Performs a daily RMAN Level 1 Incremental Backup.
#
# Backup Includes:
# - Incremental Database Backup
# - Archived Redo Logs
# - Current Control File
#
# Oracle Version : 12.2.0.1 Enterprise Edition
#
###############################################################################

##############################
# Oracle Environment
##############################

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome_1
export ORACLE_SID=ORCL12C
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

##############################
# Backup Configuration
##############################

BACKUP_ROOT=/u03/backup
LOG_DIR=/opt/oracle/logs

SECTION_SIZE=10G
MIN_FREE_GB=10

BACKUP_DATE=$(date +%Y%m%d)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

BACKUP_DIR=${BACKUP_ROOT}/${BACKUP_DATE}
LOG_FILE=${LOG_DIR}/rman_incremental_${TIMESTAMP}.log

##############################
# Create Directories
##############################

mkdir -p "${BACKUP_DIR}"
mkdir -p "${LOG_DIR}"

##############################
# Verify Oracle Home
##############################

if [ ! -d "$ORACLE_HOME" ]; then
    echo
    echo "ERROR: ORACLE_HOME does not exist."
    echo
    exit 1
fi

##############################
# Verify RMAN
##############################

command -v rman >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo
    echo "ERROR: RMAN executable not found."
    echo
    exit 1
fi

##############################
# Verify Listener
##############################

lsnrctl status >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo
    echo "ERROR: Listener is not running."
    echo
    exit 1
fi

##############################
# Verify Database Status
##############################

DB_STATUS=$(sqlplus -s / as sysdba <<EOF
set pages 0 feedback off verify off heading off
select open_mode from v\$database;
exit;
EOF
)

DB_STATUS=$(echo "$DB_STATUS")

if [ "$DB_STATUS" != "READ WRITE" ]; then
    echo
    echo "ERROR: Database is not OPEN."
    echo "Current Status: $DB_STATUS"
    echo
    exit 1
fi

##############################
# Check Free Space
##############################

FREE_SPACE=$(df -BG "${BACKUP_ROOT}" | awk 'NR==2 {gsub("G","",$4);print $4}')

if [ "${FREE_SPACE}" -lt "${MIN_FREE_GB}" ]; then
    echo
    echo "ERROR: Less than ${MIN_FREE_GB}GB free in ${BACKUP_ROOT}"
    echo
    exit 1
fi

##############################
# Backup Information
##############################

START_TIME=$(date +%s)

echo
echo "========================================================="
echo "RMAN Level 1 Incremental Backup"
echo "========================================================="
echo "Database      : ${ORACLE_SID}"
echo "Backup Folder : ${BACKUP_DIR}"
echo "Started       : $(date)"
echo

##############################
# RMAN Backup
##############################

rman target / log="${LOG_FILE}" <<EOF

RUN {

ALLOCATE CHANNEL c1 DEVICE TYPE DISK;

BACKUP AS COMPRESSED BACKUPSET
SECTION SIZE ${SECTION_SIZE}
INCREMENTAL LEVEL 1
TAG 'LEVEL1_INCREMENTAL'
FORMAT '${BACKUP_DIR}/L1_%d_%T_%U.bkp'
DATABASE;

BACKUP AS COMPRESSED BACKUPSET
TAG 'ARCHIVELOG_L1'
FORMAT '${BACKUP_DIR}/ARCH_%d_%T_%U.bkp'
ARCHIVELOG ALL DELETE INPUT;

BACKUP AS COMPRESSED BACKUPSET
TAG 'CONTROLFILE_L1'
FORMAT '${BACKUP_DIR}/CTRL_%d_%T_%U.bkp'
CURRENT CONTROLFILE;

RELEASE CHANNEL c1;

}

EXIT;

EOF

RMAN_STATUS=$?

##############################
# Backup Summary
##############################

END_TIME=$(date +%s)
ELAPSED=$((END_TIME-START_TIME))

FILES=$(find "${BACKUP_DIR}" -type f | wc -l)

echo
echo "========================================================="

if [ ${RMAN_STATUS} -eq 0 ]; then
    echo "Status         : SUCCESS"
else
    echo "Status         : FAILED"
fi

echo "Database       : ${ORACLE_SID}"
echo "Backup Files   : ${FILES}"
echo "Backup Folder  : ${BACKUP_DIR}"
echo "Log File       : ${LOG_FILE}"
echo "Elapsed Time   : ${ELAPSED} seconds"
echo "Finished       : $(date)"

echo "========================================================="

exit ${RMAN_STATUS}