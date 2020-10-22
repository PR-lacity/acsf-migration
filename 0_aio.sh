#!/bin/bash
echo "==================================================="
echo "Updating BLT Aliases"
echo "==================================================="
echo ""
rm -r drush/sites
./vendor/bin/blt aliases
echo "==================================================="
echo "Updating Site YML Files"
echo "==================================================="
echo ""
find ./drush/sites -type f -exec sed -i "s/ssh: { options: '-p 22' }/ssh: { options: '-p 22', tty: 0 }/g" {} +
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
drush -v rsync @$SOURCEALIAS.01live:%files ./tmp/$SOURCEALIAS/files
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
    #No error.  Continue
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
    exit 0
fi
#Fix the error, then continue
drush @$SOURCEALIAS.01live config:delete acsf.settings
drush @$SOURCEALIAS.01live en acsf acsf_sso acsf_sj acsf_variables acsf_duplication acsf_theme
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
