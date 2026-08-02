# IIT Patna Campus Amenities Administration System

A relational database project developed for **CS354: Database Management Systems** at IIT Patna. This repository contains the conceptual design, logical design, SQL scripts, triggers, stored procedures, and test queries for managing campus amenities, specifically focusing on **Guest House** and **Market Shop** operations.

---

## 📌 Project Overview

The objective of this project is to model, implement, and maintain a relational database system for managing campus amenities at IIT Patna. The database system handles two major administrative domains:

1. **Guest House Management**:
   * Room reservation and availability tracking.
   * Guest category handling and automated bill generation.
   * Food service order tracking and billing.
   * Staff duty scheduling and operational expenditure monitoring.

2. **Market Shop Management**:
   * Shopkeeper profiles and security pass validity management.
   * Shop licensing, lease agreement periods, and extension tracking.
   * Monthly rent and utility (electricity) billing.
   * Pending dues and payment status tracking.
   * Customer feedback and shop performance evaluations.

---
**Database Engine:** Powered by Apache MySQL for transactional reliability and relational data storage.
## 📁 Repository Structure

Based on the repository layout:

```text
Guest-House-Booking/
├── Guest_House/         # SQL scripts, ER diagrams, schema & queries for Guest House domain
├── Market_shop/         # SQL scripts, ER diagrams, schema & queries for Market Shop domain
├── PJ Description.pdf   # Solution Description & specifications
├── Project_Code.txt     # Complete combined SQL scripts (DDL, DML, Triggers, Procedures)
└── README.md            # Project documentation
