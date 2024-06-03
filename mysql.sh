#!/bin/bash
USERID=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter db password"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 $G....... SUCCESS $N"
    else
        echo -e " $2 $R....... FAILURE $N"
    fi

}

if [ $USERID -ne 0 ]
then
    echo " please run with root access "
    exit 1
else    
    echo " you are a super user "
fi

dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up password"


#Below code will be useful for idemponent nature
mysql -h db.mounka.online -uroot -p${mysql_root_password} -e 'show databases;' &>> $LOG_FILE
if [ $? -ne 0 ]
then
   mysql_secure_installation --set-root-pass ${mysql_root_password} &>> $LOG_FILE
   VALIDATE $? "MySQL Root password Setup"
else 
    echo -e "MySQL root password is already setup.. $Y SKIPPING  $N"
fi