# Setup

**INIT Postgres by looking at the migations/init.sql**

##### Server
```
/server$ yarn
/server$ yarn migrate-up

/client$ yarn
===OR===
/server$ npm i
/server$ npm run migrate-up

/client$ npm i
```

# ETL
Use either running the main.ipynb or just commandline the etl.py file

```
# 1st param is the filename of the dataset
folder_to/data> python3 etl.py dataset.csv

# This will work as well because the default
# filename is dataset.csv
folder_to/data> python3 etl.py
```

# DEV

**SERVER**
```
/server$ yarn dev
===OR===
/server$ npm run dev
```

**CLIENT**
```
/client$ yarn dev
===OR===
/client$ npm run dev
```

Then go to the browser and open http://localhost:3000
