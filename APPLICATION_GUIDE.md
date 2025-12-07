# TechEX - Application Guide

> **[← Back to README](README.md)** (Installation & Deployment)

This guide explains how to use the TechEX Parcel Management web application.

---

## Table of Contents

1. [Overview](#overview)
2. [Pages & Features](#pages--features)
3. [API Endpoints](#api-endpoints)
4. [Data Persistence](#data-persistence)

---

## Overview

TechEX is a parcel tracking and management system built with Flask. It allows you to:

- **Track parcels** from dispatch to delivery
- **Manage shipments** with full CRUD operations
- **View statistics** on your parcel data
- **Access data via API** for integration with other systems

### Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | HTML, CSS, JavaScript |
| Backend | Python Flask 3.0 |
| Database | JSON file (NFS-backed for persistence) |
| Container | Docker |
| Orchestration | Kubernetes |

---

## Pages & Features

### Home Page

**URL:** `/`

The landing page displays:
- Welcome message
- Quick statistics overview
- Navigation to all features

---

### View All Parcels

**URL:** `/parcels`

A table showing all parcels in the system:

| Column | Description |
|--------|-------------|
| Tracking Number | Unique parcel identifier |
| Sender | Who sent the parcel |
| Receiver | Who receives the parcel |
| Origin | Dispatch location |
| Destination | Delivery location |
| Status | Pending or Delivered |
| Cost | Shipping cost in ₪ |
| Weight | Package weight in kg |

**Actions:**
- **Edit** - Modify parcel details
- **Remove** - Delete a parcel

---

### Add New Parcel

**URL:** `/add_parcel`

Create a new parcel by filling in the form:

| Field | Description | Example |
|-------|-------------|---------|
| Tracking Number | Unique ID | TXP-2025-007 |
| Sender | Sender name | Shenzhen Express |
| Receiver | Recipient name | John Doe |
| Origin | Where from | Shenzhen, China |
| Destination | Where to | Tel Aviv, Israel |
| Cost (₪) | Shipping cost | 25.50 |
| Weight (kg) | Package weight | 1.5 |
| Dispatch Date | Date sent | 2025-12-01 |

Click **Add Parcel** to save.

---

### Edit Parcel

**URL:** `/edit_parcel/<id>`

Update an existing parcel:

- **Status** - Change between Pending and Delivered
- **Delivery Date** - Set when delivered
- **Cost** - Update shipping cost
- **Weight** - Update package weight

---

### Statistics

**URL:** `/statistics`

View aggregated data:

| Metric | Description |
|--------|-------------|
| Total Parcels | Number of parcels in system |
| Delivered | Count of delivered parcels |
| Pending | Count of pending parcels |
| Total Cost | Sum of all shipping costs |
| Total Weight | Sum of all package weights |
| Average Cost | Mean shipping cost |
| Average Weight | Mean package weight |
| Delivery Rate | Percentage of parcels delivered |

---

## API Endpoints

### Get All Parcels

```bash
GET /api/parcels
```

**Response:**
```json
[
  {
    "id": "1",
    "tracking_number": "TXP-2025-001",
    "sender": "Shanghai Express",
    "receiver": "David Cohen",
    "origin": "Shanghai, China",
    "destination": "Tel Aviv, Israel",
    "status": "delivered",
    "cost": 24.50,
    "weight": 1.8,
    "dispatch_date": "2025-11-15",
    "delivery_date": "2025-11-28"
  }
]
```

---

### Health Check

```bash
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "version": "2.0",
  "timestamp": "2025-12-01T12:00:00",
  "data_persistence": true
}
```

Used by Kubernetes for liveness probes.

---

### Readiness Check

```bash
GET /ready
```

**Response:**
```json
{
  "status": "ready"
}
```

Used by Kubernetes for readiness probes.

---

## Data Persistence

Parcel data is stored in a JSON file at `/data/parcels.json` inside the container.

In the Kubernetes deployment:
- Data is stored on an **NFS share** on the master node
- Location: `/srv/nfs/techex-data/parcels.json`
- All pods share the same data via NFS mount
- Data survives pod restarts and redeployments

### Checking Data Manually

```bash
# SSH to master node
ssh -i techex.pem ubuntu@<master-ip>

# View the data file
cat /srv/nfs/techex-data/parcels.json
```

---

## Quick Reference

| Action | URL |
|--------|-----|
| Home | `/` |
| View Parcels | `/parcels` |
| Add Parcel | `/add_parcel` |
| Edit Parcel | `/edit_parcel/<id>` |
| Statistics | `/statistics` |
| Health Check | `/health` |
| Readiness | `/ready` |
| API - Parcels | `/api/parcels` |

---

**📦 Happy Parcel Tracking!**
