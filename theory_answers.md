# Theory Questions — Answers

**Football Ticket Booking System | Database Design & SQL Queries**

---

## Question 1

**What role does a Foreign Key play in the Bookings table, and how does it safeguard against entering a ticket sale for a match that doesn't exist?**

### Answer

A **Foreign Key (FK)** is a column (or set of columns) in one table that references the **Primary Key** of another table, creating an enforced link between the two.

In the `Bookings` table, there are two foreign keys:

- `user_id` → references `Users(user_id)`
- `match_id` → references `Matches(match_id)`

**How it prevents invalid data:**

When you try to insert a booking record with a `match_id` that does not exist in the `Matches` table, the database engine immediately raises a **referential integrity violation error** and **rejects the insert**. For example:

```sql
-- This will FAIL because match_id 999 does not exist in Matches
INSERT INTO Bookings (booking_id, user_id, match_id, total_cost)
VALUES (601, 1, 999, 150.00);
-- ERROR: insert or update on table "bookings" violates foreign key constraint
```

This is called **referential integrity** — the database guarantees that every `match_id` in `Bookings` always points to a real, existing match. Without a Foreign Key, you could have "orphan" booking records for matches that never existed, leading to corrupt, unreliable data.

---

## Question 2

**Why are we unable to use an aggregate function like `COUNT(booking_id)` inside a standard `WHERE` clause to filter match rows? How does `HAVING` solve this?**

### Answer

The **`WHERE` clause filters individual rows *before* any grouping or aggregation happens**. At the point when `WHERE` is evaluated, the database hasn't yet calculated aggregate values like `COUNT()`, `SUM()`, or `AVG()` — those are computed *after* rows are grouped. So asking `WHERE COUNT(booking_id) > 2` is logically impossible: the count doesn't exist yet at that stage.

**Execution order in SQL:**

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

`HAVING` is specifically designed to filter **after** grouping and aggregation. It operates on the results of `GROUP BY`, so aggregate functions are fully available.

**Example — Find matches with more than 2 bookings:**

```sql
-- WRONG: Cannot use COUNT in WHERE
SELECT match_id, COUNT(booking_id)
FROM Bookings
WHERE COUNT(booking_id) > 2   -- ERROR
GROUP BY match_id;

-- CORRECT: Use HAVING after GROUP BY
SELECT match_id, COUNT(booking_id) AS total_bookings
FROM Bookings
GROUP BY match_id
HAVING COUNT(booking_id) > 2;  -- Works correctly
```

In summary: `WHERE` filters **rows**, `HAVING` filters **groups**.

---

## Question 4

**Imagine a newly registered fan who hasn't bought any match tickets yet. If you run a `LEFT JOIN` linking the Users table (left) to the Bookings table (right), what will the resulting rows look like for that specific fan?**

### Answer

A **`LEFT JOIN`** returns **all rows from the left table** (Users), and matching rows from the right table (Bookings). If there is **no matching row** in the right table, the result still includes the left-table row, but all columns from the right table are filled with **`NULL`**.

For a newly registered fan — like **Jannat Ara** (`user_id = 4`) who has no bookings — the result looks like this:

```sql
SELECT u.user_id, u.full_name, b.booking_id
FROM Users u
LEFT JOIN Bookings b ON u.user_id = b.user_id;
```

| user_id | full_name     | booking_id |
|---------|---------------|------------|
| 1       | Tanvir Rahman | 501        |
| 1       | Tanvir Rahman | 502        |
| 2       | Asif Haque    | 503        |
| 2       | Asif Haque    | 504        |
| 3       | Sajjad Rahman | 505        |
| **4**   | **Jannat Ara**| **NULL**   |

Jannat Ara appears in the result with `booking_id = NULL` — she is **not excluded** from the output. This is the key difference from an `INNER JOIN`, which would have omitted her row entirely because there is no match in the Bookings table.

`LEFT JOIN` is ideal for reports like "show all registered users, even those who haven't made a purchase yet."
