#!/bin/bash

cd "$(dirname ${BASH_SOURCE[0]})"
cd ..

GITUSER=$1
if [[ $GITUSER == "" ]]
then
  GITUSER="Scarygami"
fi

REPUSER=$2
if [[ $REPUSER == "" ]]
then
  REPUSER=$GITUSER
fi

# Authenticate GitHub User to prevent API rate limits
if [ ! -f "tool/githubtoken" ]
then
  echo "curl -u $GITUSER -d '{\"scopes\":[\"repo\"],\"note\":\"API Client Generator\"}' https://api.github.com/authorizations > \"tool/githubtoken\""
  echo "Attempting authentication with GitHub"
  echo "Please enter GitHub password for user $GITUSER when asked."
  echo `curl -u $GITUSER -d '{"scopes":["repo"],"note":"API Client Generator"}' https://api.github.com/authorizations > "tool/githubtoken"`
fi

# Check if token has been returned
token=""
id=""
while read line
do
  tmp=($line)
  key="${tmp[0]}"
  if [[ "$key" == *"token"* ]]
  then
    token="${tmp[1]}"
    token="${token:1:${#token}-3}"
  fi
  if [[ "$key" == *"id"* ]]
  then
    id="${tmp[1]}"
    id="${id:1:${#id}-1}"
  fi

  #echo "${tmp[0]} - ${tmp[1]}"
done < "tool/githubtoken"

if [[ $token == "" && $id == "" ]]
then
  echo "GitHub Authentication failed!"
  rm tool/githubtoken -f
  exit 1
fi

# TODO: Check if token is still valid
# curl https://api.github.com/authorizations/$id

echo "GitHub Authentication successful!"

# empty output folder
rm output/* -rf

# call generator --list to create APIS list
echo "dart bin/generator.dart --list 2>&1"
echo "`dart bin/generator.dart --list 2>&1`"

function handle_api {
  # Try to fetch current repository from github
  api=$1
  version=$2
  dir=$3
  echo "curl https://api.github.com/repos/$REPUSER/$dir"
  result=`curl --write-out %{http_code} --silent --output /dev/null -H "Authorization: token $token" https://api.github.com/repos/$REPUSER/$dir`

  if [ $result == "200" ]
  then
    echo "Repository $dir found."
  else
    if [ $result == "404" ]
    then
      echo "Repository $dir not found."
      # TODO:
      #   - Create repository via API if it doesn't exist yet
      data="{\"name\":\"$dir\"}"
      if [[ $GITUSER != $REPUSER ]]
      then
        echo "Creating repository $dir in organization $REPUSER"
        echo "curl https://api.github.com/orgs/$REPUSER/repos -d '$data'"
        curl --write-out %{http_code} --silent --output /dev/null -H "Authorization: token $token" https://api.github.com/orgs/$REPUSER/repos -d $data > output/result.tmp
      else
        echo "Creating repository $dir for user $REPUSER"
        echo "curl https://api.github.com/user/repos -d '$data'"
        curl --write-out %{http_code} --silent --output /dev/null -H "Authorization: token $token" https://api.github.com/user/repos -d $data > output/result.tmp
      fi
      result=$(<output/result.tmp)
      rm output/result.tmp -f
      if [[ $result != "201" ]]
      then
        echo "Error creating repository $REPUSER/$dir"
        return 1
      else
        echo "Repository $REPUSER/$dir created successfully"
      fi
    else
      echo "Error $result - $dir will be skipped."
      return 1
    fi
  fi

  echo "git clone https://github.com/$REPUSER/$dir.git output/$dir 2>&1"
  echo "`git clone https://github.com/$REPUSER/$dir.git output/$dir 2>&1`"

  # generate library
  echo "dart bin/generator.dart -a $api -v $version --check 2>&1"
  result=`dart bin/generator.dart -a $api -v $version --check 2>&1`
  echo "$result"

  if [[ "$result" == *"generated successfully"* ]]
  then
    echo "Commiting changes and pushing to GitHub"
    cd "output/$dir"
    result=`git status`; echo "$result"
    result=`git add --all`; echo "$result"
    result=`git commit -m "Automated update"`; echo "$result"
    result=`git push https://$token@github.com/$REPUSER/$dir.git master`; echo "$result"
    cd ../..
  fi

  echo "-------------"
  echo ""
  return 0
}

while read line
do
  tmp=($line)
  handle_api "${tmp[0]}" "${tmp[1]}" "${tmp[2]}"
  ## limit output for testing
  #count=$((count+1))
  #if (( $count >= 5 )); then
  #  exit 0
  #fi
done < "output/APIS"


