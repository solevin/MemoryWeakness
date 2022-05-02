#!/bin/sh

rm settings.json

echo "{
    \"database_name\": \"myDatabase.db\",
    \"database_version\": 1,
    \"create_table_sql\": [
        \"CREATE TABLE meatImages (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, kind TEXT NOT NULL, state INTEGER NOT NULL)\"
    ],
    \"insert_record_sql\": [" >> settings.json

for file in `find ../images -maxdepth 1 -type f`; do
    fileName=${file##*/}
    tmp=${fileName%_*}
    echo "        \"INSERT INTO meatImages(name, kind, state) VALUES('$fileName' ,'${fileName%%_*}' ,${tmp##*_})\"," >> settings.json
done

echo "    ],
    \"is_init_database\": false,
    \"is_show_database_viewer\": false
}" >> settings.json