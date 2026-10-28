# Experiment 2 — Relational Schema and MySQL Implementation

## Aim
Convert the Experiment 1 Indian e-commerce ER diagram to relational tables and implement the schema in MySQL using primary keys, foreign keys, `NOT NULL`, `UNIQUE`, `ON DELETE CASCADE`, and `ON DELETE SET NULL`. Insert sample data and demonstrate referential integrity.

## Schema
The schema contains Customer, Address, Seller, Category, Product, Orders, OrderItem, Payment, and Delivery. `OrderItem` uses the composite key `(Order_ID, Product_ID)`. Payment and Delivery each enforce one row per order through a unique `Order_ID`.

## Artifact and code
The original experiment file is included unchanged as [`Experiment_2_Relational_Schema_MySQL.pdf`](Experiment_2_Relational_Schema_MySQL.pdf). It contains the full DDL, sample inserts, `SELECT` statements for all tables, and referential integrity examples.

## Output and expected behavior
- The sample `SELECT *` statements display the inserted customers, addresses, sellers, categories, products, orders, order items, payments, and deliveries.
- Inserting an order with `Customer_ID = 999` fails because no matching customer exists.
- Deleting Category 301 sets the related Product's `Category_ID` to `NULL`.
- Deleting Customer 101 cascades to the customer's Address and Orders rows; dependent order items, payments, and deliveries cascade through their own order foreign keys.

## Run
Open the included PDF's Source Code section in MySQL Workbench or another MySQL client and execute its statements in order. The two deletion tests are marked to run separately because they modify the sample data.
