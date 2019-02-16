#!/usr/bin/env bash

#This script will update opencourse to the varbase-project upstream
cd
cd opencat/opencourse
echo "Add credentials."
ssh-add ~/.ssh/github
echo "Make sure any changes are pushed up. "
git push

# Move Readme out the way for now.
echo "Move readme out the way"
mv README.md README.md1
echo "Add upstream."
git remote add upstream git@github.com:Vardot/varbase-project.git
echo "Fetch upstream"
git fetch upstream

echo "Now try merge."
git merge upstream/8.6.x


#Now overide the upstream readme.
echo "Now move readme back"
mv README.md1 README.md

git add .
git commit -m \"Updated to lastest varbase.\”

rm composer.lock
composer install

# test and then push

