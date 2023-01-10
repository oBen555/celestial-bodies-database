#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU () {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # # REMOVED due to glitch in freecodecamp project VVV
  #
  # # Check selected service is number
  # if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  # then
  #   MAIN_MENU "Please type a valid option."
  # fi

  # Find Service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'" | sed -r 's/^ *| *$//g')

  # Service doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "You have chosen $SERVICE_NAME. \n\nPlease enter your phone number:"

    read CUSTOMER_PHONE

    # Find phone number
    PHONE_NUMBER_CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")


    # Phone doesn't exist / new customer
    if [[ -z $PHONE_NUMBER_CHECK ]]
    then
      echo -e "\nThis is your first time at the Salon! \n\nPlease enter your Name:"
      read CUSTOMER_NAME

      ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -r 's/^ *| *$//g')
    
    # Get appointment time
    echo -e "\nWhat time would you like your appointment?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -r 's/^ *| *$//g')

    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
