# productmanager

## Task Overview

So here is the idea:

Please write a small app that has 3 screens:

Products Screen (Here you can add products (Name, Description))
Persons Screen (Here you can add persons (First Name, Last Name))
Jobs Screen (Main Screen) Here you can write shopping orders.. you can create shopping orders here.. a person buys n products in quantity x - with a status Completed (Yes-No).

The products, persons, and jobs are persisted in an SQLite DB.

At app start, the current state is initially loaded from the DB.

All changes in the app (new/deleted person, new/deleted product, new/deleted job, changed job status) are first held in the state and not directly persisted in SQLite.
In the app, there is a "Save" button, when clicked, the state is synchronized with the DB.
