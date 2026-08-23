# Enterprise Oracle Forms & Reports Engineering

**Oracle Database 23ai • Oracle Forms & Reports 14.1.2 • WebLogic Server
14.1.2 • JDK 17 • AWS • Terraform • Ansible • WLST**

## Project Status — 2026-08-22

The new **app03** Forms/Reports platform is deployed and validated through the
WebLogic, Forms, Reports, database, and application-artifact layers.

Validation evidence confirms:
```
- Oracle Database 23ai / FORMSCDB / FORMSPDB is operational.
- RMAN Level 0 full and Level 1 incremental backups completed successfully.
- The `EMPLOYEE_APP` schema is present in `FORMSPDB`.
- `EMPLOYEES` and `DEPARTMENTS` tables are present and their definitions were validated.
- WebLogic `AdminServer`, `WLS_FORMS`, `WLS_REPORTS`, and Node Manager are running.
- Forms servlet on port `9501` returns HTTP 200.
- Reports servlet on port `9512` is deployed and responding.
- Reports Server / `rwEng-0` is running and ready.
- The clean-room Employee Management Forms source was compiled successfully
  from `.fmb` to `.fmx` and the compiled artifact was placed in the deployment directory.
```

The remaining application-level milestone is the interactive Forms runtime launch
and final Forms → Reports execution using the Employee Management application.
OHS/ALB front-end integration remains a subsequent production front-end task.

# Architecture

## Current platform

```text
                                  AWS
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
          ┌───────────────────┐         ┌────────────────────────┐
          │   Database EC2    │         │   Application EC2      │
          │                   │         │                        │
          │ Oracle Database   │◄───────►│ WebLogic Server 14.1.2│
          │ 23ai              │  JDBC   │                        │
          │                   │         │ AdminServer             │
          │                   │         │ WLS_FORMS               │
          └───────────────────┘         │ WLS_REPORTS             │
                                        │ Node Manager             │
                                        │ Oracle Forms 14.1.2      │
                                        │ Oracle Reports 14.1.2    │
                                        │ OHS 14.1.2               │
                                        └────────────────────────┘
```

### Application server
```
  Component     Value
  ------------- --------------------------------------------
  Host          `formsprod-app03`
  Private IP    `10.20.2.206`
  Domain        `formsprod`
  Domain Home   `/u01/app/oracle/config/domains/formsprod`
  Oracle Home   `/u01/app/oracle/product/fmw_14.1.2`
  Java          `/u01/app/java/jdk-17.0.12`
```

### WebLogic topology
```
  Component        HTTPS / SSL Port Status
  -------------- ------------------ ------------
  AdminServer                `9002` ✅ Running
  WLS_FORMS                  `9501` ✅ Running
  WLS_REPORTS                `9512` ✅ Running
  Node Manager               `5556` ✅ Running
  ```

Managed-server administration ports:
```
-   `WLS_FORMS` --- `9991`
-   `WLS_REPORTS` --- `9992`
```
## Current Status

```text
Component                           Status
----------------------------------- --------------------------------------------
AWS infrastructure                  ✅
Linux / JDK foundation              ✅
Fusion Middleware 14.1.2            ✅
WebLogic 14.1.2                     ✅
RCU repository                      ✅
WebLogic domain                     ✅
Node Manager                        ✅ Running
AdminServer                         ✅ Running
WLS_FORMS                           ✅ Running
Forms servlet                       ✅ HTTP 200
Forms test.fmx resolution           ✅ Validated
WLS_REPORTS                         ✅ Running
Reports Tools instance              ✅
Reports directory structure         ✅
Reports servlet                     ✅ HTTP 200
Reports Server / rwEng-0            ✅ Running / Ready
Reports OPSS/JPS authorization      ✅ Resolved
RW_ADMINISTRATOR authorization      ✅ weblogic granted
Employee database schema            ✅ Validated
Employee Management .fmb/.fmx      ✅ Compiled / deployed
Interactive Forms runtime           ⏳ Final validation
Forms → Reports end-to-end          ⏳ Final validation
OHS integration                     ⏳ Planned
```
```
----------------------------------- ------------------------------------
AWS infrastructure                  ✅
Linux / JDK foundation              ✅
Fusion Middleware 14.1.2            ✅
WebLogic 14.1.2                     ✅
RCU repository                      ✅
WebLogic domain                     ✅
Node Manager                        ✅
AdminServer                         ✅
WLS_FORMS                           ✅
Forms servlet                       ✅ Validated
Forms test.fmx resolution           ✅ Validated
WLS_REPORTS                         ✅
Reports Tools instance              ✅
Reports directory structure         ✅
Reports servlet                     ✅ HTTP 200
Reports Server / rwEng-0            ✅ Running / Ready
Reports OPSS/JPS authorization      ✅ Resolved
RW_ADMINISTRATOR authorization      ✅ weblogic granted
OHS integration                     ⏳ Planned
Employee Management application     ⏳ Next
Final Forms → Reports integration   ⏳ Application-dependent
---

### Oracle Configuration Method

The Oracle Forms and Reports platform was configured using Oracle's graphical configuration wizards rather than manually assembling the domain configuration.

The build used the Oracle-provided wizards to create and configure:

- **WebLogic domain** — created with the WebLogic Configuration Wizard
- **Oracle Forms** — configured through the Forms configuration wizard
- **Oracle Reports** — configured through the Reports configuration wizard
- **Repository Creation Utility (RCU)** — used to create the required Fusion Middleware repository schemas

WLST and command-line tools were then used for validation, lifecycle management, and targeted configuration/troubleshooting.

## What is Completed

### WebLogic / Forms

-   Created the `formsprod` domain.
-   Configured AdminServer, `WLS_FORMS`, and `WLS_REPORTS`.
-   Configured Node Manager and verified managed-server lifecycle
    control.
-   Configured WebLogic SSL.
-   Validated the Forms servlet directly through WebLogic.
---

```markdown
## Employee Management Demonstration

