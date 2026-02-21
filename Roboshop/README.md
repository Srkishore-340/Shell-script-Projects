# AWS EC2 + Route53 Automation Script

## 📌 Overview

This script automates:

- Launching EC2 instances
- Tagging instances with service names
- Fetching IP addresses
- Creating or updating Route53 DNS recordss

It supports multiple services (frontend, backend, mongodb, etc.) via command-line arguments.

---

## 🏗 Architecture Design

| Service     | IP Used      | DNS Record Created                |
|------------|-------------|-----------------------------------|
| frontend   | Public IP   | daws88s.online                    |
| backend    | Private IP  | backend.daws88s.online            |
| mongodb    | Private IP  | mongodb.daws88s.online            |

- Frontend → Public-facing
- Backend/DB → Internal only

---

## 📂 Project Structure

.
├── roboshop.sh  
└── README.md  

---

## ⚙ Prerequisites

- AWS CLI installed
- AWS CLI configured (`aws configure`)
- EC2 permissions
- Route53 permissions
- Existing Hosted Zone
- Valid AMI ID
- Security Group created

---

## 🔧 Configuration Variables

Inside `roboshop.sh`:

SG_ID="sg-xxxxxxxx"  
AMI_ID="ami-xxxxxxxx"  
ZONE_ID="ZXXXXXXXXXXXXX"  
DOMAIN_NAME="example.com"  

| Variable | Description |
|----------|------------|
| SG_ID | Security Group ID |
| AMI_ID | Amazon Machine Image |
| ZONE_ID | Route53 Hosted Zone ID |
| DOMAIN_NAME | Base domain |

Update these before execution.

---

## 🖥 Usage

Make executable:

chmod +x roboshop.sh

Run script:

./roboshop.sh frontend backend mongodb

---

## 🔄 Script Workflow

### 1️⃣ Loop Through Arguments

for instance in $@

Processes each service name passed to script.

---

### 2️⃣ Launch EC2 Instance

aws ec2 run-instances

- Uses specified AMI
- Uses t3.micro
- Attaches security group
- Adds Name tag
- Extracts Instance ID

---

### 3️⃣ Fetch IP Address

If instance is frontend:
- Fetch Public IP

Else:
- Fetch Private IP

aws ec2 describe-instances

---

### 4️⃣ Create or Update DNS Record

aws route53 change-resource-record-sets

Uses:
- Action: UPSERT
- Record Type: A
- TTL: 1
- Value: Instance IP

---

## 📝 Example Output

IP Address: 54.xx.xx.xx  
record updated for frontend  

IP Address: 172.xx.xx.xx  
record updated for backend  

---

## 🧠 Concepts Used

- AWS CLI
- EC2 provisioning
- Route53 DNS automation
- Shell scripting
- Command substitution $( )
- JSON filtering with --query
- UPSERT logic

---

## ⚠ Current Limitations

- No error handling
- No instance status validation
- No AWS credential validation
- No logging
- TTL set to 1 (not production recommended)

---

## 🚀 Suggested Production Improvements

- Add instance wait logic
- Add retry mechanism
- Add proper logging
- Add validation checks
- Parameterize instance type
- Add environment support (dev/prod)
- Use Terraform for scalable infrastructure

---

## 📈 Suitable For

- DevOps practice projects
- AWS automation learning
- Portfolio demonstration
- Infrastructure scripting practice

---

## 👨‍💻 Author

Ravi Kishore