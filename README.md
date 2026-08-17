# Enterprise Oracle Forms & Reports Engineering

**Oracle Database 23ai • Oracle Forms & Reports 14.1.2 • WebLogic Server 14.1.2 • SSL • JDK 17 • AWS • Terraform • Ansible • WLST**

---

## Overview

Oracle Database 23ai • Oracle Forms & Reports 14.1.2 • WebLogic Server 14.1.2 • SSL/TLS • JDK 17 • AWS • Terraform • Ansible • WLST

The current environment consists of two AWS EC2 servers:

- **Database server** — Oracle Database environment
- **Application server** — Oracle Fusion Middleware / WebLogic / Forms / Reports / OHS

The project intentionally combines traditional Oracle enterprise application technology with modern cloud and Infrastructure-as-Code practices.

> **Current status:** The core AWS, Linux, Oracle Fusion Middleware, WebLogic, Forms, Reports, Node Manager, and OHS platform components have been built and are being validated. The Employee Management application and production front-end architecture are still in progress.

---

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

## Current WebLogic topology

```text
Application Server: 10.20.2.27

AdminServer
    │
    └── HTTPS :9003

WLS_FORMS
    │
    └── HTTPS :7002

WLS_REPORTS
    │
    └── Runtime currently observed on :9002
        while WebLogic configuration reports :7003

Node Manager
    │
    └── controls WebLogic/OHS lifecycle
```

The `WLS_REPORTS` port discrepancy is currently being investigated and must be resolved before the Reports deployment is considered complete.

---

# Current Status Summary

| Component | Status |
|---|---|
| AWS EC2 infrastructure | ✅ |
| Application server | ✅ |
| Database server | ✅ |
| RMAN | ✅ |
| JDK 17.0.12 | ✅ |
| Fusion Middleware 14.1.2 | ✅ |
| WebLogic 14.1.2 | ✅ |
| AdminServer | ✅ |
| WLS_FORMS | ✅ |
| WLS_REPORTS | 🟡 |
| Node Manager | 🟡 OHS lifecycle status needs cleanup |
| Oracle Forms runtime | ✅ |
| Direct Forms servlet | ✅ HTTP 200 |
| Oracle Reports runtime | 🟡 |
| Reports servlet | ❌ 404 currently |
| OHS | 🟡 Running; deferred |
| OHS → Forms | ✅ Validated |
| OHS → Reports | 🟡 Deferred |
| Employee application | 🟡 In progress |
| Reports application | 🟡 In progress |
| Terraform automation | 🟡 In progress |
| Ansible automation | 🟡 In progress |
| Monitoring | ⏳ |
| ALB / Route 53 / production TLS | ⏳ |

---

---

# Technology Stack

| Layer | Technology | Current Status |
|---|---|---|
| Cloud | AWS | ✅ Built |
| Infrastructure | Terraform | 🟡 In use / continuing to document and automate |
| Configuration | Ansible | 🟡 Planned/being developed |
| Operating System | Linux | ✅ Application and database hosts provisioned |
| Database | Oracle Database 23ai | 🟡 Platform work in progress |
| Middleware | Oracle Fusion Middleware 14.1.2 | ✅ Installed |
| WebLogic | Oracle WebLogic Server 14.1.2 | ✅ Installed/configured |
| Java | JDK 17.0.12 | ✅ Installed |
| Forms | Oracle Forms 14.1.2 | ✅ Deployed and directly validated |
| Reports | Oracle Reports 14.1.2 | 🟡 Server running; servlet/application validation incomplete |
| OHS | Oracle HTTP Server 14.1.2 | 🟡 Running; front-end routing deferred |
| Automation | WLST / Bash | ✅ Actively used |
| Backup | RMAN | ✅ Completed |
| TLS | WebLogic/OHS SSL | 🟡 Test certificates currently in use |
| Load Balancing | ALB | ⏳ To complete |
| DNS | Route 53 | ⏳ To complete |
| Monitoring | Logging/monitoring | ⏳ To complete |

---

# What Has Been Completed

## 1. AWS Infrastructure

The initial two-server AWS environment has been created:

- Database EC2 instance
- Application/WebLogic EC2 instance
- Private networking
- Security-group-based connectivity
- Application server private IP: `10.20.2.27`

The repository and initial project architecture were also established.

---

## 2. Linux / Oracle Software Foundation

The application server has been prepared for Oracle middleware and Java.

The current WebLogic processes confirm:

```text
JDK:
 /u01/app/java/jdk-17.0.12

Oracle Home:
 /u01/app/oracle/product/fmw_14.1.2
```

