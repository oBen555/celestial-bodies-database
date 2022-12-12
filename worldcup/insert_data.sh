#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


echo $($PSQL "TRUNCATE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    echo -e "\n$YEAR, $ROUND, $WINNER, $OPPONENT, $WIN_GOALS, $OPP_GOALS"

    #get winner_id
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    #if not found
    if [[ -z $WIN_ID ]]
    then
      #insert winner into teams 
      $($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      echo "Inserted Winner: $WINNER"
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    fi
    echo "Found Winner: $WINNER, id=$WIN_ID."

    #get opponent_id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    #if not found
    if [[ -z $OPP_ID ]]
    then
      #insert opponent into teams 
      $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      echo "Inserted Opponent: $OPPONENT"
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    fi
    echo "Found Opponent: $OPPONENT, id=$OPP_ID."

    #insert into games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WIN_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $YEAR, $ROUND, $WIN_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS."
    fi
  fi
done
