#!/bin/bash

instance=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "ratings" "web")
hosted_zone_id="Z07779852ESP6TKS0688R"
domain_name="rajapeta.cloud"

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

if [ $name == web ]
then
ip_to_use=(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
else
ip_to_use=(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
fi
echo "creating R53 record for $name"
    aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
    {
        "Comment": "Creating a record set for '$name'"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$name.$domain_name'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$ip_to_use'"
            }]
        }
        }]
    }'

done