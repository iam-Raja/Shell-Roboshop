#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
    echo -e "$2 ..... $R Failed $N"
    exit 1
    else 
    echo -e "$2 ..... $G success $N"
    fi
}
if [ $USERID -ne 0 ]
then 
echo "switch to super user"
exit 1
else
echo "You are super user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org -y  &>>$log_file
VALIDATE $? "install mongodb-org"

systemctl enable mongod &>>$log_file
VALIDATE $? "enable mongod"

systemctl start mongod &>>$log_file
VALIDATE $? "start mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Remote server access to 0.0.0.0"

systemctl restart mongod &>>$log_file
VALIDATE $? "restart mongod"

