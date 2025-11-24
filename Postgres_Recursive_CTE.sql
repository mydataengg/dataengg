/* ============================================================
   recursive_hierarchy_demo.sql
   Demonstration of employee hierarchy using a recursive CTE
   Works on: PostgreSQL, MySQL 8+, Oracle, SQL Server
   ============================================================ */

/* -------------------------
   1. DROP TABLE (SAFE)
   ------------------------- */
DROP TABLE IF EXISTS employees;

/* -------------------------
   2. DDL - Create Table
   ------------------------- */

 CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id    INT NULL
 );

/* -------------------------
   3. DML - Insert Sample Data
   ------------------------- */
INSERT INTO employees (employee_id, employee_name, manager_id) VALUES
    (1, 'CEO',        NULL),
    (2, 'VP1',        1),
    (3, 'VP2',        1),
    (4, 'Manager1',   2),
    (5, 'Manager2',   2),
    (6, 'Lead1',      4);
   

   
   
/* ============================================================
   4. Look at the table data
   ============================================================ */
   
select * from employees ;

/* ============================================================
   4. FULL HIERARCHY QUERY (Recursive CTE)
   ============================================================ */

 WITH RECURSIVE emp_tree AS (
    -- Anchor: starting point of recursion
 
    SELECT 
        employee_id, employee_name, manager_id,1 AS level
    FROM employees
    WHERE employee_id = 1     -- Start from CEO (root)
    
    UNION ALL

    -- Recursive member: find subordinates
    SELECT 
        e.employee_id, e.employee_name,e.manager_id,t.level + 1
    FROM employees e
    JOIN emp_tree t ON e.manager_id = t.employee_id
 )
 SELECT 
 (select employee_id FROM emp_tree
 where employee_id = 1
 ORDER BY level, employee_id) as af,
(SELECT employee_id FROM emp_tree
where employee_id = 1
 ORDER BY level, employee_id ) as dd;

/* ============================================================
   5. 3-LEVEL HIERARCHY (Employee ? Manager ? Senior Manager)
   ============================================================ */

SELECT 
    e.employee_id AS employee_id,
    e.employee_name AS employee,
    m.employee_name AS manager,
    sm.employee_name AS senior_manager
FROM employees e
LEFT JOIN employees m 
    ON e.manager_id = m.employee_id
LEFT JOIN employees sm 
    ON m.manager_id = sm.employee_id
ORDER BY e.employee_id;

/* ============================================================
   6. SAMPLE OUTPUT (for reference)
   ------------------------------------------------------------
   employee_id | employee_name | manager_id | level
   ------------------------------------------------------------
   1 | CEO       | NULL | 1
   2 | VP1       | 1    | 2
   3 | VP2       | 1    | 2
   4 | Manager1  | 2    | 3
   5 | Manager2  | 2    | 3
   6 | Lead1     | 4    | 4
   ------------------------------------------------------------

   Hierarchy (visual):
   CEO (1)
     ??? VP1 (2)
     ?     ??? Manager1 (4)
     ?     ?         ??? Lead1 (6)
     ?     ??? Manager2 (5)
     ??? VP2 (3)
   ============================================================ */




  
   
/* ============================================================
   -- CTE Query
 ============================================================ */
   
   WITH ManagerReportCounts AS (
    -- Define the reusable logic ONCE:
    SELECT
        manager_id,COUNT(employee_id) AS SubordinateCount
    from  employees GROUP BY manager_id )
    
   SELECT
    -- 1. Use 1: Count managers have more than 1 subordinate
    ( SELECT  COUNT(manager_id) FROM  ManagerReportCounts
        WHERE SubordinateCount > 1
    ) AS Managers_with_Multiple_Reports,  
    
    -- 2. Use 2: Calculate the average number of subordinates
    ( SELECT AVG(SubordinateCount) FROM ManagerReportCounts
    ) AS Average_Subordinates_per_Manager;


/* ============================================================
   -- CTE Query
 ============================================================ */
 -- Subquery
   
   SELECT
    -- 1. Total Managers with Multiple Reports
    ( SELECT COUNT(T1.manager_id)
    
        FROM (
        -- Subquery 1 (T1): Calculates the report count per manager
            SELECT
        manager_id,COUNT(employee_id) AS SubordinateCount
    from  employees GROUP BY manager_id
        ) AS T1
        
        WHERE T1.SubordinateCount > 1 
        -- Filters the result of Subquery 1
    ) AS Managers_with_Multiple_Reports,
    
    -- 2. Average Subordinates per Manager
    ( SELECT AVG(T2.SubordinateCount)
    
        FROM (-- Subquery 2 (T2):Repeats the same logic as Subquery 1
            SELECT
        manager_id,COUNT(employee_id) AS SubordinateCount
    from  employees GROUP BY manager_id
        ) AS T2
        
    ) AS Average_Subordinates_per_Manager;


 