#!/bin/bash
clear
startdir=$(echo `pwd`)
sdir=$(dirname "$0")
sdir=${sdir#*/}

globalDirectory="$HOME/.drupalwizard"
globalModules="${globalDirectory}/modules"
globalCommands="${globalDirectory}/commands"
defaultCommandPath="$startdir/commands.list";
defaultModulesPath="$startdir/modules.list";
foundPath=""

#
# Search for file existence
# @param file to check 
#
function fileExists() {
  if [ -f "$1/$2" ]; then
    return 1;
  else
    return 0;
  fi  
}


#
# Get the file location, seraching from the pwd up to the global directory. 
# @param string: must be either 'module' or 'command'
#
function getFileLocation() {

  #First check if the file exists in the script working directory
  fileExists "${startdir}" "$1"
  if [  $? -eq 1 ]; then
    foundPath="$startdir/$1"
    return
  fi


  #if not the check is perfomed in the .drupalwizard user's home directory
  #either 'module' or 'command' must be specified.
  if [ "$2" == "module" ]; then 
    searchIn=$globalModules
  else
    searchIn=$globalCommands
  fi

  fileExists $searchIn $1
  if [ $? -eq 1 ]; then
    foundPath="$searchIn/$1"
    return
  else
    echo "file $1 not found"
    foundPath=""
    exit
  fi
}

# Parse optional arguments to read the module list and command list file.
# @parameters
#   -m The modules list filename to parse. The wizard will start searching
#      from the script working directory, falling back to the global .drupalwizard directory 
#   -c The commands list filename to parse. The wizard will start searching
#      from the script working directory, falling back to the global .drupalwizard directory 
# for both -c and -m and empty value means to search for the default filename (modules.list and commands.list)    
while getopts "m:c:" option; do
	case $option in
		m) 
      if [ -n $OPTARG ]; then
        getFileLocation $OPTARG 'module'
        m=$foundPath
      fi
      ;;
    c)
      if [ -n $OPTARG ]; then
        getFileLocation $OPTARG 'command'
        c=$foundPath
      fi 
      ;;
    \?)
      echo "Invalid option: - $OPTARG" >&2  
      ;;
  esac
done


echo "*****************************************************************"
echo "Welcome to theDrupal 8 Wizard Installation"
echo
echo
echo "Please, provide the path you wish the installation will be performed to."
echo "A directory with the name you provide will be created and Drupal will be installed inside it"
echo

if [ ! -z $m ]; then 
  echo -e "\e[31mAdditional modules to install are listed in the file $m\e[0m"
fi

echo

if [ ! -z $c ]; then 
  echo -e "\e[31mPost installation commands are listed in the file $c\e[0m"
fi

echo
echo "*****************************************************************"
echo
echo "If you are ready to start enter [y], otherwise if you whish to customize the installation exit with [n] and perform the modifications you want, then run this script again."
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
declare install_path="/var" sub_path="www" site_name="My Drupal Site" account_name="admin" account_passw="admin"
declare db_url="mysql://" db_host="localhost" db_root_name="root" db_root_pw="root" 
declare db_name="mysite" db_user="drupal" db_pass="drupal"
declare locale="en" version="8"
declare adminEmail="email@example.com"
declare webSiteEmail="email@example.com"


######################  WebSite informations  ##################################
#Infromations about the website drush is going to create
#
read -p "Enter the Drupal version you want to install [$version]: " ver
[[ $ver = '' ]] && version="$version" || version="$ver"

read -p "Enter the web server absolute root path [$install_path]: " path
[[ $path = '' ]] && install_path="$install_path" || install_path="$path"

read -p "Enter the relative leading web server sub path where drupal will be installed [$sub_path]: " subPath
[[ $subPath = '' ]] && sub_path="$subPath" || sub_path="$subPath"

read -p "Enter the 2 characters language code. [$locale]: " loc
[[ $loc = '' ]] && locale="$locale" || locale="$loc"

read -p "Enter the website name [$site_name]: " sitename
[[ $sitename = '' ]] && site_name="$site_name" || site_name="$sitename"

read -p "Enter the website email [$webSiteEmail]: " webMail
[[ $webMail = '' ]] && webSiteEmail="$webSiteEmail" || webSiteEmail="$webMail"

read -p "Enter the administrator account name for the website [$account_name]: " name
[[ $name = '' ]] && account_name="$account_name" || account_name="$name"

read -p "Enter the administrator account password for the website [$account_passw]: " passw
[[ $passw = '' ]] && account_passw="$account_passw" || account_passw="$passw"

read -p "Enter the administrator email for the website [$adminEmail]: " mail
[[ $mail = '' ]] && adminEmail="$adminEmail" || adminEmail="$mail"

