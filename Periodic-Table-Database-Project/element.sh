#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ $1 ]]
then
  # check if number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # query symbol and name based on atomic number
    ATOMIC_NUMBER=$1
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
  else
    # check if symbol
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
    # if symbol is empty
    if [[ -z $SYMBOL ]]
    then
      # it's a name
      NAME=$1
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME';")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME';")
    else
      # it's a symbol
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL';")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL';")
    fi
  fi

  if [[ -z $ATOMIC_NUMBER || -z $SYMBOL || -z $NAME ]]
  then
    echo "I could not find that element in the database."
  else
    TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
    MELTING_PNT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
    BOILING_PNT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_PNT celsius and a boiling point of $BOILING_PNT celsius."
  fi
else
  echo 'Please provide an element as an argument.'
fi