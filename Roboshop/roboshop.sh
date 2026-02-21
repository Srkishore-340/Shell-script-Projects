#!/bin/bash

SG_ID="sg-04d26ebef6a9e9ddc"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in "$@"
do 
    instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "t3.micro" \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ "$instance" == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)
    fi

    echo "Instance: $instance"
    echo "Instance ID: $instance_ID"
    echo "IP Address: $IP"
    echo "-----------------------------"

done