A major engineering lesson from this build was that Oracle software prerequisites must be validated **before** Oracle installation. Missing build/linker prerequisites during an earlier installation attempt resulted in an incomplete Oracle Home.

This is therefore a major objective for the next automation iteration:

```text
Validate OS prerequisites
        │
        ▼
Install required packages
        │
        ▼
Validate Java
        │
        ▼
Install Oracle software
```

---

# 3. Oracle Fusion Middleware / WebLogic

Oracle Fusion Middleware 14.1.2 and WebLogic Server 14.1.2 have been installed.

The `formsprod` WebLogic domain has been created and configured.

Current domain components include:

```text
AdminServer
WLS_FORMS
WLS_REPORTS
Node Manager
OHS / ohs1
Forms / forms1
```

The WebLogic Administration Server is accessible over HTTPS on:

```text
https://10.20.2.27:9003
```

WLST has been successfully used to connect to the domain and manage servers through Node Manager.

---

# 4. WebLogic Managed Servers

## WLS_FORMS

`WLS_FORMS` is running successfully.

Current HTTPS listener:

```text
10.20.2.27:7002
```

The WebLogic log confirms:

```text
Started WebLogic Server independent Managed Server "WLS_FORMS"
Server state changed to RUNNING
```

---

## WLS_REPORTS

`WLS_REPORTS` can be started successfully through Node Manager.

Current runtime testing showed a listener on:

```text
10.20.2.27:9002
```

However, WebLogic configuration inspection through WLST reports:

```text
WLS_REPORTS
ListenAddress = ''
ListenPort    = 7003
```

This discrepancy is **not yet resolved**.

It is a current work item and must be reconciled before Reports deployment is considered complete.

---

# 5. Node Manager

Node Manager connectivity has been established successfully.

Examples:

```text
nmServerStatus('WLS_FORMS')
RUNNING
```

and:

```text
nmStart('WLS_REPORTS')
Successfully started server WLS_REPORTS
```

Node Manager is therefore operational for the WebLogic managed servers.

OHS currently reports:

```text
FAILED_NOT_RESTARTABLE
```

through:

```text
nmServerStatus('ohs1')
```

even though the OHS processes are actually running and listening.

This Node Manager/OHS lifecycle-state issue remains to be cleaned up.

---

# 6. Oracle Forms

Oracle Forms Services 14.1.2 has been configured and deployed.

The Forms managed server is:

```text
WLS_FORMS
```

with HTTPS listener:

```text
7002
```

The Forms servlet was successfully accessed directly through WebLogic:

```text
https://10.20.2.27:7002/forms/frmservlet
```

The direct request returned:

```text
HTTP 200 OK
```

with the Oracle Forms application HTML.

### Current conclusion

**Forms runtime is working independently of OHS.**

This is important because it allows the application deployment to continue without making OHS a prerequisite.

---

# 7. Oracle Reports

Oracle Reports Services has been installed/configured as part of the middleware platform.

`WLS_REPORTS` starts successfully through Node Manager.

However, the Reports application is **not yet considered complete**.

Direct testing of:

```text
/reports/rwservlet
```

against the currently running `WLS_REPORTS` listener returned:

```text
HTTP 404 Not Found
```

The same 404 was received when testing through OHS.

This proves that the current problem is not simply OHS routing.

### Reports work remaining

- Reconcile `9002` runtime vs `7003` WebLogic configuration
- Verify Reports application/servlet deployment
- Verify Reports Server configuration
- Verify `rwservlet`
- Verify database connectivity
- Test an actual report
- Integrate Reports with Forms

---

# 8. Oracle HTTP Server

OHS 14.1.2 has been installed and configured.

Current OHS listeners include:

```text
HTTPS :4443
HTTP  :7777
Admin :7779
```

The OHS HTTPS endpoint is functional.

The OHS wallet originally contained a test certificate for:

```text
CN=localhost
```

The WebLogic Forms certificate is signed by:

```text
CN=CertGenCA
```

`CertGenCA` was therefore added to the OHS wallet.

After this change, the Forms request through OHS successfully returned:

```text
HTTP 200 OK
```

for:

```text
/forms/frmservlet
```

This demonstrated that the OHS → WebLogic HTTPS trust path is working for Forms.

### Current OHS decision

OHS is **working sufficiently for later integration testing**, but it is being temporarily parked.

The application deployment will continue directly against WebLogic first.

OHS will be revisited after Forms and Reports are independently validated.

---

# Current Application Access

## Forms — direct WebLogic access

```text
https://10.20.2.27:7002/forms/frmservlet
```

