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
MYSQLIP="mysql.mgunti.space"

mkdir -p $LOGS_FOLDER

echo "Script execution started at : $(date)"  | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "Please use root privilage to run the script"
    exit 1 
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"  | tee -a $LOG_FILE
    else
        echo -e "$2...$G SUCCESS $N"  | tee -a $LOG_FILE
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Install Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else 
    echo "$G Roboshop user already created $N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATE $? "Directory create"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Download shipping code"

cd /app &>>$LOG_FILE
VALIDATE $? "To app dir"

unzip /tmp/shipping.zip
VALIDATE $? "Unzip Shipping code"

cd /app &>>$LOG_FILE
VALIDATE $? "to app dir"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Installing dependencies of Maven"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Move target shipping JAR file to Shipping"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon Reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enable Shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Start Shipping"


dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Install Mysql"

mysql -h $MYSQLIP -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h  $MYSQLIP -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h  $MYSQLIP -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h  $MYSQLIP -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart Shiping"
