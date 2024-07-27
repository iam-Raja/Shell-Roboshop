#!/bin/bash
cartID=$(id -u)
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
if [ $cartID -ne 0 ]
then 
echo "switch to super cart"
exit 1
else
echo "You are super cart"
fi

dnf module disable nodejs -y  &>>$log_file
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "install nodejs"

useradd roboshop &>>$log_file
VALIDATE $? "useradd roboshop"

mkdir /app &>>$log_file
VALIDATE $? "creating dir app"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$log_file
VALIDATE $? "downloading code"

cd /app &>>$log_file
VALIDATE $? "Switching dir app"

unzip /tmp/cart.zip &>>$log_file
VALIDATE $? "unzipping code"

npm install &>>$log_file
VALIDATE $? "npm install"

cp /home/ec2-user/Shell-Roboshop/cart.service /etc/systemd/system/cart.service &>>$log_file
VALIDATE $? "cp cart.service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon-reload"

systemctl enable cart &>>$log_file
VALIDATE $? "enable cart"

systemctl start cart &>>$log_file
VALIDATE $? "start cart"

