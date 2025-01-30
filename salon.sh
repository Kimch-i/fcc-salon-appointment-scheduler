#! /bin/bash

PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

DISPLAY_SERVICES() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}


DISPLAY_SERVICES


while true; do
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    DISPLAY_SERVICES
  else
    break
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")


if [[ -z $CUSTOMER_ID ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | xargs), $CUSTOMER_NAME?"
read SERVICE_TIME


INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $(echo $SERVICE_NAME | xargs) at $SERVICE_TIME, $CUSTOMER_NAME."
