#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# ARG(atomic_number, symbol, name)
PRINT_ELEMENT_PROPS() {
  NUMBER=$1
  SYMBOL=$2
  NAME=$3

  echo $($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$NUMBER") | while read TYPE BAR MASS BAR MELTING_PT BAR BOILING_PT
  do
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_PT celsius and a boiling point of $BOILING_PT celsius."
  done
}

PRINT_ERROR() {

  echo "I could not find that element in the database."

}

# Is atomic number
if [[ $1 =~ ^[0-9]+$ ]]
then
  # echo "Atomic number is $1"
  CHECK_NUMBER=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1")

  if [[ -z $CHECK_NUMBER ]]
  then
    PRINT_ERROR
  else
    echo $($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1") | while read NUMBER BAR SYMBOL BAR NAME 
    do
      PRINT_ELEMENT_PROPS $NUMBER $SYMBOL $NAME
    done
  fi
# Is element symbol
elif [[ $1 =~ ^[a-zA-Z]{1,2}$ ]]
then
  CHECK_SYMBOL=$($PSQL "SELECT * FROM elements WHERE symbol=INITCAP('$1')")

  if [[ -z $CHECK_SYMBOL ]]
  then
    PRINT_ERROR
  else
    echo $($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol=INITCAP('$1')" ) | while read NUMBER BAR SYMBOL BAR NAME 
    do
      PRINT_ELEMENT_PROPS $NUMBER $SYMBOL $NAME
    done
  fi
# Is element name
elif [[ $1 =~ ^[a-zA-Z]+$ ]]
then
  CHECK_NAME=$($PSQL "SELECT * FROM elements WHERE name=INITCAP('$1')")

  if [[ -z $CHECK_NAME ]]
  then
    PRINT_ERROR
  else
    echo $($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name=INITCAP('$1')" ) | while read NUMBER BAR SYMBOL BAR NAME 
    do
      PRINT_ELEMENT_PROPS $NUMBER $SYMBOL $NAME
    done
  fi
else
  echo "Please provide an element as an argument."
fi

