#!/bin/bash

# Run from root: chmod +x scripts/build.sh in terminal to give permission first
# COMMAND: ./scripts/build.sh
# COMMAND (once build.sql is created): mysql -u root -p < db/build/build.sql
echo "Building SQL file..."

# Concat content from all these files and put them in db/build/build.sql
cat \
scripts/init.sql \
db/01_schema/tables.sql \
db/01_schema/constraints.sql \
db/02_procedures/id_generation.sql \
db/03_triggers/user_triggers.sql \
db/03_triggers/transaction_triggers.sql \
db/03_triggers/entity_triggers.sql \
db/04_seeds/seed_basic.sql \
> db/build/build.sql

# Echo to verify 
echo "Done: build.sql created at db/build/build.sql"

# Use Mysql and use the build.sql
mysql -u root -p < db/build/build.sql

# Echo to verify 
echo "Database ready"