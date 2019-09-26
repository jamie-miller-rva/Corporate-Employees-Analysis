# Corporate-Employees-Analysis
Corporate Employee Database 1980s-1990s
The following database Modeling, Engineering, and Analysis demonstrates the creation of a database using SQL in pgAdmin 4, visualizing the design of that database using an Entity Relationship Diagram (ERD), and connecting that database to Pandas by establishing a SQLAlchemy connection to the Corporate-Employee-Analysis-db.

Data Modeling
The databased was modeled from the six csv files provided (located in the DATA folder). The database uses primary keys for emp_no in the employees table and dept_no in the departments table. Those primary keys are linked to all other tables using emp_no and dept_no as foreign keys.

The Entity Relationship Diagram (ERD) below was created using the dbdiagram tool at https://dbdiagram.io/d/5d0fb76237c1673299dafea1