Status:

**✅ Working**

## Forms — through OHS

```text
https://10.20.2.27:4443/forms/frmservlet
```

Status:

**✅ Previously validated with HTTP 200**

## Reports — direct WebLogic

Currently being investigated.

The running JVM has been observed on:

```text
https://10.20.2.27:9002
```

but WebLogic configuration reports:

```text
7003
```

Status:

**🟡 Not complete**

## Reports — through OHS

```text
https://10.20.2.27:4443/reports/
```

Status:

**🟡 Deferred**

---

# Application

The planned application is an **Employee Management System** built with Oracle Forms and Oracle Database.

## Planned Modules

- Employee search
- Employee creation
- Employee modification
- Employee deletion
- Employee details
- Department management
- Job management
- Employee history
- Oracle Reports integration

### Current status

The underlying Forms runtime is working, but the complete Employee Management application has **not yet been marked complete**.

Remaining work includes:

- Application schema validation
- Forms module deployment
- Application navigation
- Employee CRUD functionality
- Department functionality
- Job functionality
- Employee history
- Forms-to-Reports integration

---

# Database Model

The planned application data model is:

```text
DEPARTMENTS
     │
     └── EMPLOYEES
              │
              └── EMPLOYEE_HISTORY

JOBS
  │
  └── EMPLOYEES
```

Core tables:

```text
DEPARTMENTS
EMPLOYEES
JOBS
EMPLOYEE_HISTORY
```

Database/application schema deployment and final validation remain part of the application phase.

---

# Oracle Reports

Planned reports include:

- Employee Directory
- Department Employee Roster
- Employee Salary Report
- Employee History
- Department Summary

Target architecture:

```text
Oracle Forms
      │
      │ Report Request
      ▼
Oracle Reports
      │
      │ SQL
      ▼
Oracle Database 23ai
      │
      ▼
Report Output
```

Oracle Reports is a deprecated Oracle technology. The project intentionally demonstrates both enterprise legacy-platform administration and the operational considerations involved in maintaining and modernizing such platforms.

---

# Infrastructure as Code

The project is being developed toward an **Infrastructure-as-Code-first** model.

Target workflow:

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ▼
Ansible
    │
    ├── Linux prerequisites
    ├── Java
    ├── Oracle Database
    └── Middleware
    │
    ▼
Bash / Shell Automation
    │
    ▼
WLST
    │
    ▼
