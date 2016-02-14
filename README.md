# drupal-wizard
Bash script for wizard Drupal installations

###  What is it for?

Automate the often tedious and repetitive Drupal installation process leveraging on templates for modules
installation and post-installaztion drush commands. The script uses drush under the hood.
![image]
(http://content.screencast.com/users/AntonioPantano/folders/Jing/media/ab143991-1d8b-4669-a41e-448602d45ff4/00000007.png)

### How does it work?

Simply running a bash script 
```bash
dwiz
```
![Image 2]
(http://content.screencast.com/users/AntonioPantano/folders/Jing/media/719ead05-3090-4ad0-b2bc-4cce8f06e19f/00000008.png)

- The simplest usage is <code>dwiz</code>
- You can also provide additioanl argumentsa (<code>-c</code>, <code>-m</code>) that specify, respectively, 
a file name containing a list of modules to be installed:
```
dwiz -m d7.modules
```
or a file name containing a list of drush post-installatiom commands (such as enabling modules):
```
dwiz -c d7.commands
```

> A bunch of templates files for both modules installations and commands to execute are provided as 
global file inside the <code>~/.drupal-wizard/commands</code> or <code>~/.drupal-wizard/modules</code>.

### Requirements
- OS must support bash scripts 
Linux and Mac OS are compatible. 
Windows has not been tested but most likely requires external tools such as git bash.   

- Drush installed (Tested with versions 7 and 8)

### Installation
1. Clone this repo <code>git clone https://github.com/ovidius72/drupal-wizard.git ~/.drupal-wizard</code>
2. For Unix like system (linux or Mac) update you .bashrc or .zshrc user file: <code>export PATH="$PATH:${HOME}/.drupal-wizard"</code>


### Usage
The script will ask you several info such as the site name, and the site email, the administrator credentials and email,
information about the database server url and host address and the database wich you want install drupal in.
> it is not required that the database already exists. The script will take care of creating a new one using 
the parameter you pass in.

As for drush site-install behaviour the script must be run from one level up the destination folder.
E.g Suppose you want to install a new drupal site in the folder ```/var/www/d7```:
1. run ```dwiz``` when you are asked for the **web server absolute root** you will type /var/www
2. when you are asked to provide the web server relative sub-path you will type ```d7``` 
and the installation will be performed inside ```/var/www/d7```

> Similary, if you wish to install the site directly in the main `/var/www` server path, 
you will type `/var` for the root path and `www` for the leading path.

**Do not provide any leading slash for the root. 
The sub path must not contains any starting slash but can contains deepest sub-paths such as `d7/public`**

#### Passing arguments
As stated above the script accepts two arguments:
- `dwiz -c filename` for post-installation commands to execute
- `dwiz -m filename` for modules to download and, eventually, enable during the installation.
- The two arguments can be passed together ` dwiz -c filename -m filename`

`filename`, as above, represent a filename the script will search for, starting from the directory the script in executed.
If `filename` doesn't exists there, the search will be performed inside the global `~/.drupal-wizard` directories, 
seraching in the `/commands` folder for the files specified in the `-c` argument and in the `/modules` 
folder for the file specified in the `-m` argument.

This structute allows to have a global set of templates one can reuse when needed or a 
web site specific templates for special cases.

#### Tips
You can have a template for plain drupal 7 website that always requires most used modules, 
such as views, ds, pathauto, context and so on, so you can create a template called d7.modules,
one template for drupal 7 commerce (or ubercart) websites that require other modules such as commerce, commerce-discount, 
and so on called d7-commerce.modules, and a drupal 8 template that requires different modules from drupal 7.
In the commands templates you can specify commands drush must execute at the end of the installation process. 
Typical usage is enable new downloaded modules or clearing the cache.

### Templates format
####modules: 
a module template file must be structured as follow:
```
module_1_name (as for the drupal site name convention) »(tab) y|n (if the module must be also enabled)
module_2_name (as for the drupal site name convention) »(tab) y|n (if the module must be also enabled)
......
```
Example: 
```
token   n
rules   y
views   y
``` 
will download the specified module accepting or not additional 
action required by drush (confirmations or dependencies)

####commands: 
a commands template file must be structured as follow:
```
drush_action_1
drush_action_2
........
```
Example:
```
en -y rules
colorbox-plugin
dis -y toolbar
cc all
```


