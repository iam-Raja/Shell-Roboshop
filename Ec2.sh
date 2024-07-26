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
done