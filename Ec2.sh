#!/bin/bash

instance=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "ratings" "web")

for name in ${instance[@]};
do 
if [ $name == mysql  ] || [ $name == shipping ]
then 
instance_type="t3.medium"
else 
instance_type="t2.micro"
fi
echo "Creating instances: $name with $instance_type"

instance_id=$(aws ec2 run-instances --image-id ami-041e2ea9402c46c32 --instance-type $instance_type --security-group-ids sg-03ec942beb955be40 --subnet-id subnet-0f56f7cb0bd748d50 --query 'Instances[0].InstanceId' --output text)

aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$name

done