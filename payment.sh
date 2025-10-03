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

mkdir -p $LOGS_FOLDER | tee -a &>>$LOG_FILE

if ( $USERID -ne 0); then
    echo -e "Please execute this script using root privilage" &>>$LOG_FILE
    exit 1
fi

echo "Script executed at  $(date)" | tee -a &>>$LOG_FILE

VALIDATE(){
    if [ $1 -ne 0]; then
        echo -e "$2...$R FAILURE $N" | tee -a &>>$LOG_FILE
    else 
        echo -e "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Install Python"

id roboshop
if [ $0 -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "User already exist" &>>$LOG_FILE
fi

mkdir -p /app &>>>$LOG_FILE
VALIDATE $? "create /app dir"


curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Download Payment artifacts"

cd /app &>>$LOG_FILE
VALIDATE $? "To app"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzip payment artifacts"

cd /app  &>>$LOG_FILE
VALIDATE $? "To App"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing requirement"

cp $SCRIPT_DIR/payment.service  /etc/systemd/system/payment.service
VALIDATE $? "creating payment service"

systemctl daemon-reload
VALIDATE $? "Deamon Reload"

systemctl enable payment 
VALIDATE $? "Enable Payment"

systemctl start payment
VALIDATE $? "Start Payment"




