#!/bin/bash
read -r -p "Enter the site name to search for: " SITENAME
echo ""
echo "==================================================="
echo "Searching for $SITENAME"
echo "==================================================="
echo ""
drush site:alias | grep $SITENAME
#Can also use drush sa
echo ""
echo "Copy the site alias between the @ and the environment (.01dev2) for the desired site"
echo ""
read -p "Was the site you were looking for found?  Y/N  " -n 1 -r SITEFOUND
echo    # (optional) move to a new line
if [[ ! $SITEFOUND =~ ^[Yy]$ ]]
then
    exit 1
fi
read -r -p "Enter the copied site alias: " SOURCEALIAS
echo ""
echo "==================================================="
echo "Dropping database from @$SOURCEALIAS.01test" 
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01test sql-drop
echo ""
echo "==================================================="
echo "Uploading database from dump to @$SOURCEALIAS.01test"
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01test sql-cli < ./tmp/$SOURCEALIAS/archive.sql
echo ""
echo "==================================================="
echo "Enabling ACSF Modules from @$SOURCEALIAS.01test"
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01test en acsf acsf_sso acsf_sj acsf_variables acsf_duplication acsf_theme
echo ""
echo "==================================================="
echo "Uploading files to @$SOURCEALIAS.01test"
echo "==================================================="
echo ""
drush -v rsync ./tmp/$SOURCEALIAS/files/ @$SOURCEALIAS:%files/
echo ""
echo "==================================================="
echo "Running CRON and clearing cache"
echo "==================================================="
drush @$SOURCEALIAS.01test CRON
drush @$SOURCEALIAS.01test cr
echo ""
echo "Finished"