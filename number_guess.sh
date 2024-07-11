#!/bin/bash

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSWORK(){
  PLAYER=$1
  SECRET=$((1 + $RANDOM % 10))
  GUESSES=0
  
  for (( ; ; ))
  do
    echo "Guess the secret number between 1 and 1000:"
    read PLAYER_GUESS

    REGEX='^[0-9]+$'
    if ! [[ $PLAYER_GUESS =~ $REGEX ]]; then
      #GUESSES=$((GUESSES+1))
      echo "That is not an integer, guess again:"
    elif [[ $PLAYER_GUESS -lt $SECRET ]]; then
      GUESSES=$((GUESSES+1))
      echo "It's higher than that, guess again:"
    elif [[ $PLAYER_GUESS -gt $SECRET ]]; then
      GUESSES=$((GUESSES+1))
      echo "It's lower than that, guess again:"
    else
      GUESSES=$((GUESSES+1))
      echo "You guessed it in $GUESSES tries. The secret number was $((SECRET)). Nice job!"
      GAMEOVER=$($PSQL "UPDATE stats SET games = games + 1 WHERE username = '$PLAYER'")
      GAMEOVER=$($PSQL "UPDATE stats SET best = $GUESSES WHERE username = '$PLAYER' AND (($GUESSES < best) OR (best IS NULL))")
      break
    fi
  done
}

MAIN_MENU() {
  echo "Enter your username:"
  read USER_NAME
  # find user in database
  CURR_USER=$($PSQL "SELECT username FROM stats WHERE username='$USER_NAME'")
    # if not found
    if [[ -z $CURR_USER ]]; then
      # insert user
      INSERT_USER_RESULT=$($PSQL "INSERT INTO stats (username, games) VALUES ('$USER_NAME', 0)")
      # get user major_id
      CURR_USER=$($PSQL "SELECT username FROM stats WHERE username='$USER_NAME'")
      echo "Welcome, $CURR_USER! It looks like this is your first time here."
    else
      IFS='|' read -r NUMGAMES BESTGAME <<<$($PSQL "SELECT games, best FROM stats WHERE username='$CURR_USER'")
      echo "Welcome back, $CURR_USER! You have played $NUM_GAMES games, and your best game took $BEST_GAME guesses."
    fi

    GUESSWORK "$CURR_USER"
}

MAIN_MENU
