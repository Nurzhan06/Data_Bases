3.1
CREATE TABLE accounts (
 account_id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
 product_id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);

3.2
BEGIN TRANSACTION;
UPDATE accounts
SET balance = balance - 100
WHERE name = 'Alice';
UPDATE accounts
SET balance = balance + 100
WHERE name = 'Bob';
COMMIT;
Qa: Alice has 900, Bob has 600
Qb: This operation is completely successful or completely unsuccessful, so no problems in between would make data inconsistent
Qc: Alice would send 100, but Bob would not get it, these 100 would be lost

3.3
BEGIN;
UPDATE accounts
SET balance = balance - 500
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
Qa: After update but before rollback Alice had 500
Qb: After rollback she has 900
Qc: wrong transfer

3.4
BEGIN;
UPDATE accounts
SET balance = balance - 100
WHERE name = 'Alice';
SAVEPOINT SP1;
UPDATE accounts
SET balance = balance + 100
WHERE name = 'Bob';
ROLLBACK TO SP1;
UPDATE accounts
SET balance = balance + 100
WHERE name = 'Wally';
COMMIT;
Qa: Alice - 800, Bob - 600, Wally - 750
Qb: Bob has received money by mistake but it was rolled back, his balance is unchanged
Qc: it undoes only certain part of transaction, which is convenient in complex transactions

3.5 A)
T1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

T2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products(shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

T1
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

3.5 B)
T1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

T2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products(shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

T1
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
Qa: in A) T1 before commit sees coke and pepsi, after commit only fanta
Qb: in B) T1 before and after sees coke and pepsi 
Qc: in READ COMMITTED it sees new committed data, allows phantom read, but SERIALIZABLE sees consistent snapshot and prevents phantom reads


3.6
T1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT max(products.price), min(products.price)
FROM products

T2
BEGIN;
INSERT INTO products(shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

T1
SELECT max(products.price), min(products.price)
FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
Qa: terminal 1 does not see new product
Qb: phantom reads occurs when same query in transaction returns different result because another transaction added or removed some data
Qc: phantom reads are preventable only by serializable isolation level

3.7
T1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';

T2
BEGIN;
UPDATE products
SET price = 99.99
WHERE product = 'Coke';

T2
BEGIN;
UPDATE products
SET price = 99.99
WHERE product = 'Coke';
ROLLBACK;

T1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
Qa: T1 sees 99.99 even though it is uncommitted. It is problematic because it may later be rolled back, which mean we have fare data
Qb: dirty reads occurs when transaction reads data that another transaction has modified but not committed yet
Qc: Read uncommitted should be avoided since it produce inconsistency, incorrect queries and violates isolation