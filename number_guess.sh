#!/bin/bash

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSWORK(){
  PLAYER=$1
  SECRET=$((1 + $RANDOM % 10))
  NGUESSES=0
  
  for (( ; ; ))
  do
    echo -e "Guess the secret number between 1 and 1000:"
    read GUESS

    REGEX='^[0-9]+$'
    if ! [[ $GUESS =~ $REGEX ]]; then
      NGUESSES=$((NGUESSES+1))
      echo -e "That is not an integer, guess again:"
    elif [[ $GUESS -lt $SECRET ]]; then
      NGUESSES=$((NGUESSES+1))
      echo -e "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET ]]; then
      NGUESSES=$((NGUESSES+1))
      echo -e "It's lower than that, guess again:"
    else
      NGUESSES=$((NGUESSES+1))
      echo -e "You guessed it in $((NGUESSES - 1)) tries. The secret number was $((SECRET)). Nice job!"
      GAMEOVER=$($PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username = '$PLAYER'")
      GAMEOVER=$($PSQL "UPDATE number_guess SET best_game = $NGUESSES WHERE username = '$PLAYER' AND (($NGUESSES < best_game) OR (best_game IS NULL))")
      break
    fi
  done
}

MAIN_MENU() {
  echo -e "Enter your username:"
  read USERNAME
  # find user in database
  CURRUSER=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")
    # if not found
    if [[ -z $CURRUSER ]]; then
      # insert user
      INSERT_USER_RESULT=$($PSQL "INSERT INTO number_guess (username) VALUES ('$USERNAME')")
      # get user major_id
      CURRUSER=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")
      echo -e "Welcome, $CURRUSER! It looks like this is your first time here."
    else
      IFS='|' read -r NUMGAMES BESTGAME <<<$($PSQL "SELECT games_played, best_game FROM number_guess WHERE username='$CURRUSER'")
      echo -e "Welcome back, $CURRUSER! You have played $NUMGAMES games, and your best game took $BESTGAME guesses."
    fi

    GUESSWORK "$CURRUSER"
}

MAIN_MENU
