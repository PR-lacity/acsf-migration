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