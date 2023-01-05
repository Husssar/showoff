DB_USER=""
DB_PASSWORD=""
DB_URI=""
DB_DATABASE=""
TIBBER_KEY=""


stop_container() {
	docker ps
	echo $1;
	dockerName=$(docker ps -q --filter name=$1)
	if [ -n "$dockerName" ]; then
		docker stop $dockerName
		docker rm $dockerName
	else
		echo "No service with name $1 running"
	fi

}


get_correct_name() {
	service=''
#	echo "Getting correct service name on github"
#	echo "Searching for $1"
	if [ $1 == 'tibber_service' ]; then
		service='tibber'
	elif [ $1 == 'trafikverket_service' ]; then
		service='trafikverket-api'
	fi

	echo $service
}

download_service() {
	echo "Download service for $service"
	location=$(curl -s https://api.github.com/repos/Husssar/$service/releases/latest | grep zipball_url | awk '{ print $2 }' | sed 's/,$//' | sed 's/"//g' );
	echo $location
	wget -O $1 $location

}

extract_service() {
	unzip $1 
}

start_service() {
	path=$(find $PWD -name Husssar* | awk -F"/" '{print $6}')
	pipreqs $path
	cd $path
	docker build -t $2 -f Dockerfile .
	docker run -d --restart unless-stopped --name $1 $2
	cd ..
}

clean_service() {
	path=$(find $PWD -name Husssar* | awk -F"/" '{print $6}')
	rm -rf $path
	rm -rf $1
	rm -rf requirements.txt
	echo "Clean up complete"
}

create_cred() {
	if [ $1 == "tibber" ]; then 
		echo "ok"
	fi

}


install_service() {
	echo "Service to install $1"
	stop_container $1
	service=$( get_correct_name $1 )
	download_service $service
	extract_service $service
	create_cred $service
	start_service $1 $service
	clean_service $service
}

#install_service tibber_service
install_service trafikverket_service 
