#!/bin/sh

git pull origin auto
cd couldron
git add *.tar *.webp
# echo '# HAHA' >> pusher.sh
git commit -a --allow-empty-message -m ''
git push origin auto
