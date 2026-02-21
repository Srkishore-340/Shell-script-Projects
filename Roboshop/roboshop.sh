#!/bin/bash

SG_ID="sg-04d26ebef6a9e9ddc"
AMI_ID="ami-0220d79f3f480ecf5"
MangoDb="MangoDb"


for instance in $@
do 
instance_ID=$(aws ec2 run-instances \
--image-id $AMI_ID \
--instance-type "t3.micro" \
--security-group-ids $SG_ID \ 
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \ 
--query 'Instances[0].InstanceId' \
--output text)

if [ $instance == "frontend" ]; then
    IP = $(
        aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
    )
else
    IP=$(
        ws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
    )
fi

echo "IP Adress: " 
done 