######################  Database Server Informations  ##########################
#Database server connection informations
# 
read -p "Enter the database server URL [$db_url]: " dburl
[[ $dburl = '' ]] && db_url="$db_url" || db_url="$dburl"

read -p "Enter the database server host address [$db_host]: " dbhost
[[ $dbhost = '' ]] && db_host="$db_host" || db_host="$dbhost"

read -p "Enter the database server root username [$db_root_name]: " dbrootname
[[ $dbrootname = '' ]] && db_root_name="$db_root_name" || db_root_name="$dbrootname"

read -p "Enter the database server root password [$db_root_pw]: " dbrootpassw
[[ $dbrootpassw = '' ]] && db_root_pw="$db_root_pw" || db_root_pw="$dbrootpassw"

#####################  Website Database Information  ###########################
# Informations about the database drush is going to create for the website
#
read -p "Enter the database name drupal will be connected to [$db_name]: " dbname
[[ $dbname = '' ]] && db_name="$db_name" || db_name="$dbname"

read -p "Enter the username the website uses to access the database [$db_user]: " dbuser
[[ $dbuser = '' ]] && db_user="$db_user" || db_user="$dbuser"

read -p "Enter the password the website uses to access the database [$db_pass]: " dbpass
[[ $dbpass = '' ]] && db_pass="$db_pass" || db_pass="$dbpass"


completeInstallPath="${install_path}/${sub_path}"
scriptdir="$(pwd)"
echo "The script is located at: ${startdir}"
workingdir=$(echo $completeInstallPath)
echo "The working directory is: $workingdir"

module_file= $m #"${scriptdir}/modules.list"
echo "The file name containing the list of modules to download is located at: $module_file"
commands_file= $c "${scriptdir}/commands"
echo "The post-installation commands file is located at: $commands_file"
echo
echo


clear

echo -e "Review below informations before staring installation:"
echo
echo -e "Website related information:"
echo -e "\tDrupal will be installed into this directory: " $completeInstallPath
echo
echo -e "\tWebsite name: $site_name"
echo -e "\tWebsite email: $webSiteEmail"
echo -e "\tWebsite language: $locale"
echo
echo -e "\tAdministrator username: $account_name"
echo -e "\tAdministrator password: $account_passw"
echo -e "\tAdministrator email: $adminEmail"
echo
echo -e "Database Server informations:"
echo -e "Drupal will use these informations to connect the server database."
echo -e "\tDatabase Server URL: $db_url"
echo -e "\tDatabase Host Address $db_host"
echo -e "\tDatabase root userbame: $db_root_name"
echo -e "\tDatabase root password: $db_root_pw"
echo
echo -e "Website Database informations:"
echo -e "Drupal will use these informations to create a new database"
echo -e "\tThis database will be created: $db_name"
echo -e "\tDrupal database username: $db_user"
echo -e "\tDrupal database password: $db_pass"
echo
echo
echo "A new Drupal ${version} website will be installed in: ${completeInstallPath}"



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
echo "Downloading latest Drupal 8 release"
echo "Please wait until this task is finished. This may take a few minutes."
echo "....."

### Change directory to the install path
cd $install_path

### Download latest drupal release	#########
drush dl drupal-${version} --destination=${install_path} --drupal-project-rename=${sub_path}
echo
echo "Latest Drupal 8 release has been downloaded at " ${completeInstallPath}
echo
echo "Please wait while drush is performing installation tasks..."
echo

cd $completeInstallPath

###	Install Drupal using drush  ########
drush site-install standard --account-name=${account_name} --account-pass=${account_passw} --account-mail=${adminEmail} --locale=${locale} --db-url=${db_url}${db_user}:${db_passw}@${db_host}/${db_name} --db-su=${db_root_name} --db-su-pw=${db_root_pw} --site-name="${site_name}"

if [ $? != 0 ]; then
	echo "Drush has encountered a problem. Please review the information you provide and try again."
	exit
fi
 
echo
echo "Drush is now downloading all modules listed in module.list"
echo


## Recursively download and (if set) enable modules from module.list file.
if [ "$m" ]; then
  while IFS=$'\t': read -r module enabled
  do
  	if [ "$module" != "" ];	then
  		echo "drush is downloading $module module"
  		drush dl -n $module
  			if [[ $enabled == "y" ]]; then
  				echo "Enabling module $module"
  				drush en -y $module
  			fi
  		echo
  	fi
  done < "$module_file"
fi

###	Perform recursively additional drush commands listed in commands files.
if [ "$c"]; then
  while IFS=$'\n': read -r action
  do
  	if [ "$action" != "" ];	then
  		echo
  		echo "drush is performing [drush $action]"
  		drush $action
  	fi
  done < "$commands_file"
fi
echo
echo
echo "Review if there were errors during the process."
echo "If not you can vist your new website at ${completeInstallPath}"
echo 
echo "All tasks are completed."
echo
echo