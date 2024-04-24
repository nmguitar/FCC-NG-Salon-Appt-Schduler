#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Nick's Salon ~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to my salon, what can we do for you today?\n"
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ")
  echo -e "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  #checking if input is a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #Re-display services menu
    SERVICES_MENU "Please select one of the available options\n"
  else
    #if indeed a number, check if chosen number is indeed an existing service
    SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AVAILABLE ]]
    then
      #If it isn't an existing service, Re-display services menu
      SERVICES_MENU "Please select one of the available options\n"
    else
      #make a service name variable
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      #now that we've confirmed there's a valid service selected, lets get their phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      #confirm if an existing customer based on if CUSTOMER_NAME is empty
      if [[ -z $CUSTOMER_NAME ]]
      then
        #if doesnt' exist ask for and read in name
        echo -e "\nLooks like you're a new customer. What's your name?"
        read CUSTOMER_NAME

        #save new customer into customers table
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      #pull in customer id since it is common between appointments and customers tables
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      #with confirmed customer id, request the desired service time from customer
      echo -e "\nWhat time would you like to set for your appointment?"
      read SERVICE_TIME

      #with time, service id, and customer id, lets insert tuple into appointment table
      INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      #echo the resulting appointment
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *//g')."

    fi

  fi


}

SERVICES_MENU