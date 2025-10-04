#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | curl -d "." -f1)
SCRPIT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER 

if [ $USERID -ne 0 ]; then
    echo -e "Execute this Script using root privilage" 
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2...$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Install Golang"

id roboshop &>>$LOG_FILE
if  [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "User already Created"
fi

mkdir /app &>>$LOG_FILE
VALIDATE $? "Create /app Dir"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOG_FILE
VALIDATE $? "Download Dispatch"

cd /app &>>$LOG_FILE
VALIDATE $? "To App"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Remove existing code"

unzip /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Unzip Dispatch"


cd /app &>>$LOG_FILE
VALIDATE $? "To app"

go mod init dispatch &>>$LOG_FILE
go get &>>$LOG_FILE
go build &>>$LOG_FILE
VALIDATE $? "Install go dependencies"

cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service &>>$LOG_FILE
VALIDATE $? "Create Dispatch Service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon Reload"

systemctl enable dispatch &>>$LOG_FILE
VALIDATE $? "Enable Dispatch"

systemctl start dispatch &>>$LOG_FILE
VALIDATE $? "Start Dispatch"
