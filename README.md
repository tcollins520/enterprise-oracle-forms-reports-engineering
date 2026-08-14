# Enterprise Oracle Forms & Reports Engineering

**Oracle Database 23ai • Oracle Forms & Reports 14.1.2 • WebLogic 14.1.2 • JDK 21 • AWS • Terraform • Ansible • WLST**

## Overview

Enterprise Oracle Forms & Reports platform engineered on AWS to demonstrate the provisioning, automation, administration, and deployment of a production-style Oracle application environment.

The platform integrates **Oracle Database 23ai**, **Oracle Forms & Reports 14.1.2**, and **WebLogic Server 14.1.2**, with modern Infrastructure-as-Code and configuration-management practices.

The environment is designed and automated using **Terraform, Ansible, Bash/Shell scripting, and WebLogic Scripting Tool (WLST)**, with the goal of creating a reproducible Oracle application platform rather than a manually configured environment.

---

## Architecture

```text
                              AWS
                               │
                         Route 53 / ALB
                               │
                            HTTPS
                               │
                               ▼
                   ┌───────────────────────┐
                   │   WebLogic 14.1.2     │
                   │                       │
                   │   AdminServer         │
                   │   WLS_FORMS           │
                   │   WLS_REPORTS         │
                   │   Node Manager        │
                   └───────────┬───────────┘
                               │
                              JDBC
                               │
                               ▼
                   ┌───────────────────────┐
                   │ Oracle Database 23ai  │
                   │                       │
                   │ FORMSCDB              │
                   │ ├── FORMSAPP          │
                   │ └── FMWREP            │
                   └───────────────────────┘
```

---

## Technology Stack

| Layer          | Technology                                 |
| -------------- | ------------------------------------------ |
| Cloud          | AWS                                        |
| Database       | Oracle Database 23ai                       |
| Middleware     | Oracle Fusion Middleware / WebLogic 14.1.2 |
| Application    | Oracle Forms 14.1.2                        |
| Reporting      | Oracle Reports 14.1.2                      |
| Java           | JDK 21                                     |
| Infrastructure | Terraform                                  |
| Configuration  | Ansible                                    |
| Automation     | Bash / Shell / WLST                        |
| Backup         | RMAN                                       |
| Networking     | VPC / ALB / Route 53                       |
| Security       | Security Groups / TLS / IAM                |

---

## Application

The project includes a demonstration **Employee Management System** built with Oracle Forms and Oracle Database.

### Application Modules

The application will provide:

* Employee search
* Employee creation
* Employee modification
* Employee deletion
* Employee details
* Department management
* Job management
* Employee history
* Oracle Reports integration

```
| Phase                               | Status                     |
| ----------------------------------- | -------------------------- |
| Architecture & stack                | ✅ Complete                 |
| Git repo / README                   | ✅ Complete                 |
| AWS infrastructure design           | ✅ Complete                 |
| DB EC2 server                   | ✅ Created                  |
| Application/WebLogic EC2 server | ✅ Created                  |
| VPC/networking                      | 🟡 Existing infrastructure |
| Linux prerequisites                 | ⏳ Next                     |
| JDK 21                              | ⏳                          |
| Oracle Database 23ai                | ⏳                          |
| FMW/WebLogic 14.1.2                 | ⏳                          |
| Forms 14.1.2                        | ⏳                          |
| Reports 14.1.2                      | ⏳                          |
| Application                         | ⏳                          |
| Automation                          | ⏳                          |
| ALB/HTTPS                           | ⏳                          |
| Monitoring/backup                   | ⏳                          |

```


### Database Model

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

---

## Oracle Reports

The project includes operational and management reports generated from Oracle Database 23ai.

### Planned Reports

* Employee Directory
* Department Employee Roster
* Employee Salary Report
* Employee History
* Department Summary

The Forms application will provide report-launching functionality so users can generate reports directly from the application workflow.

```text
Oracle Forms
     │
     │ Report Request
     ▼
Oracle Reports
     │
     │ Query
     ▼
Oracle Database 23ai
     │
     ▼
Report Output
```

> **Note:** Oracle Reports is a deprecated Oracle technology. This project therefore also demonstrates enterprise legacy-platform administration and modernization considerations.

---

## Infrastructure as Code

The environment follows an **Infrastructure-as-Code-first** approach.

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
WebLogic / Forms / Reports
```

Prerequisites are validated and automated **before Oracle software installation**, ensuring the environment can be reproduced consistently.

---

## Project Phases

### 1. AWS Infrastructure

* VPC
* Networking
* Subnets
* Security Groups
* EC2
* Application Load Balancer
* Route 53
* ACM / TLS

### 2. Linux Foundation

* OS validation
* Required packages
* Users and groups
* Filesystems
* Kernel configuration
* Resource limits
* Time synchronization
* Oracle prerequisites

### 3. Oracle Database 23ai

* Oracle Database installation
* CDB/PDB architecture
* Oracle Net Listener
* Database services
* Application schema
* Database security
* RMAN backup

### 4. Fusion Middleware 14.1.2

* Fusion Middleware Infrastructure
* Repository Creation Utility
* WebLogic domain
* AdminServer
* Managed Servers
* Node Manager
* JDBC Data Sources

### 5. Oracle Forms & Reports

* Forms Services
* Reports Services
* Forms runtime
* Reports Server
* Database connectivity
* Application deployment

### 6. Application Development

* Employee Management application
* Employee search
* Employee maintenance
* Department management
* Job management
* Employee history

### 7. Reporting

* Employee Directory
* Department Roster
* Salary Report
* Employee History
* Department Summary
* Forms-to-Reports integration

### 8. Automation

* Terraform
* Ansible
* Bash / Shell scripting
* WLST
* Automated validation
* Automated deployment

### 9. Security & Networking

* Private database access
* AWS Security Groups
* WebLogic security
* Database security
* TLS
* ALB
* Route 53

### 10. Operations

* Monitoring
* Logging
* RMAN backup
* Recovery testing
* Patching
* Troubleshooting
* Operational runbooks

---

## Repository Structure

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

## Engineering Focus

This project demonstrates hands-on engineering across:

**Oracle Database • Oracle Forms • Oracle Reports • WebLogic • Fusion Middleware • Linux • AWS • Terraform • Ansible • WLST • Oracle Multitenant • JDBC • RMAN • Networking • Security • Monitoring**

The goal is to combine **traditional enterprise Oracle application technologies with modern cloud and Infrastructure-as-Code practices**.

---

## Target Environment

The initial deployment consists of two AWS servers:

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
    └── Node Manager
```

The platform will be progressively enhanced with:

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
Oracle Forms / WebLogic
    │
    ▼
Oracle Database 23ai
```

---

## Engineering Principles

### Infrastructure as Code

AWS infrastructure is provisioned using Terraform rather than manually created resources.

### Configuration as Code

Operating-system and middleware configuration is automated using Ansible.

### Middleware Automation

WebLogic administration and configuration are automated using WLST.

### Validation Before Installation

Oracle prerequisites are validated before Oracle software installation begins.

### Secure by Default

Database services remain private and administrative interfaces are restricted.

### Reproducibility

The environment is designed to be rebuilt using source-controlled infrastructure and configuration.

### Operational Readiness

The project includes monitoring, backup, recovery, troubleshooting, patching, and operational procedures.

---

## Project Outcome

The completed platform will demonstrate the complete lifecycle of an enterprise Oracle application environment:

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
```

The final environment combines **enterprise Oracle application technologies with modern AWS, Infrastructure-as-Code, automation, security, and operational engineering practices**.
