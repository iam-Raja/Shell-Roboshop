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

dnf install mysql-server -y &>>$log_file
VALIDATE $? "install mysql-server"

systemctl enable mysqld &>>$log_file
VALIDATE $? "enable mysqld"

systemctl start mysqld &>>$log_file
VALIDATE $? "start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$log_file
VALIDATE $? "setting root passwords for mysqld"
