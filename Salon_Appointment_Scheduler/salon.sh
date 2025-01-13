#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

DISPLAY_SERVICE_LIST() {
  # Numbered list of the services
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # Display list
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  CHECK_SERVICE_ID
}

CHECK_SERVICE_ID() {
  # Read the service selected by the customer
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  # If the input is not a service_id of services, return to display the list
  if  [[  -z  $SERVICE_NAME  ]]
  then
    echo "I could not find that service. What would you like today?"
    DISPLAY_SERVICE_LIST #"I could not find that service. What would you like today?"
  else
    CUSTOMER_INFO
  fi
}

CUSTOMER_INFO() {
  # Ask for the customer's phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # if the customer's phone is not in the database, is a new customer
  if  [[  -z $CUSTOMER_NAME  ]]
  then
    #Ask for the customer's name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Insert the new customers into customers table
    NEW_COSTUMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

    # Error alert
    if  [[  ! $NEW_COSTUMER_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nERROR: Can't add the customer to the database"
    else
      SET_APPOINTMENT
    fi
  else
    SET_APPOINTMENT
  fi
}

SET_APPOINTMENT() {
  # Ask for the service time
  echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME

  # Get the customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Insert the appointment into the database
  NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Error alert
  if  [[  ! $NEW_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
  then
    echo -e "\nERROR: Can't add the appointment to the database"
  else
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICE_LIST
