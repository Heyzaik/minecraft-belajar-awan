# Minecraft on AWS (ClickOps → Terraform → Data Engineering)

## Project Overview

This project documents an end‑to‑end, production‑minded setup of a **Minecraft: Java Edition server on AWS**, starting with **ClickOps** for learning and validation, then migrating to **Infrastructure as Code (Terraform)**, and finally using **Minecraft server logs as a Data Engineering project** to analyze player behavior.

This mirrors how real-world systems evolve:

* Manual → Automated
* Infra → Observability → Analytics

---

## Goals

1. Learn AWS fundamentals (EC2, Security Groups, EBS, IAM)
2. Understand cost, persistence, and lifecycle management
3. Migrate manual infra to Terraform
4. Build a realistic data engineering pipeline from game logs

---

## Repository Structure

```
minecraft-aws-project/
├── README.md                # High-level documentation (this file)
├── docs/                     # Deep-dive documentation
│   ├── architecture.md
│   ├── aws-costs.md
│   ├── troubleshooting.md
│   └── decisions.md
├── infra/                    # Infrastructure as Code (Terraform)
│   ├── envs/
│   │   ├── dev/
│   │   └── prod/
│   ├── modules/
│   │   ├── ec2/
│   │   ├── security-group/
│   │   └── networking/
│   └── README.md
├── server/                   # Minecraft server setup
│   ├── start.sh
│   ├── stop.sh
│   ├── server.properties
│   └── eula.txt
├── data/                     # Data engineering work
│   ├── ingestion/
│   ├── transformation/
│   ├── analytics/
│   └── schemas/
└── .gitignore
```

---

## Phase 1: ClickOps EC2 Setup (Learning & Server testing Phase)

### EC2 Configuration

* **AMI**: Amazon Linux 2023
* **Instance Type**: t3.micro → t3.medium (for performance testing)
* **Storage**: EBS gp3 (persistent world data)
* **Ports**:

  * 22 (SSH)
  * 25565 (Minecraft)

### Key Learnings

* World data persists across restarts because it lives on EBS
* Stopping EC2 stops compute charges, but EBS still costs money
* Public IP changes on stop/start unless Elastic IP is used

---

## Phase 2: Minecraft Server Setup

### Install Java

```bash
sudo dnf install java-21-amazon-corretto -y
```

### Server Directory

```bash
mkdir minecraft && cd minecraft
```

### Download Server

```bash
wget https://piston-data.mojang.com/v1/objects/<HASH>/server.jar
```

### First Run (Generate Files)

```bash
java -Xms512M -Xmx768M -jar server.jar nogui
```

### Accept EULA

```bash
echo "eula=true" > eula.txt
```

### Start Server

```bash
java -Xms512M -Xmx768M -jar server.jar nogui
```

---

## Server Lifecycle Management

### Stop Server Safely

Inside Minecraft console:

```text
stop
```

### Restart Server

```bash
java -Xms512M -Xmx768M -jar server.jar nogui
```

### Persistence Guarantee

✔ World data is stored in `world/`
✔ Restarting server does NOT delete progress
❌ Terminating EC2 deletes data unless EBS is snapshotted

---

## Phase 3: Logging & Observability

### Log Files

```
logs/
├── latest.log
├── YYYY-MM-DD-1.log.gz
```

### What Logs Contain

* Player joins / leaves
* Chat messages
* Performance warnings (TPS lag)
* World events

### Example Log Entry

```
[15:56:02] AusKirix joined the game
```

---

## Phase 4: Terraform Migration

### Why Terraform

* Reproducibility
* Version control
* Safer experimentation

### Terraform Scope

* EC2 instance
* Security Groups
* IAM roles
* EBS volumes

---

## Cost Management

| Component   | Charged When Stopped | Notes             |
| ----------- | -------------------- | ----------------- |
| EC2 Compute | ❌ No                 | Only when running |
| EBS Volume  | ✅ Yes                | World persistence |
| Elastic IP  | ⚠️ Yes               | If unattached     |

---

## Risks & Constraints

* t3.micro is underpowered for multiplayer
* TPS lag under CPU credit exhaustion
* Manual ops do not scale

---

## Future Enhancements

* systemd service for auto-start
* CloudWatch metrics
* Autoscaling experiments
* Spot instances

---


## Phase 5: Data Engineering Project

### Planned Pipeline

**Source**

* Minecraft logs (EC2 filesystem)

**Ingestion**

* Filebeat / custom Python
* Push to S3

**Processing**

* Parse logs → structured events
* Sessionization

**Storage**

* S3 (raw)
* DuckDB / Snowflake (analytics)

**Analytics Questions**

* Average session length
* Peak playing hours
* Player churn
* Lag vs player count

---


## Author

Haziq Noor

---

## Philosophy

This project prioritizes **learning clarity over shortcuts**. Everything is documented, reversible, and production-inspired.
