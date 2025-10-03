#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | curl -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER &>>$LOG_FILE

if [ $USERID -ne 0]; then
    echo -e "Execute this Script using root privilage" &>>$LOG_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0]; then
        echo "$2...$R FAILURE $N" | tee -a &>>$LOG_FILE
    else
        echo "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE
    fi
}

dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Install Golang"

id roboshop
if [$? -ne 0]; then
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

unzip /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Unzip Dispatch"


cd /app &>>$LOG_FILE
VALIDATE $? "To app"

go mod init dispatch &>>$LOG_FILE
go get &>>$LOG_FILE
go build &>>$LOG_FILE
VALIDATE $? "Install go dependencies"

