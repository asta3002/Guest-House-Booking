/*--------------------------------------------USER TABLES--------------------------------------------*/
create table USER (
  user_id varchar(10) primary key, 
  email varchar(15) not null unique, 
  password varchar(10) not null, 
  first_name varchar(10) not null, 
  last_name varchar(10) not null, 
  phone_no bigint not null check(length(phone_no) = 10)
);


load data local infile "./Users.csv"
into table USER
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by '\n'
ignore 1 lines;

-- Adding indices to speed the searching (testing)
create table INDEXED_USER like USER;
insert INDEXED_USER select * from USER;
alter table INDEXED_USER add index(user_id);
alter table INDEXED_USER add index(first_name);

-- Adding to actual USER table
alter table USER add index(user_id);
alter table USER add index(first_name);

/*
mysql> show profiles;
+----------+------------+--------------------------------------------------------------+
| Query_ID | Duration   | Query                                                        |
+----------+------------+--------------------------------------------------------------+
|        1 | 0.00533500 | select * from USER where first_name LIKE 'B_a%'              |
|        2 | 0.00145300 | select * from INDEXED_USER where first_name LIKE 'B_a%'      |
+----------+------------+--------------------------------------------------------------+
*/

/*--------------------------------------------ROOM TABLE--------------------------------------------*/
create table ROOM (
  room_id varchar(5) primary key, 
  ac_exists bit(1), 
  bed_size varchar(50) check(bed_size in ('Twin', 'Queen', 'King', 'Double')), 
  occupancy int not null,
  price bigint,
  rating float check(rating <= 5.0)
);

insert into ROOM values
('r101', 0, 'Twin', 2, 300, 3.5),
('r102', 1, 'King', 4, 500, 4.0),
('r103', 0, 'King', 4, 300, 3.5),
('r104', 1, 'Queen', 4, 500, 3.2),
('r105', 1, 'Double', 2, 200, 4.3),
('r106', 0, 'Double', 2, 100, 3.1),
('r107', 0, 'Queen', 4, 500, 5.0),
('r108', 0, 'Twin', 2, 300, 4.5);

load data local infile "./Room.csv"
into table ROOM
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by '\n'
ignore 1 lines;

/*--------------------------------------------EXPENSES TABLE--------------------------------------------*/
create table EXPENSES (
  exp_id varchar(10) primary key,
  room_id varchar(5),  
  amount bigint not null,
  category varchar(50) check(category in ('Electricity', 'Water', 'Cleaning')), 
  foreign key(room_id) references ROOM(room_id)
);

insert into EXPENSES values
('exp101', 'r101', 120, 'Electricity'),
('exp102', 'r101', 100, 'Water'),
('exp103', 'r102', 150, 'Water'),
('exp104', 'r102', 130, 'Cleaning'),
('exp105', 'r103', 130, 'Cleaning'),
('exp106', 'r104', 190, 'Electricity'),
('exp107', 'r105', 130, 'Cleaning'),
('exp108', 'r105', 150, 'Electricity'),
('exp109', 'r105', 130, 'Cleaning'),
('exp110', 'r106', 120, 'Water'),
('exp111', 'r107', 150, 'Electricity'),
('exp112', 'r107', 130, 'Cleaning'),
('exp113', 'r108', 100, 'Water');


load data local infile "./Expenses.csv"
into table EXPENSES
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by '\r\n'
ignore 1 lines;



/*--------------------------------------------BOOKING TABLE--------------------------------------------*/
create table BOOKING (
  booking_id varchar(10) primary key,
  room_id varchar(5),
  user_id varchar(5), 
  check_in date,
  check_out date,
  constraint check(check_in < check_out),
  foreign key(room_id) references ROOM(room_id),
  foreign key(user_id) references USER(user_id)
);

insert into BOOKING (booking_id,room_id, user_id,check_in, check_out) values
('b101', 'r101', 'u101', '2022-11-14', '2022-11-15'),
('b102', 'r102', 'u102', '2022-11-15', '2022-11-16'),
('b103', 'r102', 'u103', '2022-11-17', '2022-11-18');

/*
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                                                |
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+                                                                                                                                                       |
|       23 | 0.00861175 | select * from expenses where amount < 150 and amount > 110                                                                                                                                                 |
|       26 | 0.00512400 | select * from expenses where amount < 150 and amount > 110                                                                                                                                                      |
+----------+------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
*/

/*--------------------------------------------FOOD ORDERING TABLES--------------------------------------------*/
create table FOOD (
  food_id varchar(5) primary key, 
  food_name varchar(20),
  food_price int
);

insert into FOOD values 
('f101', 'Creamy Pasta', 100),
('f102', 'Veg Momo', 120),
('f103', 'White Pasta', 120),
('f104', 'Schezwan Noodles', 80),
('f105', 'Veg Sandwich', 70);

load data local infile "./Food.csv"
into table FOOD
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by '\n'
ignore 1 lines;

