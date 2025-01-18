# Base strings for querys
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"
QUERY_BASE="SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius FROM elements FULL JOIN properties USING (atomic_number) FULL JOIN types USING (type_id)"

# Function for display the element info
DISPLAY_INFO() {
  # Check if the atomic_number element is in the database
  if  [[  -z $INFO_RESULT  ]]
  then
    echo "I could not find that element in the database."
  else
    # Display the info
    echo "$INFO_RESULT" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

# Conditional for the argument
if  [[  -z $1  ]]
then
  echo "Please provide an element as an argument."
else
  # Identify if the argument is the atomic_number, symbol or name of the element
  if  [[  "$1" =~ ^[0-9]+$  ]]
  then
    # Make the query to obtain the info
    INFO_RESULT=$($PSQL "$QUERY_BASE WHERE atomic_number = $1")
    DISPLAY_INFO
  elif  [[  "$1" =~ ^[a-zA-Z][a-zA-Z]?$  ]]
  then
    # Make the query to obtain the info
    INFO_RESULT=$($PSQL "$QUERY_BASE WHERE symbol='$1'")
    DISPLAY_INFO
  else
    # Make the query to obtain the info
    INFO_RESULT=$($PSQL "$QUERY_BASE WHERE name='$1'")
    DISPLAY_INFO
  fi
fi