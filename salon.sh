#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"
PSQL_NO_SPACE="psql --username=freecodecamp --dbname=salon -t -A -c"

echo -e "\nSALON\n"


MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  echo -e "\nHere are the available services:"
  echo "$($PSQL "SELECT * FROM services;")" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  NUMBER_OF_SERVICES=$($PSQL "SELECT COUNT(*) FROM services;")

  echo -e "\nPlease pick one:"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nHere are the available services:"
    echo "$($PSQL "SELECT * FROM services;")" | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
    return
  fi

  if [[ $SERVICE_ID_SELECTED -gt $NUMBER_OF_SERVICES ]]
  then
    echo -e "\nHere are the available services:"
    echo "$($PSQL "SELECT * FROM services;")" | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
    return
  fi

  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    #add customer to customers
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  fi

  echo -e "\nAt what time?"
  read SERVICE_TIME

  #add appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  CUSTOMER_NAME=$($PSQL_NO_SPACE "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
  SERVICE_NAME=$($PSQL_NO_SPACE "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU

