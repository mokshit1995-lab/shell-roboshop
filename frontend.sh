#!bin/bash

USER=$(id -u) #This will give you the value if the user is not a root user 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER != 0 ]; then
    echo "Please execute the script using root user access"
    exit 1
fi

LOG_DIR="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOG_DIR/$SCRIPT_NAME.log" #/var/log/shell-roboshop/frontend.log

mkdir -p $LOG_DIR
echo "Script started execution at $(date)" &>>$LOG_FILE

VALIDATE(){
    if [ $1 != 0 ]; then
        echo -e "$2 ... $R FAILUER $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabe Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enable Nginx v24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Install Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Remove default HTML"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Download Frontend content"

cd /usr/share/nginx/html  &>>$LOG_FILE
VALIDATE $? "Got to /usr/share/nginx/html"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzip frontend content"

cp $SCRIPT_DIR/frontend.cont /etc/nginx/nginx.conf
VALIDATE $? "Copy Frontend content to nginx.conf"

systemctl restart nginx 
VALIDATE $? "restart nginx"


