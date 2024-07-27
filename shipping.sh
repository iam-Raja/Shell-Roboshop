#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MYSQL_HOST=mysql.rajapeta.cloud

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

dnf install maven -y  &>>$log_file
VALIDATE $? "install maven"

id roboshop &>>$log_file
if [ $? -ne 0 ]
then
    useradd roboshop &>>$log_file
    VALIDATE $? "useradd roboshop"
else
echo "USER roboshop is already exists.....$Y SKIPPIMG $N"
fi

rm -rf /app &>>$log_file
VALIDATE $? "clean up existing directory"


mkdir -p /app &>>$log_file
VALIDATE $? "creating dir app"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$log_file
VALIDATE $? "downloading code"

cd /app &>>$log_file
VALIDATE $? "Switching dir app"

unzip /tmp/shipping.zip &>>$log_file
VALIDATE $? "unzipping code"

mvn clean package &>>$log_file
VALIDATE $? "mvn clean package"

mv target/shipping-1.0.jar shipping.jar &>>$log_file
VALIDATE $? "moving shipping.jar"

cp /home/ec2-user/Shell-Roboshop/shipping.service /etc/systemd/system/shipping.service &>>$log_file
VALIDATE $? "Copying shipping.service"

systemctl daemon-reload &>>$log_file
VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$log_file
VALIDATE $? "enable shipping"

systemctl start shipping &>>$log_file
VALIDATE $? "start shipping"

dnf install mysql -y &>>$log_file
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>>$log_file
if [ $? -ne 0 ]
then
    echo "Schema is ... LOADING"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$log_file
    VALIDATE $? "Loading schema"
else
    echo -e "Schema already exists... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$log_file
VALIDATE $? "restart shipping"