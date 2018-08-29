#!/bin/sh
cont="/contracts"
path="$( $(dirname $0) ; pwd -P)"
echo $path
cd $path

homepage=$(grep -o "\"homepage.*" package.json)
url=$(grep -o "\"url.*" package.json )
author=$(grep -o "\"author.*" package.json)
name=$(grep -o "\"name.*" package.json)
desc=$(grep -o "\"desc.*" package.json)
version=$(grep -o "\"version.*" package.json)

cd /tmp
git clone git@github.com:RyanHendricks/doxity-simpleton.git
cd doxity-simpleton

awk -v na="$version" '{gsub(/\"version\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json
awk -v na="$homepage" '{gsub(/\"homepage\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json
awk -v na="$url" '{gsub(/\"url\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json
awk -v na="$author" '{gsub(/\"author\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json
awk -v na="$name" '{gsub(/\"name\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json
awk -v na="$desc" '{gsub(/\"description\":.*?/,na);}1' package.json > package.tmp && mv package.tmp package.json

cp $path/README.md .
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