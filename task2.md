# Task 2

Database Connection and Table Verification

## Part 1

### Task

- Check if your SQL data source is available (in this case, simply an SQLite DB)
- Check if you can connect to the DB
- Ensure that the 3 tables exist
- If they do not exist, they should be created

### Answer

First we need sqflite and path which are imported via

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.2.7
  path: ^1.8.3
```

* * *

next we create a new file called **"sqlmanage.dart"**

* * *

inside we code our sqllite db handling, where we check for the avaiability of the file, and if the database even exists

if it does not exist, we need to create the sqlite file, else we continue to check for the 3 tables if they exist if not, we need to create them

* * *

now we need to display the existing tables. if a connection is existing, there will be a button saying: "view database", which is going to another screen with a statless widget showing the database tables with their content. (each view for a table is selectable inside a sidebar. and you can go back the the main screen with the bakc button on the top left)

## Part 2

In the context of SQLite, please check the table conventions again.. I believe it is PascalCase in MYSQL.. but in most databases, Snake Case is used, which I actually prefe


## Task State

DONE
