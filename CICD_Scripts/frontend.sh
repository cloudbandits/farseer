#! /bin/bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash
sudo apt install -y nodejs
node -v
npm i
npm run build
nohup npm run start &>/dev/null &