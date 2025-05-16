#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
 
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) SERVICE_MENU "$SERVICE_ID_SELECTED" ;; # send all options to service menu
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}
SERVICE_MENU(){
  SERVICE_ID_SELECTED=$1
  # service name
  SERVICE_NAME=$($PSQL "
  SELECT name    
  FROM services 
  WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
  # get customers info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "
  SELECT name 
  FROM customers
  WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "
    INSERT INTO customers(phone,name)
    VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  # get customer id
  CUSTOMER_ID=$($PSQL "
  SELECT customer_id
  FROM customers
  WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -r 's/^ *| *$//g')
  # get time of appointment

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  SERVICE_TIME=$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g')
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "
  INSERT INTO appointments(customer_id, service_id, time)
  VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}
MAIN_MENU