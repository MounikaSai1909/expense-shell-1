#!/bin/bash

source ./common.sh

check_root

echo "Please enter db password"
read -s  mysql_root_password

dnf install mysql-server -y &>>$LOG_FILE
#VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
#VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOG_FILE
#VALIDATE $? "Starting MySQL Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
#VALIDATE $? "Setting up the root password"


#Below code will be useful for idemponent nature
mysql --host=54.87.219.211 --user=root --password=${mysql_root_password} -e 'SHOW DATABASES;' &>> $LOG_FILE
if [ $? -ne 0 ]
then
   mysql_secure_installation --set-root-pass ${mysql_root_password} &>> $LOG_FILE
 # VALIDATE $? "Setting up the root password"
else 
    echo -e "MySQL root password is already setup.. $Y SKIPPING  $N"
fi
   