WebLogic / Forms / Reports / OHS
```

### Important engineering lesson

The current V2 build exposed a gap in the automation process: Oracle software installation was attempted before all required OS/build prerequisites were guaranteed.

The next version of the automation must therefore make prerequisite validation and installation a hard prerequisite for Oracle installation.

---

# Project Phases

## 1. AWS Infrastructure

- [x] AWS environment created
- [x] Database EC2 server created
- [x] Application/WebLogic EC2 server created
- [x] Networking/security foundation established
- [ ] Final Terraform resource coverage
- [ ] Application Load Balancer
- [ ] Route 53
- [ ] ACM certificate

---

## 2. Linux Foundation

- [x] Linux application server available
- [x] Java installed
- [x] Oracle software directories established
- [ ] Fully automated prerequisite validation
- [ ] Automated prerequisite package installation
- [ ] Final OS hardening
- [ ] Resource limits validation
- [ ] Time synchronization validation
- [ ] Final production readiness validation

---

## 3. Oracle Database 23ai

- [x] Database server provisioned
- [x] Final database installation validation
- [x] CDB/PDB architecture validation
- [x] Oracle Net listener validation
- [x] Database services
- [x] Application schema
- [x] Database security
- [x] RMAN backup
- [ ] Recovery testing

---

## 4. Fusion Middleware 14.1.2

- [x] Fusion Middleware installed
- [x] WebLogic installed
- [x] WebLogic domain created
- [x] AdminServer configured
- [x] WLS_FORMS configured
- [x] WLS_REPORTS configured
- [x] Node Manager configured
- [x] WebLogic SSL configured
- [ ] Final JDBC Data Source validation
- [ ] Final production hardening

---

## 5. Oracle Forms

- [x] Forms Services installed
- [x] Forms runtime configured
- [x] WLS_FORMS running
- [x] Direct Forms servlet validated
- [x] Forms HTTPS validated
- [x] OHS → Forms HTTPS path validated
- [ ] Deploy/finalize Employee Management application
- [ ] Application database integration validation
- [ ] User/application testing

---

## 6. Oracle Reports

- [x] Reports platform installed/configured
- [x] WLS_REPORTS can be started
- [ ] Resolve `9002` vs `7003` discrepancy
- [ ] Verify Reports deployment
- [ ] Verify `rwservlet`
- [ ] Verify Reports Server
- [ ] Database connectivity
- [ ] Execute an actual report
- [ ] Forms-to-Reports integration

---

## 7. Oracle HTTP Server

- [x] OHS installed
- [x] OHS process running
- [x] HTTPS listener configured on `4443`
- [x] OHS wallet configured
- [x] CertGenCA trusted by OHS
- [x] OHS → WLS_FORMS HTTPS path validated
- [ ] Clean up OHS Node Manager lifecycle status
- [ ] Finalize Forms routing
- [ ] Finalize Reports routing
- [ ] Production HTTPS port/certificate
- [ ] Move from test certificate to appropriate TLS certificate
- [ ] Final front-end validation

> **Current strategy:** OHS is temporarily deferred while direct WebLogic application deployment is completed.

---

## 8. Application Development

- [ ] Employee Management application
- [ ] Employee search
- [ ] Employee maintenance
- [ ] Department management
- [ ] Job management
- [ ] Employee history
- [ ] Forms navigation
- [ ] Application security
- [ ] End-to-end testing

---

## 9. Reporting

- [ ] Employee Directory
- [ ] Department Roster
- [ ] Salary Report
- [ ] Employee History
- [ ] Department Summary
- [ ] Forms-to-Reports integration
- [ ] Report execution testing

---

## 10. Automation

- [x] Terraform repository established
- [x] WLST used for WebLogic administration
- [x] Bash automation used during platform build
- [x] Complete Terraform coverage
- [ ] Ansible prerequisite automation
- [ ] Ansible Oracle installation automation
- [ ] Middleware automation
- [ ] Automated validation
- [ ] Automated deployment
- [ ] Idempotent rebuild/testing

---

## 11. Security & Networking

- [x] AWS security groups
- [x] Private database/application networking foundation
- [x] WebLogic SSL
- [x] OHS SSL
- [x] OHS trust of WebLogic CertGenCA
- [ ] Production certificates
- [ ] Final least-privilege security-group rules
- [ ] ALB/HTTPS architecture
- [ ] Route 53
- [ ] Administrative access hardening
- [ ] Secrets/password management review

---

## 12. Operations

- [x] RMAN backup
- [ ] Recovery testing
- [ ] Patching procedures
- [ ] Health checks
- [ ] Startup/shutdown runbooks
- [ ] Node Manager operational runbook
- [ ] OHS operational runbook
- [ ] Forms operational runbook
- [ ] Reports operational runbook
- [ ] Troubleshooting documentation
- [ ] Monitoring
- [ ] Centralized logging

---

# Repository Structure

The repository is organized around infrastructure, configuration, database, middleware, application, and operational automation.

```text
enterprise-oracle-forms-reports-engineering/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── env/
│       └── production.tfvars
│
├── ansible/
│   ├── inventory/
│   │   └── production
│   ├── playbooks/
│   │   ├── prerequisites.yml
│   │   ├── database.yml
│   │   └── middleware.yml
│   └── roles/
│
├── database/
│   ├── schemas/
│   ├── scripts/
│   └── rman/
│
├── weblogic/
│   ├── wlst/
│   └── scripts/
│
├── forms/
│
├── reports/
│
├── scripts/
│
├── docs/
│
└── README.md
```

> The repository structure above represents the intended organization. Individual automation components are still being built/refined.

---

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

The immediate implementation strategy is intentionally different:

```text
Browser / Test Client
        │
        ├──► WLS_FORMS :7002
        │
        └──► WLS_REPORTS
```

This allows the application tier to be validated independently before OHS/ALB integration is finalized.

---

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

This approach prevents a front-end component such as OHS from masking problems in the underlying application tier.

# Immediate Next Steps

The next implementation sequence is intentionally:

```text
1. Resolve WLS_REPORTS port discrepancy
              ↓
2. Verify Reports deployment / rwservlet
              ↓
3. Test an actual Oracle Report
              ↓
4. Complete Employee Management application
              ↓
5. Validate Forms → Reports integration
              ↓
6. Return to OHS
              ↓
7. Finalize OHS Forms/Reports routing
              ↓
8. Production TLS
              ↓
9. ALB / Route 53
              ↓
10. Monitoring / RMAN / operational runbooks
              ↓
11. Automate the complete build with Terraform + Ansible + WLST
```

---

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

**Platform foundation complete → Forms runtime validated → Reports troubleshooting in progress → Application deployment next → OHS/ALB production front end afterward.**