create table BILL (
  bill_id varchar(10) primary key,
  user_id varchar(5), -- user who ordered the item
  tax int,
  total_cost float, -- cost of the items in the order
  foreign key(user_id) references USER(user_id)
);

create table ORDERS (
  bill_id varchar(10),
  food_id varchar(10),
  quantity int,
  primary key(bill_id, food_id, quantity),
  foreign key(food_id) references FOOD(food_id),
  foreign key(bill_id) references BILL(bill_id)
);

delimiter |

create trigger insert_bill before insert on ORDERS
for each row 
begin
    if (not (exists(select * from BILL where BILL.bill_id = NEW.bill_id))) then 
        insert into BILL (bill_id) values (NEW.bill_id);
    end if;
end;|

delimiter ;

insert into ORDERS values
('b101', 'f102', 1),
('b101', 'f103', 2),
('b102', 'f101', 3),
('b102', 'f104', 2),
('b103', 'f105', 1),
('b104', 'f102', 1),
('b104', 'f101', 1);


/*--------------------------------------------STAFF & SCHEDULING TABLES--------------------------------------------*/
create table STAFF (
  staff_id varchar(10) primary key,
  staff_name varchar(50),
  staff_role varchar(50),
  shift_start time,
  shift_end time,
  monthly_req bigint,
  hourly_wage bigint,
  late_entry_count int default 0,
  early_exit_count int default 0
);

insert into STAFF values 
('s101', 'Marcel Matthews', 'Cook', '08:30:00', '16:00:00', 150, 100, 0, 0),
('s102', 'Rajan Gupta', 'Cleaner', '09:30:00', '15:00:00', 100, 60, 0, 0),
('s103', 'Prajwal Kumar', 'Cleaner', '15:30:00', '20:00:00', 150, 60, 0, 0),
('s104', 'Mohit Kumar', 'Helper', '08:30:00', '16:00:00', 150, 50, 0, 0),
('s105', 'Pam Beasely', 'Receptionist', '08:30:00', '16:00:00', 200, 80, 0, 0),
('s106', 'Oscar Martinez', 'Accountant', '10:00:00', '15:00:00', 150, 120, 0, 0);


create table STAFF_LOG (
  log_id varchar(10) primary key,
  staff_id varchar(10),
  entry_time time,
  exit_time time,
  date_stamp date,
  foreign key(staff_id) references STAFF(staff_id)
);

create trigger check_log after insert on STAFF_LOG
for each row
begin
  if (select shift_start from STAFF where STAFF.staff_id = NEW.staff_id) < NEW.entry_time then
    update STAFF set STAFF.late_entry_count = STAFF.late_entry_count + 1 where STAFF.staff_id = NEW.staff_id;
  end if;
  if (select shift_end from STAFF where STAFF.staff_id = NEW.staff_id) > NEW.exit_time then
    update STAFF set STAFF.early_exit_count = STAFF.early_exit_count + 1 where STAFF.staff_id = NEW.staff_id;
  end if;
end;|

delimiter ;
insert into STAFF_LOG values 
('l101', 's101', '08:00:00', '15:00:00', '2022-11-15'),
('l102', 's102', '10:00:00', '15:00:00', '2022-11-15'),
('l103', 's102', '09:00:00', '16:00:00', '2022-11-16'),
('l104', 's103', '15:00:00', '17:00:00', '2022-11-17'),
('l105', 's103', '15:30:00', '21:00:00', '2022-11-18'),
('l106', 's104', '06:00:00', '20:00:00', '2022-11-19'),
('l107', 's105', '10:00:00', '18:00:00', '2022-11-20'),
('l108', 's106', '10:00:00', '15:00:00', '2022-11-21');

delimiter |

create function calc_working_hours(staff_id varchar(5)) returns time deterministic
begin
  declare total_worked time;
  set total_worked = (select time(sum(TIMEDIFF(STAFF_LOG.exit_time, STAFF_LOG.entry_time))) 
  from STAFF_LOG
  where STAFF_LOG.staff_id = staff_id);
  return total_worked;
end;|

create function calc_salary(staff_id varchar(5)) returns bigint deterministic
begin
  declare worked_hours bigint;
  declare wage int;
  declare salary bigint;
  set worked_hours = HOUR(calc_working_hours(staff_id));
  set wage = (select STAFF.hourly_wage from STAFF where STAFF.staff_id = staff_id);
  set salary = worked_hours*wage;
  return salary;
end;|

/*--------------------------------------------EXPENDITURE CALCULATION--------------------------------------------*/

create function calc_expenditure(room_id varchar(5)) returns bigint deterministic
begin
  declare expd bigint;
  set expd = (select sum(EXPENSES.amount) from EXPENSES where EXPENSES.room_id = room_id);
  return expd;
end;|

/*--------------------------------------------AVAILABILITY CALCULATION--------------------------------------------*/

