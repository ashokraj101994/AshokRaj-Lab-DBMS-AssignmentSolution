Create Database if not exists `order-directory` ;
use `order-directory`;



create table if not exists `supplier`(
`SUPP_ID` int primary key,
`SUPP_NAME` varchar(50) ,
`SUPP_CITY` varchar(50),
`SUPP_PHONE` varchar(10)
);




CREATE TABLE IF NOT EXISTS `customer` (
  `CUS_ID` INT NOT NULL,
  `CUS_NAME` VARCHAR(20) NULL DEFAULT NULL,
  `CUS_PHONE` VARCHAR(10),
  `CUS_CITY` varchar(30) ,
  `CUS_GENDER` CHAR,
  PRIMARY KEY (`CUS_ID`));

 

CREATE TABLE IF NOT EXISTS `category` (
  `CAT_ID` INT NOT NULL,
  `CAT_NAME` VARCHAR(20) NULL DEFAULT NULL,
 
  PRIMARY KEY (`CAT_ID`)
  );



  CREATE TABLE IF NOT EXISTS `product` (
  `PRO_ID` INT NOT NULL,
  `PRO_NAME` VARCHAR(20) NULL DEFAULT NULL,
  `PRO_DESC` VARCHAR(60) NULL DEFAULT NULL,
  `CAT_ID` INT NOT NULL,
  PRIMARY KEY (`PRO_ID`),
  FOREIGN KEY (`CAT_ID`) REFERENCES category (`CAT_ID`)
  
  );


 CREATE TABLE IF NOT EXISTS `product_details` (
  `PROD_ID` INT NOT NULL,
  `PRO_ID` INT NOT NULL,
  `SUPP_ID` INT NOT NULL,
  `PROD_PRICE` INT NOT NULL,
  PRIMARY KEY (`PROD_ID`),
  FOREIGN KEY (`PRO_ID`) REFERENCES product (`PRO_ID`),
  FOREIGN KEY (`SUPP_ID`) REFERENCES supplier (`SUPP_ID`)
  
  );


 
CREATE TABLE IF NOT EXISTS `order` (
  `ORD_ID` INT NOT NULL,
  `ORD_AMOUNT` INT NOT NULL,
  `ORD_DATE` DATE,
  `CUS_ID` INT NOT NULL,
  `PROD_ID` INT NOT NULL,
  PRIMARY KEY (`ORD_ID`),
  FOREIGN KEY (`CUS_ID`) REFERENCES customer (`CUS_ID`),
  FOREIGN KEY (`PROD_ID`) REFERENCES product_details (`PROD_ID`)
  );






CREATE TABLE IF NOT EXISTS `rating` (
  `RAT_ID` INT NOT NULL,
  `CUS_ID` INT NOT NULL,
  `SUPP_ID` INT NOT NULL,
  `RAT_RATSTARS` INT NOT NULL,
  PRIMARY KEY (`RAT_ID`),
  FOREIGN KEY (`SUPP_ID`) REFERENCES supplier (`SUPP_ID`),
  FOREIGN KEY (`CUS_ID`) REFERENCES customer (`CUS_ID`)
  );
select customer.cus_gender,count(customer.cus_gender) as count 
from customer 
inner join `order` 
on customer.cus_id=`order`.cus_id 
where `order`.ord_amount>=3000
group by customer.cus_gender;


-- 4. Display all the order along with product name ordered by a customer having Customer_Id=2;
select `order`.*, product.pro_name
from `order`, product_details, product
where `order`.cus_id=2 
and `order`.prod_id = product_details.prod_id
and product_details.pro_id = product.pro_id;

-- 5. Display the Supplier details who can supply more than one product.
SELECT * FROM supplier
 JOIN product_details on supplier.SUPP_ID = product_details.SUPP_ID
 GROUP BY product_details.SUPP_ID
 HAVING COUNT(product_details.SUPP_ID) >=2;

SELECT distinct `SUPPLIER`.SUPP_ID,`SUPPLIER`.SUPP_NAME,`SUPPLIER`.SUPP_CITY,`SUPPLIER`.SUPP_PHONE from `SUPPLIER`,`PRODUCT_DETAILS`
WHERE `SUPPLIER`.SUPP_ID = `PRODUCT_DETAILS`.SUPP_ID
GROUP BY `PRODUCT_DETAILS`.SUPP_ID
having count(`PRODUCT_DETAILS`.SUPP_ID)>1;

select supplier.*
from supplier, product_details
where supplier.supp_id in 
(
select product_details.supp_id
from product_details
group by product_details.supp_id
having count(product_details.supp_id) > 1
)
group by supplier.supp_id;

-- 6. Find the category of the product whose order amount is minimum.
-- https://stackoverflow.com/questions/6924896/having-without-group-by
select category.*, `order`.ord_id
from `order`
inner join product_details
on `order`.prod_id = product_details.prod_id
inner join product on product.pro_id = product_details.pro_id
inner join category on category.cat_id = product.cat_id
having min(`order`.ord_amount);


-- 7. Display the Id and Name of the Product ordered after “2021-10-05”.
SELECT PRODUCT.pro_id, PRODUCT.pro_name FROM PRODUCT 
 JOIN product_details ON PRODUCT.PRO_ID =product_details.PRO_ID
 JOIN `ORDER` ON product_details.PROD_ID = `ORDER`.PROD_ID
WHERE `ORDER`.ORD_DATE > '2021-10-05';

-- 8. Display customer name and gender whose names start or end with character 'A'.
-- like
SELECT CUS_NAME,CUS_ID FROM CUSTOMER WHERE CUS_NAME like 'A%' or cus_name like '%A';


-- 9 Create a stored procedure to display the Rating for a Supplier if any 
-- along with the Verdict on that rating if any like if rating >4 then “Genuine Supplier” if rating >2 “Average Supplier” else “Supplier should not be considered”.
-- You define a DELIMITER to tell the mysql client to treat the statements, 
-- functions, stored procedures or triggers as an entire statement. Normally in a .
--  sql file you set a different DELIMITER like $$. The DELIMITER command is used to change the standard delimiter of MySQL commands

DELIMITER &&
create procedure prc()
BEGIN
select supplier.supp_id, supplier.supp_name, rating.rat_ratstars,
case
	when rating.rat_ratstars >4 then 'GENUINE Supplier'
    when rating.rat_ratstars >2 then 'Average  Supplier'
    Else 'Supplier should not be considered'
END as verdict from rating inner join supplier on supplier.supp_id = rating.supp_id;
END 
&& DELIMITER ;

call prc();

