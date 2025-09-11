#!/bin/sh

git pull --no-edit origin temp
cp ../*.tar .
echo '' >> ./childhood_friend_1757564866.tar
git add *.tar
git commit -a --allow-empty-message -m ''
git push origin temp
