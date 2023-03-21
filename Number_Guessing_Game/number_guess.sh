#!/bin/bash
RANDOM_NUM=$(($RANDOM % 1000 + 1))
echo $RANDOM_NUM
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

if [[ -z $GAMES_PLAYED ]]
then
  # new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
NUMBER_OF_GUESSES=1

while [[ $USER_GUESS != $RANDOM_NUM ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  fi

  if [[ $USER_GUESS > $RANDOM_NUM ]]
  then
    echo "It's lower than that, guess again:"
    read USER_GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  else
    echo "It's higher than that, guess again:"
    read USER_GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"

# update games played
GAMES_PLAYED=$(($GAMES_PLAYED + 1))
UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED")

# update best game
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  UPDATE=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES")
fi


