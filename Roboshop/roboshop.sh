#!/bin/bash
# This tells the system to execute this file using the Bash shell.

# -------------------------------
# Static Configuration Variables
# -------------------------------

SG_ID="sg-076ec9ad23dab2b28" 
# Security Group ID.
# This controls firewall rules (ports like 22, 80, 443).

AMI_ID="ami-0220d79f3f480ecf5"
# Amazon Machine Image ID.
# This is the OS template (example: Amazon Linux).

ZONE_ID="Z05013202FKF0ZL12WAOP"
# Route53 Hosted Zone ID.
# This identifies your DNS zone in AWS.

DOMAIN_NAME="daws88s.online"
# Your base domain name.

# --------------------------------
# Loop through all input arguments
# --------------------------------
# $@ = all arguments passed to script
# Example:
# ./script.sh frontend backend mongodb
# instance will become frontend, backend, mongodb one by one

for instance in $@
do

    # --------------------------------
    # Step 1: Create EC2 Instance
    # --------------------------------
    INSTANCE_ID=$( aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type "t3.micro" \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text )

    # Explanation:
    # - Launches EC2 instance
    # - Uses given AMI
    # - Uses t3.micro type
    # - Attaches security group
    # - Adds Name tag (example: frontend)
    # - Extracts only InstanceId
    # - Stores in INSTANCE_ID variable

    # --------------------------------
    # Step 2: Get IP Address
    # --------------------------------

    if [ $instance == "frontend" ]; then
        
        # For frontend → use PUBLIC IP
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )

        RECORD_NAME="$DOMAIN_NAME"
        # frontend will use main domain:
        # daws88s.online

    else
        
        # For backend/mongodb → use PRIVATE IP
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )

        RECORD_NAME="$instance.$DOMAIN_NAME"
        # Example:
        # mongodb.daws88s.online
        # backend.daws88s.online
    fi

    echo "IP Address: $IP"

    # --------------------------------
    # Step 3: Create or Update DNS Record
    # --------------------------------

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$RECORD_NAME'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP'"
                        }
                    ]
                }
            }
        ]
    }
    '

    # Explanation:
    # UPSERT = create if not exists, update if exists
    # Type A = maps domain to IP
    # TTL 1 = DNS cache time (1 second)
    # Value = instance IP

    echo "record updated for $instance"

done