#!/bin/bash
USERID=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter db password"
read -s  mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$2...$R  FAILURE $N"
       exit 1
    else 
       echo -e "$2... $G  SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo "Please run with super user"
    exit 1
else 
    echo "You are a super user"
fi

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling node:20 version"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

#useradd expense
#VALIDATE $? "creating expense user"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-sample/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload"

systemctl start backend &>>$LOG_FILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql --host=3.80.83.45 --user=root --password=${mysql_root_password} < /app/schema/backend.sql &>> $LOG_FILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting backend"

##