The clean-room **Employee Management** application is being built specifically
for this portfolio project. No proprietary company Forms source is used.

The database layer and Forms build/deployment artifacts are now validated:

- Schema: `EMPLOYEE_APP`
- PDB: `FORMSPDB`
- Tables: `EMPLOYEES`, `DEPARTMENTS`
- Forms source: `/home/oracle/employee-management/source/test.fmb`
- Compiled Forms artifact: `/home/oracle/employee-management/compiled/test.fmx`
- Deployment artifact: `/home/oracle/employee-management/deploy/test.fmx`

The remaining step is to prove the interactive runtime session and complete the
Forms → Reports workflow with the Employee Management application.

The application demonstrates the real operational workflow:

### Reports

Created the Reports Tools instance:

``` text
reptools_formsprod_app03
```

Initialized the Reports directory structure:

``` text
$DOMAIN_HOME/reports/
├── bin
├── cache
├── fonts
├── plugins
└── server
```

Verified the Reports servlet:

``` text
https://10.20.2.206:9512/reports/rwservlet/showenv
```

Result:

``` text
HTTP 200
```

The servlet is therefore deployed and responding.

```markdown
## Reports Authorization — Resolved

The Reports/JPS authorization issue encountered during validation was resolved
through the Reports application policy and WebLogic identity store.

The `reports` application stripe contains the Oracle Reports roles:

```text
RW_OPERATOR
RW_ADMINISTRATOR
RW_BASIC_USER
RW_POWER_USER
RW_MONITOR
RW_DEVELOPER
---

The WebLogic weblogic user was granted membership in:

RW_ADMINISTRATOR

WLST confirmed the effective Reports permissions:

oracle.reports.server.ReportsPermission
Target: report=* server=* destype=* desformat=* allowcustomargs=true
Actions: *


oracle.reports.server.WebCommandPermission
Target: webcommands=* server=*
Actions: execute

Reports validation also confirmed:
```
WLS_REPORTS       RUNNING
Reports servlet   HTTP 200
Reports Server    rep_wls_reports_formsprod-app03
Reports engine    rwEng-0 READY
```

## Important Configuration

Reports servlet configuration:

``` text
$DOMAIN_HOME/config/fmwconfig/servers/WLS_REPORTS/applications/reports_14.1.2/configuration/rwservlet.properties
```

Current settings include:

``` xml
<server>rep_wls_reports_formsprod-app03</server>
<singlesignon>no</singlesignon>
<inprocess>yes</inprocess>
<webcommandaccess>L2</webcommandaccess>
```

JPS policy:

``` text
$DOMAIN_HOME/config/fmwconfig/system-jazn-data.xml
```

Reports application:

``` text
reports
```

Reports administrator role:

``` text
rw_administrator
```

## Validation Commands

### WebLogic / Forms / Reports runtime

Check managed-server state:

```text
wls:/nm/formsprod> nmServerStatus('WLS_FORMS')
wls:/nm/formsprod> nmServerStatus('WLS_REPORTS')
```

Check listeners:

```bash
ss -lntp | grep -E '5556|9002|9501|9512|9991|9992'
```

Validate the Forms servlet:

```bash
curl -k -I --max-time 10 \
  "https://10.20.2.206:9501/forms/frmservlet"
```

Expected:

```text
HTTP 200
content-type: text/html
```

Validate the Reports servlet:

```bash
curl -k -I --max-time 10 \
  "https://10.20.2.206:9512/reports/rwservlet/showenv"
```

Expected:

```text
HTTP 200
```

Validate the Reports engine:

```bash
pgrep -af 'RWEngine|rwEng'
```

Expected process includes:

```text
oracle.reports.engine.RWEngine
name=rwEng-0
server=rep_wls_reports_formsprod-app03
```

### Employee Management database

Connect to the application schema:

```bash
sqlplus EMPLOYEE_APP@db02:1521/FORMSPDB
```

Validate schema, database, and service:

```sql
SELECT
    USER AS schema_name,
    SYS_CONTEXT('USERENV','DB_NAME') AS database_name,
    SYS_CONTEXT('USERENV','SERVICE_NAME') AS service_name
FROM dual;
```

