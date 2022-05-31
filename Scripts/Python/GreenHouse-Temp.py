import time
import Adafruit_DHT
import mysql.connector
from datetime import datetime
from twilio.rest import Client

#Variables
alert_count_high = 0
alert_count_low = 0

# Pulls Temp from DHT22
def get_temp():
    humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, 4)
    global temp
    global humid
    global temp_fahrenheit
    temp = round(temperature, 2)
    humid = round(humidity, 2)
    temp_fahrenheit_no_round= temperature *1.8 + 32
    temp_fahrenheit = round(temp_fahrenheit_no_round, 1)

#Text Alert function
def text_alert_high():
    account_sid = "TWILIO ACCOUNT SID"
    auth_token = "TWILIO AUTH TOKEN"
    client = Client(account_sid, auth_token)
    
    client.api.account.messages.create(
    to="NUMBER FOR RECIVER",
    from_="TWILIO NUMBER",
    body= 'Temperature is high Temp={}  Humidity={}'.format(temp_fahrenheit, humid))

    client.api.account.messages.create(
        to="NUMBER FOR RECIVER",
        from_="TWILIO NUMBER",
        body= 'Temperature is high Temp={}  Humidity={}'.format(temp_fahrenheit, humid))

# Text Alert function 
def text_alert_low():
        account_sid = "TWILIO ACCOUNT SID"
        auth_token = "TWILIO AUTH TOKEN"
        client = Client(account_sid, auth_token)

        client.api.account.messages.create(
        to="NUMBER FOR RECIVER",
        from_="TWILIO NUMBER",
        body= 'Temperature is low Temp={}  Humidity={}'.format(temp_fahrenheit, humid))

        client.api.account.messages.create(
        to="NUMBER FOR RECIVER",
        from_="TWILIO NUMBER",
        body= 'Temperature is low Temp={}  Humidity={}'.format(temp_fahrenheit, humid))

# Date Time for database
def date_time():
    global dt
    now = datetime.now()
    dt = now.strftime("%D - %I:%M %p")

# Connection to database
def database_connection():
    try:
        mydb = mysql.connector.connect(
            host="MYSQL IP",
            user="MYSQL USER",
            password="MYSQL USER PASSWORD",
            database="greenhouse"
        )
        mycursor = mydb.cursor()
        sql = "INSERT INTO tempgh(DT, temperature, humidity) VALUES (%s, %s, %s)"
        val = (dt, temp_fahrenheit, humid)
        mycursor.execute(sql, val)
        mydb.commit()
    except mysql.connector.Error as err:
        print("Something went wrong: {}".format(err))

# Infinite Loop
while True:
    date_time()
    get_temp()

    if temp_fahrenheit >= 100: #set to 90 Test temp set to 25
        alert_count_high += 1
        if alert_count_high == 1:
            text_alert_high()
        elif alert_count_high == 7:
            text_alert_high()
            alert_count_high = 0

    elif temp_fahrenheit <= 40: #set to 40 Test temp set to 20
        alert_count_low += 1
        if alert_count_low == 1:
            text_alert_low()
        elif alert_count_low == 7:
            text_alert_low()
            alert_count_low = 0

    database_connection()
    time.sleep(300)