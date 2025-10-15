1.1
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INT, CHECK (age BETWEEN 18 AND 65),
    salary INT, CHECK (salary > 0)
);

1.2
CREATE TABLE products_catalog (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
        )
);

1.3
CREATE TABLE booking (
    booking_date INT PRIMARY KEY,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INT CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

1.4
INSERT INTO employees VALUES (1, 'john', 'smith', 17, 15000),
                             (2, 'alice', 'joy', 20, 0);

-- ERROR: new row for relation "employees" violates check constraint "employees_age_check"
Detail: Failing row contains (1, john, smith, 17, 15000).

-- ERROR: new row for relation "employees" violates check constraint "employees_salary_check"
Detail: Failing row contains (2, alice, joy, 20, 0).


INSERT INTO employees VALUES (1, 'john', 'smith', 18, 15000),
                             (2, 'alice', 'joy', 20, 12000);




INSERT INTO products_catalog VALUES (1, 'coca-cola', 0, 3),
                                    (2, 'twix', 3, 0),
                                    (3, 'beef_steak', 20, 25);

--ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"
  Detail: Failing row contains (1, coca-cola, 0, 3).

--ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"
  Detail: Failing row contains (2, twix, 3, 0).

--ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"
  Detail: Failing row contains (3, beef_steak, 20, 25).


INSERT INTO products_catalog VALUES (1, 'coca-cola', 5, 3),
                                    (2, 'twix', 3, 2),
                                    (3, 'beef_steak', 20, 13);




INSERT INTO booking VALUES (1, '2025-01-01', '2025-01-08', 0),
                           (2,'2025-02-02', '2025-02-16', 13),
                           (3, '2025-03-03', '2025-02-03', 7);

--ERROR: new row for relation "booking" violates check constraint "booking_num_guests_check"
  Detail: Failing row contains (1, 2025-01-01, 2025-01-08, 0).

--ERROR: new row for relation "booking" violates check constraint "booking_num_guests_check"
  Detail: Failing row contains (2, 2025-02-02, 2025-02-16, 13)

--ERROR: new row for relation "booking" violates check constraint "booking_check"
  Detail: Failing row contains (3, 2025-03-03, 2025-02-03, 7).


INSERT INTO booking VALUES (1, '2025-01-01', '2025-01-08', 3),
                           (2,'2025-02-02', '2025-02-16', 9),
                           (3, '2025-03-03', '2025-03-24', 7);

2.1
CREATE TABLE customers (
    customer_id INT PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

2.2
CREATE TABLE inventory (
    item_id INT PRIMARY KEY NOT NULL,
    item_name TEXT NOT NULL,
    quantity INT NOT NULL, CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL, CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

2.3
INSERT INTO customers VALUES (NULL,'john@gmail.com', '4242', '2025-01-01'),
                             (2, 'alice@gmail.com', '5252', '2025-02-02');

--ERROR: null value in column "customer_id" of relation "customers" violates not-null constraint
  Detail: Failing row contains (null, john@gmail.com, 4242, 2025-01-01).

INSERT INTO customers VALUES (1,'john@gmail.com', '4242', '2025-01-01'),
                             (2, 'alice@gmail.com', '5252', '2025-02-02');

3.1
CREATE TABLE users (
    user_id INT,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

3.2
CREATE TABLE course_enrollments (
    enrollment_id INT,
    student_id INT,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_code, semester)
);

3.3
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username),
ADD CONSTRAINT unique_email UNIQUE (email);

4.1
CREATE TABLE departments (
    dept_it INT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

4.2
CREATE TABLE student_courses (
    student_it INT,
    course_id INT,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_it, course_id)
);

4.3
-- 1) PRIMARY KEY: uniquely identifies rows; implicitly NOT NULL; table can have only one PK.
--    UNIQUE: enforces uniqueness but allows NULLs (unless declared NOT NULL); can have many UNIQUE constraints.
-- 2) Use single-column PK when a single attribute uniquely identifies rows (e.g., id).
--    Use composite PK when uniqueness requires combination of columns (e.g., student_id + course_id).
-- 3) Only one PRIMARY KEY allowed because it defines the principal unique identifier for the row; multiple UNIQUE constraints are allowed because they enforce other uniqueness rules.


5.1
CREATE TABLE employees_dept (
    emp_id INT PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INT REFERENCES departments(dept_it),
    hire_date DATE
);

5.2
CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INT REFERENCES authors(author_id),
    publisher INT REFERENCES publishers(publisher_id),
    publication_year INT,
    isbn INT UNIQUE
);

5.3
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INT REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products_fk(product_id),
    quantity INT CHECK (quantity > 0)
);

6.1
CREATE TABLE e_customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE e_products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE e_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES e_customers(customer_id) ON DELETE SET NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE e_order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES e_orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES e_products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);
