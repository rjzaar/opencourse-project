#!/bin/bash

#This will push the opencourse project changes to github
#push opencourse-project
echo -e "\e[34mpush opencourse-project\e[39m"
rm ocgitstore/ocsitegit/.git -rf
mv .git ocgitstore/ocsitegit/.git
cp .gitignore.ocproj .gitignore
mv ocgitstore/ocprojectgit/.git .git
git add .
git commit -m "Scripts update."
git push
cp .gitignore.ocsite .gitignore
mv .git ocgitstore/ocprojectgit/.git
cp ocgitstore/ocsitegit/.git .git -rf