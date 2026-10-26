# ስራልኝ (Seralegn) — Localized Gig Economy Platform

> **A Demand-Led, Task-Based Gig Economy Platform for Ethiopia**

[![Platform](https://img.shields.io/badge/Platform-Mobile%20%7C%20Web-blue)](#2-architecture--technology-stack)
[![Backend](https://img.shields.io/badge/Backend-Supabase%20%2B%20PostgreSQL-emerald)](#2-architecture--technology-stack)
[![Payment](https://img.shields.io/badge/Payment-Chapa-green)](#2-architecture--technology-stack)
[![Status](https://img.shields.io/badge/Status-v1.0.0-orange)](#1-project-overview)

---

## 💡 Demo Video
🎥 Watch our project walkthrough and feature demonstration: **[demo video](https://drive.google.com/file/d/1VfOjQVX1YZgzALH9VEwM04CkcBdpLa09/view?usp=drivesdk)**

---

## 📋 Table of Contents
1. [Project Overview](#1-project-overview)
2. [Key Features](#2-key-features)
3. [Architecture & Technology Stack](#3-architecture--technology-stack)
4. [User Roles & Workflows](#4-user-roles--workflows)
5. [Monetization & Subscription Model](#5-monetization--subscription-model)
6. [Identity, Security & Trust](#6-identity-security--trust)
7. [System Requirements & Operating Environment](#7-system-requirements--operating-environment)

---

## 1. Project Overview

**ስራልኝ (Seralegn)** is a mobile-first, localized gig economy platform designed for the Ethiopian market. It bridges the gap between clients needing short-term physical repairs or tasks (such as plumbing, electrical work, carpentry, and painting) and verified local service professionals.

Instead of relying on informal referrals, street brokers, or static worker profiles, Seralegn operates on a **demand-led bounty model**:
* **Clients** post specific tasks with detailed descriptions, photos, set budgets (in ETB), and precise GPS locations.
* **Workers** discover open tasks within a 3–5 km radius via an interactive **Job Radar**, inspect the job on-site, and execute the task.

---

## 2. Key Features

### 📲 2.1 Client Features (Mobile App)
* **Job Creation:** Post tasks by category (plumbing, electrical, painting, etc.) with description, photos, budget in ETB, and pinned location.
* **Location Pinning:** Precision GPS mapping for accurate on-site discovery.
* **Job Tracking:** Live status monitoring (`Draft` ➔ `Posted` ➔ `Claimed` ➔ `Inspected` ➔ `In Progress` ➔ `Completed` ➔ `Finalized`).
* **Cancellation Control:** Mutual agreement cancellation options before physical work begins.

### 👷 2.2 Worker Features (Mobile App)
* **Job Radar:** Proximity-based discovery tool showing available jobs within a **3–5 km radius**.
* **Instant Claiming:** Review job scope, location, and photos, then claim tasks instantly.
* **On-Site Inspection:** Formalize scope agreement with the client prior to starting work.
* **Earnings & Subscription Tracker:** Track active feed access, subscription status, and completed tasks.

### ⚙️ 2.3 Administrative Features (Web Dashboard)
* **User Overview:** Centralized monitoring of active clients and registered workers.
* **System Control:** Administrative oversight of overall application workflows, system health, and transaction logs.
* **Transaction Audit:** Immutable financial logs covering worker subscription payments and system usage.

---

## 3. Architecture & Technology Stack

| Layer / Module | Technology / Tool | Description & Purpose |
| :--- | :--- | :--- |
| **Frontend (Users)** | **React** | Mobile-first responsive web application for clients and workers. |
| **Frontend (Admin)** | **React** | Web dashboard for system management, monitoring, and information. |
| **Backend Service** | **Supabase** | BaaS providing JWT authentication, database access, and storage. |
| **Database** | **PostgreSQL + PostGIS** | Spatial database extension enabling high-performance `ST_DWithin` proximity queries for Job Radar. |
| **Payments** | **Chapa API** | Payment gateway supporting Telebirr, CBE Birr, and local debit/credit card transactions. |
| **Location Services** | **HTML5 Geolocation / Device GPS** | Enables real-time coordinate mapping and proximity job matching. |

---

## 4. User Roles & Workflows

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Client  │ ──────> │  Worker  │ ──────> │  Admin   │
│ (Mobile) │         │ (Mobile) │         │  (Web)   │
└──────────┘         └──────────┘         └──────────┘
```

### 👤 Client Workflow
1. **Register/Sign In** on the mobile application.
2. **Create & Publish Job** with description, photos, ETB budget, and GPS map pin.
3. **Coordinate** with a nearby worker who claims the task.
4. **Conduct On-Site Inspection** to verify job requirements and terms.
5. **Approve Completion** once the physical task is executed.

### 🛠️ Worker Workflow
1. **Register** and complete **Fayda QR Identity Scanning**.
2. **Subscribe** to an active plan (Weekly / Monthly / Quarterly) via Chapa to enable job feeds.
3. **Browse Job Radar** to find active tasks within a 3–5 km radius.
4. **Claim Task & Inspect** the job site in person with the client.
5. **Update Status** to `In Progress` and complete the physical work.
6. **Mark Completed** to trigger client approval.

### 🛡️ Administrator Workflow
1. **Log in** to the secure Web Dashboard.
2. **Monitor Users** (client and worker lists and operational status).
3. **Track Activity** across platform job postings, transaction logs, and financial flows.

---

## 5. Monetization & Subscription Model

Seralegn employs a **Worker Subscription Model** integrated directly with the **Chapa** payment gateway:

* **Subscription Tiers:** Workers choose between **Weekly**, **Monthly**, or **Quarterly** subscription plans.
* **Feed Access:** Active subscriptions unlock access to the **Job Radar** and live job feeds in their geographic area.
* **Direct Earnings:** Service charges between client and worker are settled directly upon task completion.

---

## 6. Identity, Security & Trust

* **Fayda ID Integration:** Instant worker identity verification via **Fayda QR Code Scanning**.
* **On-Site Inspection Safeguard:** Mandatory pre-work inspection ensures both parties agree on scope and pricing before work begins.
* **Data Security & Privacy:** HTTPS/TLS 1.3 encryption in transit and PostgreSQL **Row-Level Security (RLS)** ensuring isolated access to user data.
* **Audit Trails:** Transaction logging for all system activities, subscriptions, and status transitions.

---

## 7. System Requirements & Operating Environment

* **Clients & Workers:** Modern mobile browsers or Progressive Web App (PWA) on Android / iOS with active GPS capabilities.
* **Network Constraints:** Optimized for reliable operation over low-bandwidth / intermittent 3G/4G cellular networks across urban and semi-urban Ethiopia.
* **Language & Localization:** English primary interface with planned multi-language (Amharic & regional languages) expansion.


## 8. Group members



## Phase 01 (In camp)

## Backend Developer 

1. Hermon Ermias CTC-135-26 (nieiamsi)

2. Leul mekonnen CTC-5687-26 (Leul0M)
## Frontend Developer 

3. Mekonen Gebreslassie CTC-1288-26 (mekonen-4)

4. Mekiya Sultan CTC-1379-26 (mekiyasultan01-hub)
## Mobile App Developer 

5. Malchiel Dawit CTC-210-26 (malchiel-d)

---

## Phase 02 (Out of camp) 

## Mobile App Developer

1. Hermon Ermias CTC-135-26 (nieiamsi)

2. Malchiel Dawit CTC-210-26 (malchiel-d)
## Frontend Developer

1. Kokebe Aschalew CTC-3609-26 (mastars-z)

2. Mekiya Sultan CTC-5687-26 (mekiyasultan01-hub)
## Backend Developer 

1. Hermon Ermias CTC-135-26 (nieiamsi)


## 9. Classroom of Mohammadawal Ahmed (Room 4) Group 1
