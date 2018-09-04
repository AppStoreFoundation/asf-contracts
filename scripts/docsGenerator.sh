#!/bin/sh
cont="/contracts"
path="$( cd $(dirname $0) ; pwd -P)/.."
echo $path
cd $path

homepage=$(grep -o "\"homepage.*" $path/package.json)
url=$(grep -o "\"url.*" $path/package.json )
author=$(grep -o "\"author.*" $path/package.json)
name=$(grep -o "\"name.*" $path/package.json)
desc=$(grep -o "\"desc.*" $path/package.json)
version=$(grep -o "\"version.*" $path/package.json)

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

cd $path
path="$(pwd)"

echo "Moved Documentation to $path/docs"
echo "Moved Doxity website to $path/doxity"
cd /tmp
rm -rf /tmp/doxity-simpleton