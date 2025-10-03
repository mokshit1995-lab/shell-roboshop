#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_DIR=$PWD
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

if [$USERID -ne 0]; then
    echo -e "Please execute the script using root privilage" &>>$LOG_FILE
fi

VALIDATE(){
    if [ $1 -ne 0]; then
        echo "$2...$R FAILURE $N" | tee -a &>>$LOG_FILE
    else
        echo "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE 
    fi
}

cp $SCRIPT_DIR /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copy of rabbit repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Install Rabbit MQ"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Rabbit user roboshop addition"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Giving Premissions for Roboshop user"
