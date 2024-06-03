#!/bin/bash
source ./common.sh

check_root

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing Existing Content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOGFILE
VALIDATE $? "Downloading Frontend Code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGFILE
VALIDATE $? "unzipping frontend code"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting nginx"






