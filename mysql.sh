#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

if ( $USERID -ne 0); then
    echo "Please use root privilage to run this script"
    exit 1
fi

echo "Script execution started at : $(date)"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2...$R FAILURE $N" | tee -a &>>$LOG_FILE
    else
        echo "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE

}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Install Mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enable mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Start Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Create root password"

