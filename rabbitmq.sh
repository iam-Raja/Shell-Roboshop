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
    exit 1 #exist here manually
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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>>$log_file
VALIDATE $? "Downloading script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>>$log_file
VALIDATE $? "Confguring script"

dnf install rabbitmq-server -y  &>>$log_file
VALIDATE $? "install rabbitmq-server"

systemctl enable rabbitmq-server  &>>$log_file
VALIDATE $? "enable rabbitmq-server"

systemctl start rabbitmq-server  &>>$log_file
VALIDATE $? "start rabbitmq-server"

sudo rabbitmqctl list_users | grep roboshop &>>$LOGFILE

if [ $? -ne 0 ]
then
     rabbitmqctl add_user roboshop roboshop123  &>>$log_file
     VALIDATE $? "Add user roboshop"
     rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$log_file
     VALIDATE $? "Setting Permissions"
else
echo -e "USER is aleady exists.....$Y SKIPPING $N"
fi




