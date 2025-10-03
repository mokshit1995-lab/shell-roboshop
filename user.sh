#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_DIR="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
LOG_FILE="$LOG_DIR/$SCRIPT_NAME.log"

mkdir -p $LOG_DIR

if ( $USERID -ne 0); then
    echo "Please run script with root privilage"
    exit 1 
fi

echo "Script execution started at $(date)" &>>$LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILLED $N" | tee -a &>>$LOG_FILE
        exit 1
    else
        echo -e "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install Nodejs"


id roboshop
if [ $? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo "roboshop user already exist"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Create App Dir"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Download artifacts"

cd /app &>>$LOG_FILE
VALIDATE $? "Moved to App directory"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzip artifact"

npm install &>>$LOG_FILE
VALIDATE $1 "Install Depencencies"

cp $SCRIPT_DIR/user.service vim /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $1 "Setup systemD for User.service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $1 "Deamon-Reload"

systemctl enable user &>>$LOG_FILE
VALIDATE $1 "Enable User"

systemctl start user &>>$LOG_FILE
VALIDATE $1 "Start User"