Validate application tables:

```sql
SELECT table_name, num_rows
FROM user_tables
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
ORDER BY table_name;
```

Validate definitions:

```sql
DESC DEPARTMENTS;
DESC EMPLOYEES;
```

### Employee Management Forms artifacts

```bash
find /home/oracle/employee-management/source -type f -name '*.fmb' -ls
find /home/oracle/employee-management/compiled -type f -name '*.fmx' -ls
find /home/oracle/employee-management/deploy -type f -name '*.fmx' -ls
```

The current evidence shows `test.fmb` compiled successfully to `test.fmx`
and the compiled artifact was copied into the deployment directory.



``` text
wls:/nm/formsprod> nmServerStatus('WLS_FORMS')
wls:/nm/formsprod> nmServerStatus('WLS_REPORTS')
```

Check listeners:

``` bash
ss -lntp | grep -E '5556|9002|9501|9512|9991|9992'
```

Check Reports servlet:

``` bash
curl -k -i \
"https://10.20.2.206:9512/reports/rwservlet/showenv"
```

```markdown
## Next Steps

1. Complete the interactive Employee Management Forms runtime validation.
2. Create/deploy the Employee Report if not already completed.
3. Execute the report through the real Forms → Reports workflow.
4. Validate report output and capture final end-to-end evidence.
5. Return to OHS integration.
6. Complete final production hardening and automation.


# Engineering Focus

This project demonstrates hands-on engineering across:

**Oracle Database • Oracle Forms • Oracle Reports • WebLogic • Fusion Middleware • Linux • AWS • Terraform • Ansible • WLST • Oracle Multitenant • JDBC • RMAN • Networking • TLS • OHS**

The goal is to combine traditional enterprise Oracle application technologies with modern cloud, Infrastructure-as-Code, automation, security, and operational engineering practices.

---

# Target Environment

The current two-server deployment is:

```text
AWS
│
├── Database Server
│   └── Oracle Database 23ai
│
└── Application Server
    ├── WebLogic 14.1.2
    ├── AdminServer
    ├── WLS_FORMS
    ├── WLS_REPORTS
    ├── Node Manager
    └── Oracle HTTP Server
```

The target production-style front-end architecture is:

```text
Route 53
    │
    ▼
Application Load Balancer
    │
    ▼
HTTPS / TLS
    │
    ▼
Oracle HTTP Server
    │
    ├── Oracle Forms / WebLogic
    │
    └── Oracle Reports / WebLogic
              │
              ▼
       Oracle Database 23ai
```

# Engineering Principles

## Infrastructure as Code

AWS infrastructure should be provisioned through Terraform rather than manual creation.

## Configuration as Code

Operating-system and middleware configuration should be automated using Ansible and scripts.

## Middleware Automation

WebLogic administration and lifecycle operations should be automated using WLST.

## Validation Before Installation

Oracle prerequisites must be validated and installed **before Oracle software installation begins**.

This is a specific lesson from the current build and is a major requirement for the next automation iteration.

## Secure by Default

Database services should remain private and administrative interfaces should be restricted.

## Reproducibility

The environment should be rebuildable from source-controlled infrastructure and configuration.

## Incremental Validation

Each platform layer should be validated independently:

```text
AWS
  ↓
Linux
  ↓
Java
  ↓
Oracle Database
  ↓
Fusion Middleware
  ↓
WebLogic
  ↓
Forms / Reports
  ↓
OHS
  ↓
ALB / DNS
```

This approach prevents a front-end component such as OHS from masking problems in the underlying application tier


# Project Outcome

The completed platform will demonstrate the lifecycle of an enterprise Oracle application environment:

```text
AWS Infrastructure
        │
        ▼
Linux Foundation
        │
        ▼
Oracle Database 23ai
        │
        ▼
Fusion Middleware 14.1.2
        │
        ▼
WebLogic Server 14.1.2
        │
        ├── Oracle Forms 14.1.2
        │
        └── Oracle Reports 14.1.2
                │
                ▼
        Employee Management System
                │
                ▼
       Production Front End
       OHS / ALB / Route 53
```

The final environment will combine **enterprise Oracle application technologies with AWS, Infrastructure-as-Code, automation, security, TLS, observability, backup/recovery, and operational engineering practices**.

---

## Current Milestone

**Platform foundation complete → Database validated → Forms/Reports services validated → Employee Management database/build/deployment validated → Interactive Forms runtime validation → Forms-to-Reports end-to-end validation → OHS/ALB production front end.**


## Engineering Lessons

The V2 build demonstrated that Oracle software prerequisites must be
validated before Oracle installation. The next automation iteration
should enforce:

``` text
Terraform
   ↓
AWS infrastructure
   ↓
OS prerequisite validation
   ↓
Required package installation
   ↓
Java validation
   ↓
Oracle software installation
   ↓
Domain / Forms / Reports configuration
   ↓
Validation
```

## Screenshot Documentation

The screenshot set focuses on successful configuration steps and the
troubleshooting changes that materially advanced the platform.
