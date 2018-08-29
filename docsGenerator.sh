#!/bin/sh
cont="/contracts"
path="$( $(dirname $0) ; pwd -P)"
echo $path
cd /tmp
git clone git@github.com:RyanHendricks/doxity-simpleton.git
cd doxity-simpleton

echo $(pwd)
rm -rf ./contracts/*
cp -r $path$cont/* ./contracts
mv ./contracts/lib/* ./contracts/.
rm -rf ./contracts/lib
rm ./contracts/Migrations.sol

# replace file location
sed -i -- 's/\.\/lib\/CampaignLibrary\.sol/\.\/CampaignLibrary\.sol/g' ./contracts/*

cd doxity
npm install
cd ..
npm install
./node_modules/.bin/doxity build

cp -rf docs $path
cp -rf doxity $path

cd /tmp
rm -rf /tmp/doxity-simpleton
# set repo folder
#sed  -i 's/^linkPrefix .*$/linkPrefix = "/asf-contracts"/g' ./doxity/config.toml
# set name
#sed  -i 's/^name .*$/name = "asf-contracts"/g' ./doxity/config.toml
# set author
#sed  -i 's/^author .*$/description = "App Store Foundation"/g' ./doxity/config.toml
# set description
#sed  -i 's/^homepage .*$/homepage = "https://github.com/AppStoreFoundation/asf-contracts.git"/g' ./doxity/config.toml



#npm run-script develop -y
