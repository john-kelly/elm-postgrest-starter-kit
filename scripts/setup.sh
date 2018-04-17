source ../.env \
    && createdb $DB_NAME \
    && psql --dbname=$DB_NAME --file=../src/backend/init.sql
