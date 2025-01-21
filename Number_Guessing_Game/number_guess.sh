#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"

SECRET_NUMBER=$((1 + RANDOM % 1000))

# Ask for username
echo "Enter your username:"
read USERNAME

#Check if the user is in the database
USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if  [[  -z $USERNAME_RESULT  ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  # Insert the new user in the database
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Get the games_played and best_game of the user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")

  # Print the message
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Loop for the game
NUMBER_OF_GUESSES=1
echo -e "\nGuess the secret number between 1 and 1000:"
while read NUMBER_GUESS
do
  # Check if the input is an integer
  if  [[  ! $NUMBER_GUESS =~ ^[0-9]+$  ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    if  [[  $NUMBER_GUESS -gt $SECRET_NUMBER  ]]
    then
      echo "It's lower than that, guess again:"
    elif  [[  $NUMBER_GUESS -lt $SECRET_NUMBER  ]]
    then
      echo "It's higher than that, guess again:"
    else
      break;
    fi
  fi
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Insert the new game in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# Insert the game with the user_id relation for the other table
INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")