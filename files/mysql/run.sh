#!/bin/bash

# Read all arguments in command line
while [ $# -gt 0 ]; do
	if [[ $1 == *"--"* ]]; then
		param="${1/--/}"
		param="${param/-/_}"
		IFS='=' read -r param value <<< "$param"
		[[ $value == "" ]] && value=$2
		[[ $value == *"--"* || $value == "" ]] && value=true
		declare $param="$value"
	fi
	shift
done

# Parameters
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -z "$password" ]; then
	read -p 'Enter root password: ' -s password
	echo '******'
	read -p 'Confirm root password: ' -s password_bis
	echo '******'
else
	password_bis=$password
fi

while [ -z "$password" ] || [ "$password" != "$password_bis" ]; do
	echo 'Password error!'
	read -p 'Enter root password: ' -s password
	echo '******'
	read -p 'Confirm root password: ' -s password_bis
	echo '******'
done

while [ -z "$name" ]; do
	read -p 'Name: ' name
done

[ "$port" = "" ] && port="3306"
[ "$network" = "" ] && network="network-$name"

if [ -z "$config" ]; then
	config="$DIR/my-$name.cnf"

	if [ ! -e "$config" ]; then
		cp "$DIR/my.cnf" "$config"
	fi
fi

[ "$version" = "" ] && version="latest"

# Create network
docker network create "$network" 2>/dev/null

# Create mysql volume
docker volume create "mysql-$name" 2>/dev/null

# Stop and delete existing container
docker stop "mysql-$name" 2>/dev/null
docker rm "mysql-$name" 2>/dev/null

# Run mysql container
docker run --pull always --name "mysql-$name" --network "$network" --restart always -e MYSQL_ROOT_PASSWORD="$password" -v "$config":/etc/mysql/conf.d/mysql.cnf -v "mysql-$name":/var/lib/mysql -d -p 127.0.0.1:"$port":3306 "mysql:$version"