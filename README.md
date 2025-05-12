
# ☕ Monday Coffee SQL Project

### 📚 A Data Analytics Project Using PostgreSQL

---

## 📌 Overview

**Monday Coffee** is a simulated SQL project designed to answer real-world business questions for a fictional coffee company expanding its operations across multiple cities. The project involves designing a relational database, importing mock data, and executing strategic queries to generate insights into customer behavior, sales patterns, and market potential.

This project is ideal for demonstrating skills in:

- Database schema design
- SQL query development
- Data-driven business decision-making
- Relational data analysis using PostgreSQL

---

## 🧱 Database Design

The project includes four key tables:

---

### 1. `city` – 📍 Market Demographics

This table holds basic information about each city where the coffee business operates or plans to expand.

```sql
CREATE TABLE city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(15),
    population BIGINT,
    estimated_rent FLOAT,
    city_rank INT
);
```

**Explanation:**
- `city_id`: Unique ID for each city.
- `city_name`: Name of the city (e.g., Austin, Boston).
- `population`: Total population size.
- `estimated_rent`: Average monthly rent, used to understand cost of living.
- `city_rank`: A manually defined rank to prioritize cities.

---

### 2. `customers` – 👥 Coffee Buyers

Holds individual customer details and links them to their respective cities.

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25),
    city_id INT REFERENCES city(city_id)
);
```

**Explanation:**
- `customer_id`: Unique identifier for each customer.
- `customer_name`: Full name of the customer.
- `city_id`: Links the customer to the city they reside in.

---

### 3. `products` – ☕ Coffee Products

Contains data on all coffee products offered by the company.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(35),
    price FLOAT
);
```

**Explanation:**
- `product_id`: Unique identifier for the coffee product.
- `product_name`: Name of the product (e.g., Espresso, Latte).
- `price`: Selling price per unit.

---

### 4. `sales` – 💰 Transaction Records

Captures all sales transactions, including product sold, amount, and customer feedback.

```sql
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    total FLOAT,
    rating INT
);
```

**Explanation:**
- `sale_id`: Unique ID for the sale.
- `sale_date`: When the transaction happened.
- `product_id`: Coffee product that was purchased.
- `customer_id`: Who purchased it.
- `total`: Total cost of the sale.
- `rating`: Customer satisfaction rating (1 to 5).

---

## 🔍 Business Questions & SQL Queries

### ✅ Q1: Estimated Coffee Consumers per City

**Business Goal:**  
Estimate how many people might consume coffee in each city. Assuming 25% of each city's population are coffee drinkers.

```sql
SELECT 
    city_name,
    population * 0.25 AS coffee_consumers,
    city_rank
FROM city
ORDER BY coffee_consumers DESC;
```

**Explanation:**
- Calculates 25% of each city’s population.
- Helps identify cities with the largest potential market.

---

### 🧠 Future Business Questions to Explore

- **What is the average customer rating for each product?**
- **Which customer has made the highest total purchases?**
- **What is the total revenue generated in each city?**
- **Which cities show the highest coffee consumption relative to population?**
- **Do higher rents correlate with higher product pricing or sales volume?**

---

## 🛠️ Tech Stack

| Tool       | Purpose                   |
|------------|---------------------------|
| PostgreSQL | Relational database engine |
| SQL        | Query language             |
| pgAdmin    | GUI client for SQL         |

---

## 🚀 How to Use This Project

1. Clone or download the repository.
2. Open `monday_coffee.sql` in your SQL environment (like pgAdmin).
3. Execute the table creation and sample queries.
4. Expand the project by adding mock data or writing new SQL queries.

---

## 📁 Files Included

- `monday_coffee.sql`: Full SQL script including table definitions and sample queries.
- `README.md`: This file, explaining the entire project in detail.

---

## 📬 Contact

For feedback or collaboration, reach out:

**Your Name**  
✉️ your.email@example.com  
🌐 your-portfolio.com

---
