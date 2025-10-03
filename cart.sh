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

mkdir -p $LOGS_FOLDER
echo "Script execution started at : $(date) "

if [ $USERID -ne 0 ]; then
    echo "Please excute the script with Root Privilate"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0]; then
        echo -e "$2...$R FAILED $N" | tee -a &>>$LOG_FILE
        exit 1
    else
        echo -e "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE  $? "Enable Nodejs v20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install Nodejs"

id roboshop &>>$LOG_FILE
if [$? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "Roboshop id Already exist"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Create app Dir"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Download cart artifacts"

cd /app  &>>$LOG_FILE
VALIDATE $? "Go to App Dir"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Unzip cart artifacts"

cd /app &>>$LOG_FILE
VALIDATE $? "Go to App Dir"

npm install &>>$LOG_FILE
VALIDATE $? "Install depedencies"

cp $SCRIPT_DIR/cart.service vim /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "Create systemD of cart"

systemctl deamon-reload
VALIDATE $? "Deamon Reload"

systemctl enable cart
VALIDATE $? "Enable cart"

systemctl start cart 
VALIDATE $? "Enable cart"





