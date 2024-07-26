#!/bin/bash

source ./Ec2.sh
echo "after calling Ec2.sh script, calling::$Instances"

echo "Terminating-instnaces_id's: $Instances"

aws ec2 terminate-instances --instance-ids $Instances