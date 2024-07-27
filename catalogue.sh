#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGO_HOST=mongodb.rajapeta.cloud

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

dnf module disable nodejs -y  &>>$log_file
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "install nodejs"

id roboshop &>>$log_file

if [ $? -ne 0 ]
then
    useradd roboshop &>>$log_file
    VALIDATE $? "useradd roboshop"
else
echo "USER roboshop is already exists.....$Y SKIPPIMG $N"
fi 

mkdir /app &>>$log_file
VALIDATE $? "creating dir app"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$log_file
VALIDATE $? "downloading code"

cd /app &>>$log_file
VALIDATE $? "Switching dir app"

unzip /tmp/catalogue.zip &>>$log_file
VALIDATE $? "unzipping code"

npm install &>>$log_file
VALIDATE $? "npm install"

cp /home/ec2-user/Shell-Roboshop/catalogue.service /etc/systemd/system/catalogue.service &>>$log_file
VALIDATE $? "cp catalogue.service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon-reload"

systemctl enable catalogue &>>$log_file
VALIDATE $? "enable catalogue"

systemctl start catalogue &>>$log_file
VALIDATE $? "start catalogue"

cp /home/ec2-user/Shell-Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
VALIDATE $? "Copying mongo.repo"

dnf install -y mongodb-mongosh &>>$log_file
VALIDATE $? "install mongodb-mongosh"

SCHEMA_EXISTS=$(mongosh --host $MONGO_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") &>> &>>$log_file

if [ $SCHEMA_EXISTS -lt 0 ]
then
    echo "Schema does not exists ... LOADING"
    mongosh --host $MONGO_HOST </app/schema/catalogue.js &>> &>>$log_file
    VALIDATE $? "Loading catalogue data"
else
    echo -e "schema already exists... $Y SKIPPING $N"
fi

