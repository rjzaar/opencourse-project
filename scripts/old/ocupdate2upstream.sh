#!/usr/bin/env bash

#This script will update opencourse to the varbase-project upstream
cd
cd opencat/opencourse
echo "Add credentials."
if [ -f ~/.ssh/github ]; then
    ssh-add ~/.ssh/github
else
    echo "could not add git credentials, recommended to create github credentials in .ssh folder"
fi
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
git merge upstream/8.7.x

#Now overide the upstream readme.
echo "Now move readme back"
mv README.md1 README.md

git add .
git commit -m \"Updated to lastest varbase.\”
git push

rm composer.lock
composer install

# test and then push

