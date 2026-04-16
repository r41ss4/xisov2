# About 
The project is a partial design for fintech (XISO) application database using MySQL. It demonstrates database design, data integrity enforcement using constraints and triggers, and basic analytics integration with Python. The database is designed to support a fintech application where users can add funds, withdraw funds and make payment to merchant as payin, payout and deposit, respectively.

## Quick Start
### Initial commands
To run db and analysis in a fast manner:

```bash
# Build DB
chmod +x scripts/build.sh
./scripts/build.sh

# Run build.sql in mysql
mysql -u root -p < db/build/build.sql

# Run Python analysis
python python/main.py
```

### Sample Output

The Python analysis output should be formated as:
USER BALANCE
```bash
usd_account_id | balance
003GZHKD3GW7C4J 12223.92
00ZU9TB3LNILHKE 15361.19
017WVNL2JHTMPMZ 19537.77
02BBQN3KIUP0ZVE 10278.53
...

TRANSACTION SUMMARY
transaction_type | total_tx | total_amount
payin   50001   25032367.94
payout  1001    -12543086.68
deposit 1       -100.00
```

## Project structure
It is primary divided into four main folders as **[db](https://github.com/r41ss4/xisov2/tree/main/db)**, **[docker](https://github.com/r41ss4/xisov2/tree/main/docker)**, **[python](https://github.com/r41ss4/xisov2/tree/main/python)** and **[scripts](https://github.com/r41ss4/xisov2/tree/main/scripts)**, each one containinig multiple files relevant for the project functionalities. 

```bash
xisov2
│           
├── db/         
│   ├── 01_schema/     
│   │   ├── tables.sql  
│   │   └── constraints.sql  
│   ├── 02_procedures/  
│   │   └── id_generation.sql   
│   ├── 03_triggers/
│   │   ├── entity_triggers.sql  
│   │   ├── transaction_triggers.sql
│   │   └── user_triggers.sql
│   ├── 04_seeds/
│   │   ├── seed_basic.sql 
│   │   ├── seed_edge_cases.sql
│   │   └── seed_heavy_users.sql
│   ├── 05_analytics/
│   │   ├── transaction_summary.sql
│   │   └── user_balance.sql
│   └── 06_build/ 
│       └── build.sql
│                       
├── python/                     
│   ├── analysis.py     
│   ├── db.py                
│   ├── queries.py               
│   └── main.py   
│
├── scripts/                     
│   └── build.sh  
│  
├── docker/                     
│   └── Dockerfile                
│  
├── visualization/ 
│   ├── db_diagram.dbml               
│   └── xiso_dbmldiagram.png  
│       
├── internal_guide.md               
└── README.md    
```

### Database and structure

The database, called *xiso_staging*, is created uniquelly by running the file **[db/06_build/build.sql](https://github.com/r41ss4/xisov2/blob/main/scripts/build.sh)**, which is based in most of the files within db's folders. Moreover, the build.sql file is a result of running **[scripts/build.sh](https://github.com/r41ss4/xisov2/tree/main/scripts)**, a bash file that concatenates most of the files within db's folder in a specific order. Therefore, for easier modifications of files, debugging and improving modularity of the project, the files within **[db/](https://github.com/r41ss4/xisov2/tree/main/db)** have self-explanatory names and comments on top of each required step to facilitate spotting their part once they are concadenated in **[db/06_build/build.sql](https://github.com/r41ss4/xisov2/blob/main/db/build/build.sql)**. 

Table and constrains are within the **[db/01_schema/](https://github.com/r41ss4/xisov2/tree/main/db/01_schema)** folder. The database contains multiple tables defined in **[db/01_schema/tables.sql](https://github.com/r41ss4/xisov2/blob/main/db/01_schema/tables.sql)**, which constraints are specified in **[db/01_schema/constraints.sql](https://github.com/r41ss4/xisov2/blob/main/db/01_schema/constraints.sql)**. A detailed text description of the database content is available in **[internal_guide.md](https://github.com/r41ss4/xisov2/blob/main/inter_guide.md)**.

Procedures are located in **[db/02_procedures/id_generation.sql](https://github.com/r41ss4/xisov2/blob/main/db/02_procedures/id_generation.sql)**, as they focus mainly in generating unique id for users, usd accounts, merchants, providers and all type of transactions (payin, payouts and deposits). Meanwhile, triggers are employed to use the procedure in the connect events, such as user creation, when a merchant or financial provider is integrated or when a transaction is done, which are defined in the files within **[db/03_triggers](https://github.com/r41ss4/xisov2/tree/main/db/03_triggers)**. Lastly, the initial seed for the db is defined in **[db/04_seeds/seed_basic.sql](https://github.com/r41ss4/xisov2/blob/main/db/04_seeds/seed_basic.sql)**. All previous mentioned folders and  files are included in build.sh and, therefore, build.sql to properly create the db. 

To actually create the database, it is necesary to run **[script/build.sh](https://github.com/r41ss4/xisov2/blob/main/scripts/build.sh)**, which generates the file **[db/06_build/build.sql](https://github.com/r41ss4/xisov2/blob/main/db/build/build.sql)** by concadenating the files mentioned. Once it is created, it only needs to be run in the terminal. To do such steps you can run the following commands (standing in xisov2 folder): 

```bash
# Give permisions to bash script
chmod +x scripts/build.sh 

# Run the bash script to create build.sql
./scripts/build.sh

# Run build.sql in mysql
mysql -u root -p < db/build/build.sql
```

### Analysis and seeds
The two remaining seed in **[db/04_seeds/](https://github.com/r41ss4/xisov2/tree/main/db/04_seeds)** are **[seed_edge_cases.sql](https://github.com/r41ss4/xisov2/tree/main/db/04_seeds/seed_edge_cases.sql)** and **[seed_heavy_users.sql](https://github.com/r41ss4/xisov2/blob/main/db/04_seeds/seed_heavy_users.sql)**. While the first one is excluded from the **[script/build.sh](https://github.com/r41ss4/xisov2/blob/main/scripts/build.sh)** as some of the inserts must return error, the second one is experimental as it inserts aroun 1000 random users which transactions (only payin and payout) and not key to create the database. Run them using the following commands (standing in xisov2 folder):

```bash
# Run mysql
mysql -u root -p 

# Source seed_edge_cases.sql
SOURCE db/04_seeds/seed_edge_cases.sql
```

```bash
# Run mysql
mysql -u root -p 

# Create procedure seed_heavy_users()
SOURCE db/04_seeds/seed_heavy_users.sql

# Call procedure seed_heavy_users()
CALL seed_heavy_users()
```

Moreover, in **[db/05_analytics/](https://github.com/r41ss4/xisov2/tree/main/db/05_analytics)** there are two files for testing the ledger created in the database, which can be run manually within mysql using the following commands (standing in xisov2 folder): 

```bash
# Run mysql
mysql -u root -p 

# Source transaction_summary.sql
SOURCE db/05_analytics/transaction_summary.sql

# Source user_balance.sql
SOURCE db/05_analytics/user_balance.sql
```

However, the actual analysis should be done using the files in the folder **[python/](https://github.com/r41ss4/xisov2/tree/main/python)**, which contains multiple python scripts. The four files work together, being **[python/main.py](https://github.com/r41ss4/xisov2/blob/main/python/main.py)** the one calling functions from the other three. This last one connects to the database in mysql and extracts two key insights: USER BALANCE as balance by user and TRANSACTION SUMMARY as all transactions by type. The output is mirrows to the analysis done in **[db/05_analytics/](https://github.com/r41ss4/xisov2/tree/main/db/05_analytics)** while testing the db in mysql. 

```bash
# Run python script
python python/main.py
```

### Docker 
The project is complemented with the option to dockerize the database instead of only running it locally. To do the following commands need to be run:

```bash
# Build docker image
docker build -t xiso-db -f docker/Dockerfile .

# Run docker image and expose it
docker run -d -p 3307:3306 --name xiso-container xiso-db

# Connect to the docker db
docker exec -it xiso-container mysql -u root -p root_password
```

If seeds and other parts of the analytics projects are desired to be execute, such as **[db/04_seeds/seed_heavy_users.sql](https://github.com/r41ss4/xisov2/blob/main/db/04_seeds/seed_heavy_users.sql)**, this can be done through the terminal and connecting to mysql within the container. The following commands can help to do so:
```bash
# Run db/04_seeds/seed_heavy_users.sql in container
docker exec -i xiso-container mysql -u root -proot_password xiso_staging < db/04_seeds/seed_heavy_users.sql

# Run container mysql
docker exec -it xiso-container mysql -u root -p 

# Call seed_heavy_users()
CALL seed_heavy_users();
```

The process can also be done with the files in **[db/05_analytics/](https://github.com/r41ss4/xisov2/tree/main/db/05_analytics)**. The following commands can help to do so:

```bash
# Run db/05_analysis/transaction_summary.sql in container
docker exec -i xiso-container mysql -u root -proot_password xiso_staging < db/05_analytics/transaction_summary.sql

# Run db/05_analysis/user_balance.sql in container
docker exec -i xiso-container mysql -u root -proot_password xiso_staging < db/05_analytics/user_balance.sql
```