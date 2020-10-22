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
echo ""
if [[ ! $SITEFOUND =~ ^[Yy]$ ]]
then
    exit 1
fi
read -r -p "Enter the copied site alias: " SOURCEALIAS
echo ""
echo "==================================================="
echo "Copying files from @$SOURCEALIAS.01live to /tmp/$SOURCEALIAS/files" 
echo "==================================================="
echo ""
mkdir -p tmp/$SOURCEALIAS/files
drush -v rsync @$SOURCEALIAS.01live:%files ./tmp/$SOURCEALIASE/files
echo ""
echo "==================================================="
echo "Uninstalling ACSF Modules from @$SOURCEALIAS.01live"
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01live pmu acsf acsf_sso acsf_sj acsf_variables acsf_duplication acsf_theme
echo ""
echo "==================================================="
echo "Copying database from @$SOURCEALIAS.01live"
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01live sql-dump > ./tmp/$SOURCEALIAS/archive.sql
echo ""
echo "==================================================="
echo "Enabling ACSF Modules from @$SOURCEALIAS.01live"
echo "==================================================="
echo ""
drush @$SOURCEALIAS.01live en acsf acsf_sso acsf_sj acsf_variables acsf_duplication acsf_theme
read -p "Was there an error that the acsf.settings already exists?  Y/N  " -n 1 -r ACSFERROR
echo ""
if [[ ! $ACSFERROR =~ ^[Yy]$ ]]
then
    echo ""
    echo "Finished"
    exit 0
fi
drush @$SOURCEALIAS.01live config:delete acsf.settings
drush @$SOURCEALIAS.01live en acsf acsf_sso acsf_sj acsf_variables acsf_duplication acsf_theme
echo "Finished"