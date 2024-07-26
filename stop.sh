#!/bin/bash

source ./Ec2.sh
echo "calling other  Ec2.sh script, calling::$instance_id"
aws ec2 terminate-instances --instance-ids $instance_id