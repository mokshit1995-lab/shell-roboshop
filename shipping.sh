#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

echo "Script execution started at : $(date)"  | tee -a $LOG_FILE

if [$USERIF -ne 0]; then
    echo "Please use root privilage to run the script"
    exit 1 
fi

VALIDATE(){
    if [ $1 -ne 0]; then
        echo "$2...$R FAILURE $N  | tee -a $LOG_FILE
    else
        echo "$2...$G SUCCESS $N  | tee -a $LOG_FILE
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Install Maven"

id roboshop
if [$? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo "$G Roboshop user already created $N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATE $? "Directory create"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Download shipping code"

cd /app &>>$LOG_FILE
VALIDATE $? "
unzip /tmp/shipping.zip




