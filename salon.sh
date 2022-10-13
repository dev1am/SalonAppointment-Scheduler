#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ Hello in Salon Appointment Scheduler ~~\n"

MAIN_MENU () {
  CUSTOMER_CHOISE
  CUSTOMER_INFO
  SELECT_TIME
}

CUSTOMER_CHOISE () {
  SERVICE_INFO=$($PSQL "SELECT service_id, name FROM services") # give services info
  echo -e "\nHere are the services we have available:"
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nPick number of service what do you want?"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED == [1-5] ]]
  then
    echo "That is not a valid service number."
    CUSTOMER_CHOISE
  else
    SERVICE_NAME_TO_SELECT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  fi
}

CUSTOMER_INFO () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE # get customer phone
  if [[ -z $CUSTOMER_PHONE ]] # check if enter empty phone 
  then
    echo "Please input valid phone number (XXX-XXX-XXXX)" # return question if phone empty
    CUSTOMER_INFO 
  else
    CHECKED_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'") # check phone in DB
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name IS NULL")
    if [[ -z $CHECKED_PHONE ]] # if phone is not in DB
    then # insert phone and name in DB
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "Name can't be empty"
        CUSTOMER_INFO 
      else
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    else # insert name if phone in DB
      if [[ ! -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME' WHERE phone='$CUSTOMER_PHONE'")
      fi
    fi
  fi
}

SELECT_TIME () {
  echo -e "\nPlease input time what you want to get service (hh:mm)"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    echo "Please input valid time hh:mm"
    SELECT_TIME 
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE_NAME_TO_SELECT at $SERVICE_TIME, $CUSTOMER_NAME"
    fi
  fi
}

EXIT () {
  echo -e "\nThank you for your choice"
}

MAIN_MENU
