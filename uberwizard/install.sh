#!/bin/bash
clear
startdir=$(echo `pwd`)
sdir=$(dirname "$0")
sdir=${sdir#*/}

echo "Welcome to Drupal Wizard Installation"
echo
echo
echo "Run this script inside the webserver root directory where your web projects are located."
echo "E.g. if your webserver root is /var/www then place the script directory inside it"
echo "so you have /var/www/$sdir/. Then from the root server directory run $0"
echo
echo "A directory with the name you'll provide will be created and Drupal will be installed inside it"
echo "The modules listed in the module.list file will also be installed."
echo "Feel free to add or remove modules editing that file."
echo "Drush will performs all tasks for you."
echo
echo "If you are ready to start enter [y], otherwise if you whish to customize the installation exit with [n] and perform the modifications you want inside the module.list file, then run this script again."
echo 
echo 

read -p "Do you wish to continue?[y/n] [y] " goahed

if [[ $goahed == "y" || $goahed == "" ]]; then # yes, continue
	echo "I will continue"
	clear
else
	echo "Exiting.."
	echo "Bye."
	exit
fi

echo -en '\E[47;31m'"\033[1mPlease be careful.
Database and folder already existing will be overwritten.\033[0m\n\n"

##################### The script is running, declare some variables ############
declare install_path="MySite" site_name="My Drupal Site" account_name="admin" account_passw="admin"
declare db_url="mysql://" db_host="localhost" db_root_name="root" db_root_pw="root" 
declare db_name="mysite" db_user="drupal" db_pass="drupal" 


######################  WebSite informations  ##################################
#Infromations about the website drush is going to create
#
read -p "Enter the path you wish to install Drupal [$install_path]: " path
[[ $path = '' ]] && install_path="$install_path" || install_path="$path"

read -p "Enter the website name [$site_name]: " sitename
[[ $sitename = '' ]] && site_name="$site_name" || site_name="$sitename"

read -p "Enter the administrator account name for the website [$account_name]: " name
[[ $name = '' ]] && account_name="$account_name" || account_name="$name"

read -p "Enter the administrator account password for the website [$account_passw]: " passw
[[ $passw = '' ]] && account_passw="$account_passw" || account_passw="$passw"

######################  Database Server Informations  ##########################
#Database server connection informations
# 
read -p "Enter the Database Server URL [$db_url]: " dburl
[[ $dburl = '' ]] && db_url="$db_url" || db_url="$dburl"

read -p "Enter the Database Host Address [$db_host]: " dbhost
[[ $dbhost = '' ]] && db_host="$db_host" || db_host="$dbhost"

read -p "Enter the Database Server root username [$db_root_name]: " dbrootname
[[ $dbrootname = '' ]] && db_root_name="$db_root_name" || db_root_name="$dbrootname"

read -p "Enter the Database Server root password [$db_root_pw]: " dbrootpassw
[[ $dbrootpassw = '' ]] && db_root_pw="$db_root_pw" || db_root_pw="$dbrootpassw"

#####################  Website Database Information  ###########################
# Informations about the database drush is going to create for the website
#
read -p "Enter the Database Name you wish to install the Website [$db_name]: " dbname
[[ $dbname = '' ]] && db_name="$db_name" || db_name="$dbname"

read -p "Enter the username the website uses to access the database [$db_user]: " dbuser
[[ $dbuser = '' ]] && db_user="$db_user" || db_user="$dbuser"

read -p "Enter the password the website uses to access the database [$db_pass]: " dbpass
[[ $dbpass = '' ]] && db_pass="$db_pass" || db_pass="$dbpass"



clear

echo -e "Review below informations before staring installation:"
echo
echo -e "Website related information:"
echo -e "\tDrupal will be installed into this directory: " $install_path
echo -e "\tWebsite name: "$site_name""
echo -e "\tWebsite administrator username: $account_name"
echo -e "\tWebsite administrator password: $account_passw"
echo
echo -e "Database Server informations:"
echo -e "Drupal will use these informations to connect to the database server."
echo -e "\tDatabase Server URL: $db_url"
echo -e "\tDatabase Host Address $db_host"
echo -e "\tDatabase root userbame: $db_root_name"
echo -e "\tDatabase root password: $db_root_pw"
echo
echo -e "Website Database informations:"
echo -e "Drupal will use these informations to create a new database"
echo -e "\tThis database will be created: $db_name"
echo -e "\tDrupal Database username: $db_user"
echo -e "\tDrupal Database password: $db_pass"
echo
echo
echo "A new Drupal website will be installed in: `pwd`/${install_path}"


scriptdir="$(dirname "$0")"
#echo "The script is located at: ${startdir}/${scriptdir}"
workingdir=$(echo $startdir)"/"$(echo $install_path)
#echo "The working directory is: $workingdir"
module_file="${startdir}/${scriptdir}/modules.list"
commands_file="${startdir}/${scriptdir}/commands"
#echo "The file name containing the list of modules to download is located at: $module_file"
echo
echo

while true; do
	read -p "Are the informations correct? [y/n]" correct
	
	case $correct in
		[Yy]* ) echo "Starting installation...."; break;;
		[Nn]* ) echo "Please start the script again and make needed corrections."; exit;;
		*  ) echo "Please answer yes[y] or not[n].";;
	esac
done

echo
echo
echo "Downloading latest Drupal release"
echo "Please wait until this task is finished. This may take a few minutes."
echo "....."

### Download latest drupal release	#########
drush dl drupal --drupal-project-rename=$install_path

echo
echo "Latest Drupal release has been downloaded at " `pwd`
echo
echo "Please wait while drush is performing installation tasks..."
echo
cd $workingdir

###	Install Drupal using drush  ########
drush site-install standard --account-name=${account_name} --account-pass=${account_passw} --db-url=${db_url}${db_user}:${db_passw}@${db_host}/${db_name} --db-su=${db_root_name} --db-su-pw=${db_root_pw} --site-name="${site_name}"

if [ $? != 0 ]; then
	echo "Drush has encountered a problem. Please review the information you provide and try again."
	exit
fi
 
echo
echo "Drush is now downloading all modules listed in module.list"
echo


## Recursively download and (if set) enable modules from module.list file.
while IFS=$'\t': read -r module enabled
do
	if [ "$module" != "" ];
	then
		echo "drush is downloading $module module"
		drush dl -n $module
			if [[ $enabled == "y" ]]; then
				echo "Enabling module $module"
				drush en -y $module
			fi
		echo
	fi
done < "$module_file"


###	Perform recursively additional drush commands listed in commands files.
while IFS=$'\n': read -r action
do
	if [ "$action" != "" ];	then
		echo
		echo "drush is performing [drush $action]"
		drush $action
	fi
done < "$commands_file"
echo
echo
echo "Review if there were errors during the process."
echo "If not you can vist your new website at http://[your-local-webserver]/$install_path"
echo 
echo "All tasks are completed."
echo
echo
