SQL update master using a transaction table mysql database

This might help to get you started.

github
https://tinyurl.com/yc8e5s79
https://github.com/rogerjdeangelis/utl_sql_update_master_using_a_transaction_table_mysql_database

Assuming name is a primary unique index on the master and transaction tables.
The number of matches is small(less than a million).
In this case I want to update age.
Should be fast.


Expect Oracle has similar sytax.

INPUT  (tables in mysql database)
==================================

 MYSQLLIB.MASTER total obs=5

    NAME      SEX    AGE    HEIGHT    WEIGHT

   Alfred      M      14     69.0      112.5
   Alice       F      13     56.5       84.0
   Barbara     F      13     65.3       98.0
   Carol       F      14     62.8      102.5
   Henry       M      14     63.5      102.5


MYSQLLIB.TRANSACTION total obs=2

    Obs     NAME      AGE

      1    Alfred     999
      2    Barbara    888

EXAMPLE OUTPUT
--------------

UPDATED MYSQLLIB.MASTER total obs=5

    NAME      SEX   HEIGHT    WEIGHT     AGE

   Alfred      M     69.0      112.5     999  ** changed
   Alice       F     56.5       84.0      13
   Barbara     F     65.3       98.0     888  ** changed
   Carol       F     62.8      102.5      14
   Henry       M     63.5      102.5      14


PROCESS
=======

proc sql;
   connect to mysql ( user=root password="xxxxxxxx" database=sakila);
   execute (
      update master join transaction
      on master.name = transaction.name
      set master.age = transaction.age
   ) by mysql
;quit;


OUTPUT
======

UPDATED MYSQLLIB.MASTER total obs=5

    NAME      SEX   HEIGHT    WEIGHT     AGE

   Alfred      M     69.0      112.5     999  ** changed
   Alice       F     56.5       84.0      13
   Barbara     F     65.3       98.0     888  ** changed
   Carol       F     62.8      102.5      14
   Henry       M     63.5      102.5      14


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;


libname mysqllib mysql user=root password=xxxxxxx database=sakila;

* just in case you rerun;
proc sql;
   connect to mysql ( user=root password="xxxxxxx" database=sakila);
   execute (drop table master)  by mysql;
   execute (drop table transaction)  by mysql;
quit;

* create master and transaction;
data  mysqllib.master;
  set sashelp.class(obs=5);
run;quit;

data mysqllib.transaction;
  set sashelp.class(obs=5);
  select (name);
  when  ('Alfred') do;  age=999 ; output; end;
  when  ('Barbara' ) do;  age=888 ; output; end;
  otherwise;
  end;
  keep name age;
run;quit;

* build primary keys;
proc sql;
   connect to mysql ( user=root password="xxxxxxx" database=sakila);
   execute (create unique index name on master(name))  by mysql;
   execute (create unique index name on transaction(name))  by mysql;
;quit;


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

proc sql;
   connect to mysql ( user=root password="xxxxxxx" database=sakila);
   execute (
      update master join transaction
      on master.name = transaction.name
      set master.age = transaction.age
   ) by mysql
;quit;

proc print data=mysqllib.master;
run;quit;


