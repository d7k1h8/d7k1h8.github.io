#!/bin/sh

git pull origin auto
git add *.png
git commit -a -m '.png change'
git push origin auto
