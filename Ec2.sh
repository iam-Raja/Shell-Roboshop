#!/bin/bash

instance=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "ratings" "web")

for names in ${instance[@]};
do 
echo "Creating instances: $names"
done