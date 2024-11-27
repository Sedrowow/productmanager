# Task 1

How do the tables in SQLite look like?

## Answer

there will be three tables:

1. **[Products]:** here are products listed in stock with "ProductID {INT}", "Name {TEXT}", "Description {TEXT}", and "SellPrice {REAL}".
    1. ProductID will be auto increment and not null, as its a primary key
2. **[Persons]:** here are the persons (customers) listed with "CustomerID {INT}", "FirstName {TEXT}", "LastName {TEXT}"
    1. CustomerID will be auto increment and not null, as its a primary key
3. **[Jobs]:** here are the current delivery jobs and shopping orders listed with "OrderID {INT}", "OrderedBy", "OrderedProduct", "Quantity {INT}", "Status {INT}"
    1. OrderID will be auto increment and not null, as its a primary key
    2. OrderedBy is inherited from **[Persons]**CustomerID
    3. OrderedProduct is inherited from **[Products]**ProductID
    4. Quantity is not null, since you order at least 1, and never order nothing
    5. Status is True or False (yes or no), but since True and False are just translated to integers saying 1 and 0, it needs to be INT, as there is no BOOL, value in SQLite

* * *

### Visualiation

#### Products Table

| **Column Name** | **Data Type** | **Description**                               |
|------------------|---------------|-----------------------------------------------|
| `ProductID`      | `INTEGER`     | Auto-incrementing primary key, not null.      |
| `Name`           | `TEXT`        | Name of the product.                         |
| `Description`    | `TEXT`        | Description of the product.                  |
| `SellPrice`      | `REAL`        | Price of the product.                        |

* * *
* * *

#### Persons Table

| **Column Name** | **Data Type** | **Description**                               |
|------------------|---------------|-----------------------------------------------|
| `CustomerID`     | `INTEGER`     | Auto-incrementing primary key, not null.      |
| `FirstName`      | `TEXT`        | First name of the customer.                  |
| `LastName`       | `TEXT`        | Last name of the customer.                   |

* * *
* * *

### Jobs Table

| **Column Name**   | **Data Type** | **Description**                                      |
|--------------------|---------------|----------------------------------------------------|
| `OrderID`          | `INTEGER`     | Auto-incrementing primary key, not null.           |
| `OrderedBy`        | `INTEGER`     | References `Persons.CustomerID`.                   |
| `OrderedProduct`   | `INTEGER`     | References `Products.ProductID`.                   |
| `Quantity`         | `INTEGER`     | Quantity of the product ordered (must be ≥ 1).     |
| `Status`           | `INTEGER`     | Delivery status: `1` for true, `0` for false.      |

* * *
* * *
