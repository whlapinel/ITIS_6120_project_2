# Requirements

- [] Create an application programming interface (API) using stored procedures that allows an EMR system developer to work with the database without having to write SQL statements.

- - One simple way to use MySQL stored procedures in an API is to create a text-based interface with multiple options for the user to access your database functionalities without being able to access/modify the data or using MySQL workbench.

- - You can use any programming language to create the text-based interface. It is important to note that you will need to allow these functions according to the user authorization. For example, you may want to allow doctors to update prescriptions, but not patients.

- [] Add user authentication so that only authorized users can access the database

- [] Add some form of role-based access control to limit the functions that a user can perform. You should implement at least one use case to demonstrate this capability. For example, you may allow a physician to delete a prescription order, but not a receptionist. In this case, you have two roles, physician and receptionist.

- [] Add tables and other features to enable audit trail so that every query or change of every record in the database is monitored and the entire history of the data in the database is captured. Basically, every time a record is accessed (queried, inserted, or changed), the user and time of access is recorded. Every time any field of a record is updated or deleted, the previous value of the record is saved.

- [] Add indexes and views so that frequently used queries and changes to the database
are most efficient.