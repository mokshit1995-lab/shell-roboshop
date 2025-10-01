#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo "Please execute script with root user access"
    exit 1
fi

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER

echo "Script execited at :$(date)" | tee -a $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ];then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disable Redis"

dnf module enable redis:7 -y  &>>$LOG_FILE
VALIDATE $? "Enable Redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Install Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Changed ip to allow all"

sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Change protection to Yes"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enable Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Start Redis"

