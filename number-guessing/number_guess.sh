#!/bin/bash

#PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

# BEST_GAME=0
# GAMES_PLAYED=0

# MAIN_MENU() {
  # Get Username
  echo "Enter your username:"
  read USERNAME

  USER_SEARCH=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  # Get user data
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'" | sed 's/ *//')
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'" | sed 's/ *//')

  # New Username
  if [[ -z $USER_SEARCH ]]
  then
    # ADD user to database
    # echo $($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
    echo $($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # Greet Existing User
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
# }

# Get user data
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'" | sed 's/ *//')
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'" | sed 's/ *//')


GUESS_GAME() {
  NUM_GUESSES=$1
  # echo "Best game = $BEST_GAME"
  # echo "NUMBER = $RANDOM_NUMBER"
  # echo "Number of guesses = $NUM_GUESSES"

  echo $2

  read USER_GUESS

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_GAME $(($NUM_GUESSES + 1)) "That is not an integer, guess again:"
  elif [[ $USER_GUESS > $RANDOM_NUMBER ]]
  then
    GUESS_GAME $(($NUM_GUESSES + 1)) "It's lower than that, guess again:"
  elif [[ $USER_GUESS < $RANDOM_NUMBER ]]
  then
    GUESS_GAME $(($NUM_GUESSES + 1)) "It's higher than that, guess again:"
  elif [[ $USER_GUESS == $RANDOM_NUMBER ]]
  then
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    
    if [[ -z $BEST_GAME ]]
    then
      BEST_GAME=$NUM_GUESSES
    elif [[ $NUM_GUESSES < $BEST_GAME ]]
    then
      BEST_GAME=$NUM_GUESSES
    fi

    UPDATE_USER=$($PSQL "UPDATE users SET games_played=$(($GAMES_PLAYED + 1)), best_game=$BEST_GAME WHERE username='$USERNAME'")
  fi
}

# MAIN_MENU

GUESS_GAME 1 "Guess the secret number between 1 and 1000:"
