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
    echo -e "$2 ..... $R FAILED $N"
    exit 1
    else 
    echo -e "$2 ..... $G SUCCESS $N"
    fi
}
if [ $USERID -ne 0 ]
then 
echo "switch to super user"
exit 1
else
echo "You are super user"
fi

dnf install python3.11 gcc python3-devel -y &>>$log_file
VALIDATE $? "install redis"

id roboshop &>>$log_file
if [ $? -ne 0 ]
then
    useradd roboshop &>>$log_file
    VALIDATE $? "useradd roboshop"
else
    echo -e "USER roboshop is already exists.....$Y SKIPPING $N"  
fi

rm -rf /app &>>$log_file
VALIDATE $? "Cleaning up the directory"

mkdir -p /app &>>$log_file
VALIDATE $? "creating dir app"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$log_file
VALIDATE $? "downloading code"

cd /app &>>$log_file
VALIDATE $? "Switching dir app"

unzip /tmp/payment.zip &>>$log_file
VALIDATE $? "unzipping code"

pip3.11 install -r requirements.txt &>>$log_file
VALIDATE $? "npm install"

cp /home/ec2-user/Shell-Roboshop/payment.service /etc/systemd/system/payment.service &>>$log_file
VALIDATE $? "cp payment.service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon-reload"

systemctl enable payment &>>$log_file
VALIDATE $? "enable payment"

systemctl start payment &>>$log_file
VALIDATE $? "start payment"



