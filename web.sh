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

dnf install nginx -y  &>>$log_file
VALIDATE $? "install nginx"

systemctl enable nginx &>>$log_file
VALIDATE $? "enable nginx"

systemctl start nginx &>>$log_file
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
VALIDATE $? "remove default nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$log_file
VALIDATE $? "Downloading code"

cd /usr/share/nginx/html &>>$log_file
VALIDATE $? "Switch nginx/html"

unzip /tmp/web.zip &>>$log_file
VALIDATE $? "Unzipping"

cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$log_file
VALIDATE $? "Copying roboshop.conf"

systemctl restart nginx &>>$log_file
VALIDATE $? "restart nginx"


