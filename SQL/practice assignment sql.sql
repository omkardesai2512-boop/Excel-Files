-- A. Character Functions (10 Questions)

-- 1. Display all customer first names in UPPER case.
use bankingdb;
select upper(firstname) "UPPER" from customers;

-- 2. Showall account types in lower case.
select lower(accounttype) "LOWER" from accounts;

-- 3. Display branch names with leading and trailing spaces removed using TRIM.
select trim(branchname) "TRIM" from branches;

-- 4. Concatenate FirstName and LastName in format → LastName, FirstName.
select concat(firstname," ",lastname) "concat" from customers;

-- 5. Replace spaces in BranchName with underscores (_).
select replace(branchname," ","_") "REPLACE" from branches;

-- 6. Display the length of each customer's Email.
select length(email) "LENGTH" from customers;

-- 7. Extract the first 5 characters from BranchName using LEFT.
select left(branchname, 5)"LEFT" FROM branches;

-- 8. Extract the last 4 digits from Phone using RIGHT.
select right(phone, 4)"RIGHT" FROM customers;

-- 9. Extract a substring from the 3rd position for 6 characters from Email.
select substring(email,3,6)"SUBSTRING" FROM customers;

-- 10. Display AccountType after trimming and converting it to UPPER case.
select trim(upper(AccountType))"UPPER" FROM accounts;
 