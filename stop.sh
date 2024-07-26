#!/bin/bash


Instances=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].{Instance:InstanceId}" --output text)

echo "Terminating-instnaces_id's: $Instances"

aws ec2 terminate-instances --instance-ids $Instances