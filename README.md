# acsf-migration

0_aio.sh - Run one script to refresh aliases, modify module configuration, download files/database, drop the current database, upload files/database, modify module configuration, run cron, then clear cache in one continuous script.  All in one script.  

1_refresh.sh - Runs the first step of updating blt site aliases.  Modifies the downloaded aliases by adding tty:0 to prevent database dump command from being written to the console instead of a file as intended.

2_download.sh - Prompts user to search for a site.  Once the user provides the site alias, the script will copy the files from the production environment, disable the acsf modules listed in the ACSF site migration documentation, export the database, then re-enable the acsf modules.  There is a check for a potential error noted in the documentation.  

3_upload.sh - Prompts user to search for a site.  Once the user provides the site alias, the script will drop the database on the test environment, upload the database downloaded from the 2_download.sh script, enable the acsf modules, upload the files from the 2_download.sh script, run cron, then run cache-rebuild to clear caches.  

--------------------------------------------------------------------------------------------------------------

1_refresh.sh
Running 1_refresh.sh requires the user to have set up ssh with acquia cloud and have ssh permissions for the environments.  The only user input needed is to enter their ssh key passphrase to authenticate.


2_download.sh
Running 2_download.sh prompts the user to enter a site name to search for.  Once the user has input a site and pressed enter, a list of sites matching the user’s input will be displayed.  The user will be prompted to respond if the site that was searched for was found.  If the site was not found, pressing anything other than ‘Y’ will end the script.  
The script provides instructions for what to copy.  If the desired site is found, copy the site name excluding the @ and the .##ENVIRONMENT. 
The user will be prompted to enter their ssh key passphrase to copy files, disable modules, copy database, and enable modules.  


3_upload.sh
Running 3_upload.sh prompts the user to enter a site name to search for.  Once the user has input a site and pressed enter, a list of sites matching the user’s input will be displayed.  The user will be prompted to respond if the site that was searched for was found.  If the site was not found, pressing anything other than ‘Y’ will end the script.  
The script provides instructions for what to copy.  If the desired site is found, copy the site name excluding the @ and the .##ENVIRONMENT. 
The user will be prompted to enter their ssh key passphrase to drop the database, import the downloaded database, enable the modules, upload the downloaded files, run cron, and clear caches.  


