#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  # if there's an argument
  if [[ $1 ]]
  then
    # print the argument
    echo -e "\n$1"
  fi

  # print main menu
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # read service id input
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # get service information
  SERVICE_INFO=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if no service available
  if [[ -z $SERVICE_INFO ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # read customer phone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get customer info
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if no customer info available
    if [[ -z $CUSTOMER_NAME ]]
    then
      # read customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # read service time
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # insert new appointment
    INSERT_APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

  # return to main menu
}

MAIN_MENU "Welcome to My Salon, how can I help you?"