create procedure get_available_rooms(
  IN ac_exists bit(1), 
  IN bed_size varchar(50),
  IN occupancy int,
  IN check_in date,
  IN check_out date
)
begin 
  select distinct(ROOM.room_id) 
  from ROOM LEFT JOIN BOOKING on ROOM.room_id = BOOKING.room_id
  where ((ROOM.ac_exists = ac_exists and ROOM.bed_size = bed_size and ROOM.occupancy = occupancy)
  and ((BOOKING.booking_id IS NULL) 
  or (ROOM.room_id not in 
  (select ROOM.room_id from ROOM LEFT JOIN BOOKING on ROOM.room_id = BOOKING.room_id
  where (BOOKING.check_in <= check_in and BOOKING.check_out >= check_out)))));
end |

/*--------------------------------------------BILL CALCULATION AND GENERATION - ROOM AND FOOD--------------------------------------------*/

create function calc_room_bill(b_id varchar(10), tax int) returns bigint deterministic
begin
  declare sum_total bigint;
  declare rprice bigint;
  declare num_days bigint; 
  set num_days = (select datediff(BOOKING.check_out, BOOKING.check_in) from BOOKING where BOOKING.booking_id = b_id);
  set rprice = (select ROOM.price from BOOKING natural join ROOM where BOOKING.booking_id = b_id);
  set sum_total = rprice*num_days;
  set sum_total = sum_total + sum_total*(tax/100);
  return sum_total;
end |

create procedure show_room_bill(
  IN b_id varchar(10), 
  IN tax int)
begin
  declare u_id varchar(50);
  set u_id = (select user_id from BOOKING where BOOKING.booking_id = b_id);
  select user_id, first_name, last_name, phone_no from USER where USER.user_id = u_id; 
  select * from BOOKING where BOOKING.booking_id = b_id;
  select tax as "Tax Percent";
  select calc_room_bill(b_id, tax) as "Grand Total" from BILL where BILL.bill_id = b_id;
end |

create function calc_food_bill(b_id varchar(10), tax int) returns float deterministic
begin
  declare cnt int default 0;
  declare sum_total float default 0;
  declare total int default (select count(*) from ORDERS where ORDERS.bill_id = b_id);
  declare price float;
  declare quant int;
  declare cur cursor for select FOOD.food_price, ORDERS.quantity from ORDERS natural join FOOD where ORDERS.bill_id = b_id;
  
  open cur;
  while cnt < total do
    fetch cur into price, quant;
    set sum_total = sum_total + price*quant;
    set cnt = cnt + 1;
  end while;
  close cur;

  set sum_total = sum_total + sum_total*(tax/100);

  return sum_total;
end |

create procedure show_food_bill(
  IN b_id varchar(10), 
  IN u_id varchar(5),
  IN tax int)
begin
  declare cnt int default 0;
  declare total int default (select count(*) from ORDERS where ORDERS.bill_id = b_id);
  declare fname varchar(100);
  declare price float;
  declare quant int;
  declare cur cursor for select FOOD.food_name, FOOD.food_price, ORDERS.quantity from ORDERS natural join FOOD where ORDERS.bill_id = b_id;
  open cur;

  create table if not exists FOOD_BILL (
    item varchar(20),
    price int,
    quantity int,
    total bigint
  );

  -- clear the entry of the bill
  delete from FOOD_BILL;

  while cnt < total do
    fetch cur into fname, price, quant;
    insert into FOOD_BILL values (fname, price, quant, price*quant);
    set cnt = cnt + 1;
  end while;
  close cur;

  update BILL 
  set BILL.total_cost = calc_food_bill(b_id, tax),
  BILL.user_id = u_id,
  BILL.tax = tax 
  where BILL.bill_id = b_id;

  select user_id, first_name, last_name, phone_no from USER where USER.user_id = u_id; 
  select * from FOOD_BILL;
  select total_cost as "Grand Total" from BILL where BILL.bill_id = b_id;
end |

-- sums all the food and room bills of an user 
create function calc_total_bill(u_id varchar(10)) returns float deterministic
begin
  declare cnt int default 0;
  declare sum_total float default 0;
  declare total int default (select count(*) from BILL where BILL.user_id = u_id);
  declare b_id varchar(5);
  declare cur cursor for select BILL.bill_id from BILL where BILL.user_id = u_id;
  declare cur2 cursor for select BOOKING.booking_id from BOOKING where BOOKING.user_id = u_id;
  
  
  open cur;
  while cnt < total do
    fetch cur into b_id;
    set sum_total = sum_total + calc_food_bill(b_id, 10);
    set cnt = cnt + 1;
  end while;
  close cur;

  set total = (select count(*) from BOOKING where BOOKING.user_id = u_id);
  set cnt = 0;

  open cur2;
  while cnt < total do
    fetch cur2 into b_id;
    set sum_total = sum_total + calc_room_bill(b_id, 10);
    set cnt = cnt + 1;
  end while;
  close cur2;

  return sum_total;
end|