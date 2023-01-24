-- 1). 
create type type_ingr as enum('Appetiser', 'Coloriser');

-- If you don't want to drop the table, you can use this instead of the typ in the relation
ALTER TABLE ingredient
ALTER COLUMN typ TYPE type_ingr USING typ::type_ingr;

CREATE TABLE ingredient(name varchar(20) UNIQUE,
					    typ varchar(20) NOT NULL check(typ in ('Appetiser', 'Coloriser') ),
						id SERIAL CHECK (id >= 0) PRIMARY KEY) ;
						
INSERT INTO ingredient
VALUES ('Jumbo', 'Appetiser'),
	   ('Drinks Color', 'Coloriser'),
	   ('Rice Color', 'Coloriser'),
	   ('Pepper', 'Appetiser'),
	   ('Salt', 'Appetiser');
	   
update ingredient
set id = 20
where id = 2

DELETE FROM ingredient
where id = 2

drop table ingredient
SELECT * FROM ingredient

-------------------------------------------------
--2).
CREATE TABLE ingfood(ingr_id int REFERENCES ingredient on delete cascade on update cascade,
					 food_id int REFERENCES fooddrinks on delete cascade on update cascade,
					 PRIMARY KEY (ingr_id, food_id) );
					 
INSERT INTO ingfood 
VALUES  (1, 2),
		(2, 4),
		(1, 1),
		(4, 2),
		(2, 5),
		(5, 1),
		(5, 2),
		(2, 6);

drop table ingfood
SELECT * FROM ingfood
--------------------------------------------------
--3).  not total
CREATE TABLE fooddrinks(etype varchar(20) NOT NULL,
						type varchar(20) NOT NULL,
						name varchar(20) not null, 
						cost int NOT NULL,
						qnt int NOT NULL, 
					    id SERIAL CHECK (id >= 0) PRIMARY KEY);
						
INSERT INTO fooddrinks
VALUES ('Rice', 'Biryani', 'Pakistani Biryani', 10, 1),
	   ('Rice', 'Biryani', 'Indian Biryani',    20, 2),
	   ('Rice', 'Jolof',   'African Rice',      20, 2),
	   ('Drinks', 'Soft Drink',   'Fanta',      2,  1),
	   ('Drinks', 'Fruit Juice',   'Mango',      2,  1),
	   ('Drinks', 'Milk',   'Cowow',      4,  4),
	   ('Fish', 'Fish Burger',   'Fried Burger',   20,  1);
	   
drop table fooddrinks
SELECT * FROM fooddrinks
------------------------------------------------------

-- 4).
CREATE TABLE supply(food_id int unique references fooddrinks on delete set null on update cascade,
				   bus_id int references business on delete set null on update cascade,
				   date timestamptz,
				   id SERIAL CHECK (id >= 0) PRIMARY KEY)

drop table supply

INSERT INTO supply
VALUES  (1, 3, now()),
		(2, 6, now()),
		(3, 8, now()),
		(4, 4, now()),
		(5, 1, now()),
		(7, 10, now()),
		(6, 1, now());

SELECT * FROM supply where date::date = '2022-06-21' 
-- supdate::date returns only the date part
---------------------------------------------------------------------------
create type Addr as (street varchar (100), num int, zip int )

-- 5). not total
CREATE TABLE business(city int references city on delete set null on update cascade, 
					  name varchar(20) not null,
					  business_type varchar(20),
					  addr Addr not null,
					  etype varchar(20) not null,
					  id SERIAL CHECK (id >= 0) PRIMARY KEY
					  UNIQUE(city, name, addr, etype));

drop table business

INSERT INTO business
VALUES  (1, 'PepsiCo', 		'Drinks Supplier', ('via Catania', 23, 00159), 'Business'),
		(1, 'Ferrero', 		'Drinks Supplier', ('via Padre Pio', 2, 00165), 'Business'),
		(1, 'Danone',  		'Food Supplier', ('viale Arezzo', 34, 00133), 'Business' ),
		(1, 'Red Bull', 	'Drinks Supplier', ('via San Paolo', 34, 00133), 'Business'),
		(7, 'Gruppo Bimbo', 'Food Supplier', ('via San Pietro in Laterano', 4, 00133), 'Business'),
		(7, 'Soxham', 		'Food Supplier', ('via Siria', 12, 00143), 'Business'),
		(7, 'Al Bacio', 	'Food Supplier', ('via Santo Domenico', 1, 00172), 'Business'),
		(7, 'Triens SRL', 	'Food Supplier', ('via degli aviatori', 29, 00154), 'Business'),
		(5, 'New Flavors', 	'Food Supplier', ('piazzale della gioventu', 60, 00190), 'Business'),
		(4, 'Skigel SRL', 	'Food Supplier', ('via Savorelli', 10, 00165), 'Business'),
		(4, 'Befood SRL', 	'Food Supplier', ('via ospedale San Marco', 44, 00163), 'Business'),
		(11, 'Sabatino Italia SRL', 'Food Supplier', ('viale Universita', 6, 00123), 'Business'),
		(2, 'Assicurazione Brumotti', null, ('via Cicerone', 20, 00139), 'Insurance'),
		(10, 'Allianz Insurance', null, ('viale Universita', 19, 00143), 'Insurance'),
		(11, 'Insure All', null, ('via Piemonte', 59, 00196), 'Insurance');
		
		
SELECT * FROM business
		
----------------------------------------------------------------------------------
-- 6). 
CREATE TABLE buyfood(client varchar(20) references client on delete set null on update cascade,
					food_id int unique references fooddrinks on delete set null on update cascade,
					date Timestamptz,
					id SERIAL check(id>=0) PRIMARY KEY);

INSERT INTO buyfood
VALUES  ('NITOW89HSI3JL', 1, now()),
		('NITOW89HSI3JL', 2, now()),
		('FATJWR05NICEB', 3, now()),
		('ASRBSJS788BWE', 7, now()),
		('MUAYA67HAJ8BA', 6, now()),
		('CHIUHBS67HSJJ', 4, now()),
		('DABJNSJ89NNSN', 5, now());

SELECT * FROM buyfood
----------------------------------------------------------------------------------
-- 7). SSN is alphanumeric
--Note that the constraint regular expression is case sensitive if one uses the '~' operator 
--and insensitive if uses '~*', so one needs to decide whether the DB should accept lower 
--case characters in that column.
CREATE TABLE client(ssn varchar(20) check (ssn ~ '^[A-Z0-9]+$')PRIMARY KEY,
				   firstname varchar(20) not null,
				   surname varchar(20) not null,
				   city int references city on delete set null on update cascade,
				   age int not null check(age > 0),
				   email varchar(20),
				   sex varchar(6));
DROP TABLE client

INSERT INTO client
VALUES  ('NITOW89HSI3JL', 'Nick', 'Tows', 1, 22, 'nick@yahoo.com', 'MALE'),
		('FATJWR05NICEB', 'Fatima', 'Juwara', 1, 16, 'fatima@yahoo.com', 'FEMALE'),
		('DABJNSJ89NNSN', 'David', 'Biden', 2, 39, 'david@gmail.com', 'MALE'),
		('ASRBSJS788BWE', 'Andrea', 'Scaloni', 5, 12, 'andrea@yahoo.com', 'MALE'),
		('KIENZK393832Q', 'Kleija', 'Ianna', 3, 50, 'kleija@yahoo.com', 'FEMALE'),
		('ALHAJNJN89BSS', 'Ali', 'Hafaz', 1, 32, 'alis@yahoo.com', 'MALE'),
		('SEBAS888BSBSN', 'Sebastian', 'Hua', 1, 45, 'sebastian@gmail.com', 'MALE'),
		('CHIUHBS67HSJJ', 'Chua', 'Hua', 4, 22, 'chua@yahoo.com', 'FEMALE'),
		('MUAYA67HAJ8BA', 'Muhamad', 'Ayaz', 6, 28, 'muhamad@gmail.com', 'MALE')
		('YPHA10WQEWAAWAQ', 'Yuana', 'Diaz Brown', 1, 20, 'yuabrown@yahoo.com', 'FEMALE');

SELECT * FROM client
------------------------------------------------------------------------------------
-- 8).
CREATE TABLE promocode(client varchar(20) references client on delete set null on update cascade,
					  typ varchar(20) references event on delete set null on update cascade,
					  start_date date not null,
					  end_date date not null,
					  used_or_not varchar(3), 
					  etype varchar(20) check(etype in ('Expired Promo', 'Not Expired Promo') ), -- expired promo or not
					  id SERIAL check(id >= 0) PRIMARY KEY ,
					  CHECK(start_date < end_date),
					  UNIQUE(client, typ, start_date));
					  
drop table promocode

INSERT INTO promocode
VALUES  ('ALHAJNJN89BSS', 'Marriage Ceremony', date('2022-06-12'), date('2022-09-12'), null, 'Not Expired Promo'),
		('SEBAS888BSBSN', 'Birthday', date('2022-07-2'), date('2022-09-02'), null, 'Not Expired Promo'),
		('FATJWR05NICEB', 'Picnic', date('2022-04-29'), date('2022-06-04'), 'Yes', 'Expired Promo'),
		('SEBAS888BSBSN', 'Birthday', date('2022-02-13'), date('2022-05-16'), 'No', 'Expired Promo'),
		('MUAYA67HAJ8BA', 'Birthday', date('2022-06-29'), date('2022-08-22'), null, 'Not Expired Promo'),
		('ALHAJNJN89BSS', 'Picnic', date('2022-06-23'), date('2022-10-23'), null, 'Not Expired Promo');
		
SELECT * FROM promocode

-----------------------------------------------------------------------------------
-- 9). 
CREATE TABLE rating(client varchar(20) references client on delete set null on update cascade,
				   event_instance int references event_instance on delete set null on update cascade,
				   date date DEFAULT NOW(),
				   rate_value int check(rate_value >= 0),
				   PRIMARY KEY(client, event_instance) );
				   
DROP TABLE rating

INSERT INTO rating
VALUES  ('SEBAS888BSBSN', 1, now(), 98),
		('FATJWR05NICEB', 2, date('2022-08-12'), 80),
		('FATJWR05NICEB', 1, date('2022-07-28'), 77);
		
-- cannot insert these because they do not satisfy requirements (...trigger)
INSERT INTO rating
VALUES  ('MUAYA67HAJ8BA', 1, now(), 98),
		('ALHAJNJN89BSS', 2, date('2022-09-03'), 40);

select * from  rating

-----------------------------------------------------------------------------------
--10). 
CREATE TABLE book_accommodation(client varchar(20) references client on delete set null on update cascade,
							   accommodatio_id int references accommodation on delete set null on update cascade,
							   date date,
							   id SERIAL check(id >= 0) PRIMARY KEY );

DROP TABLE book_accommodation

INSERT INTO book_accommodation
VALUES  ('ALHAJNJN89BSS', 5, now()),
		('SEBAS888BSBSN', 2, date('2022-07-10')),
		('MUAYA67HAJ8BA', 3, date('2022-05-13')),
		('FATJWR05NICEB', 4, date('2022-08-25'));
		
select * from book_accommodation
-----------------------------------------------------------------------------------
-- 11).

CREATE TABLE book_many_times(client varchar(20) references client on delete set null on update cascade,
							site int references site on delete set null on update cascade,
							cost int check(cost > 0),
							typ varchar(20) check( typ in ('Cinema', 'Concert', 'Restaurant')),
							duration int check( duration > 0), -- in hours
							start_date_time timestamptz,
							id SERIAL check(id >= 0),
							UNIQUE(client, site, start_date_time) );

DROP TABLE book_many_times

INSERT INTO book_many_times
VALUES ('SEBAS888BSBSN', 1, 20, 'Cinema', 5, '2022-06-29 18:30:00+02'),
		('FATJWR05NICEB', 2, 10, 'Cinema', 2, date('2022-04-05 19:30:00')),
		('ALHAJNJN89BSS', 1, 50, 'Concert', 5, now()),
		('FATJWR05NICEB', 3, 25, 'Restaurant', 1, now()),
		('FATJWR05NICEB', 4, 20, 'Restaurant', 1, now()),
		('FATJWR05NICEB', 2, 15, 'Cinema', 3, '2022-07-02 15:00:00+02'),
		('FATJWR05NICEB', 1, 40, 'Concert', 4, now());

select * from book_many_times

-----------------------------------------------------------------------------------
-- 12).
CREATE TABLE organiser_dj( ssn varchar(20) check (ssn ~ '^[A-Z0-9]+$')PRIMARY KEY,
						   firstname varchar(20) not null,
						   surname varchar(20) not null,
						   city int references city on delete set null on update cascade,
						   age int not null check(age >= 18),
						   email varchar(20) not null,
						   sex varchar(6) ,
						   salary int check(salary > 0),
						   hire_date date,
						   license varchar(20) check (license is null or license ~ '^[A-Z0-9]+$') );

DROP TABLE organiser_dj

INSERT INTO organiser_dj
VALUES  ('HARHIL89E92NM', 'Harvey', 'Hills', 1, 22, 'nharvey@yahoo.com', 'MALE', 2200, '2019-03-23', 'AGSHABA78B'),
		('DUGOHB05NICEB', 'Duck', 'Go', 1, 26, 'duck@yahoo.com', 'FEMALE', 2000, 	   '2022-01-01', NULL),
		('ALETUDJ89NNSN', 'Alexa', 'Turjan', 2, 39, 'alexa@gmail.com', 'FEMALE', 2000,		'2020-02-28', 'GSJS87BSNB'),
		('SAMPIJS788BWE', 'Samuele', 'Johns', 5, 42, 'samuele@yahoo.com', 'MALE',  3000 ,   '2016-06-09',  'HSJA89NSNS');
		
SELECT * FROM organiser_dj

-----------------------------------------------------------------------------------
-- 13).
CREATE TABLE work(dj varchar(20) not null references organiser_dj on delete set null on update cascade,
				site_id int not null references site on delete set null on update cascade,
				 PRIMARY KEY (dj, site_id));

drop table work		
				   
INSERT INTO work 
VALUES 	('HARHIL89E92NM', 1), ('DUGOHB05NICEB', 2),
		('ALETUDJ89NNSN', 3), ('SAMPIJS788BWE', 1),
		('HARHIL89E92NM', 2), ('SAMPIJS788BWE', 3),
		('DUGOHB05NICEB', 3)

SELECT * FROM work;

-----------------------------------------------------------------------------------
-- 14).
CREATE TABLE director(    ssn varchar(20) check (ssn ~ '^[A-Z0-9]+$')PRIMARY KEY,
						   firstname varchar(20) not null,
						   surname varchar(20) not null,
						   city int references city on delete set null on update cascade,
						   age int not null check(age > 18),
						   email varchar(20) not null,
						   sex varchar(6),
						   salary int check(salary > 0),
						   hire_date date );


DROP TABLE director

INSERT INTO director
VALUES  ('NIBTYL89E92NM', 'Nicholas', 'Best', 1, 20, 'nicholas@yahoo.com', 'MALE', 6800, '2017-03-23'),
		('MAJHSB05NICEB', 'Stephen', 'Jones', 1, 26, 'jones@yahoo.com', 'MALE', 		3500, 	   '2016-01-01'),
		('ALETUDJ89NNSN', 'Aisha', 'Huda', 2, 39, 'aisha@gmail.com', 'FEMALE', 3100,		'2020-02-28'),
		('TODOIJS788BWE', 'Tony', 'Droid', 5, 42, 'tony@yahoo.com', 'MALE',  5000 ,   '2016-06-09');


SELECT * FROM director

-----------------------------------------------------------------------------------
-- 15).

CREATE TABLE event_instance(typ varchar(20) references event on delete set null on update cascade,
						   organiser_dj varchar(20) references organiser_dj on delete set null on update cascade,
						   client varchar(20) references client on delete set null on update cascade,
						   buy_date date,
						   site int references site on delete set null on update cascade,
						   start_date_time 		timestamptz,
						   finish_date_time   	timestamptz,
						   id SERIAL check(id >= 0) PRIMARY KEY,
						   CHECK(start_date_time < finish_date_time and buy_date < finish_date_time),
						   UNIQUE(site, start_date_time));

drop table event_instance cascade

INSERT INTO event_instance
VALUES ('Picnic', 'ALETUDJ89NNSN', 'FATJWR05NICEB', now(), 1, timestamptz('2022-10-29 18:30:00'),  timestamptz('2022-10-29 23:30:00') ),
	   ('Picnic', 'SAMPIJS788BWE', 'DABJNSJ89NNSN', now(), 2, timestamptz('2022-07-02 15:00:00'),  timestamptz('2022-07-02 23:30:00') ),
	('Marriage Ceremony', 'ALETUDJ89NNSN', 'DABJNSJ89NNSN', date('2022-07-05'), 2, timestamptz('2022-08-10 10:00:00'),  timestamptz('2022-08-10 18:30:00') ),
	('Birthday', 'ALETUDJ89NNSN', 'FATJWR05NICEB', now(), 3, timestamptz('2022-06-29 18:30:00'),  timestamptz('2022-06-29 23:30:00') ),
	('Picnic', 'DUGOHB05NICEB', 'ASRBSJS788BWE', date('2022-04-20'), 1, timestamptz('2022-04-29 18:30:00'),  timestamptz('2022-04-29 23:30:00') );
		
SELECT * FROM event_instance;
-----------------------------------------------------------------------------------
--16.
CREATE TABLE event(typ varchar(20) not null check(typ in ('Picnic', 'Birthday', 'Marriage Ceremony', 'Concert')) PRIMARY KEY, 
					cost int not null check(cost > 0) );

drop table event

INSERT INTO event
VALUES 				   ('Picnic', 500),
					   ('Birthday', 500),
					   ('Concert', 500),
					   ('Marriage Ceremony', 500);
					   
SELECT * FROM event

-----------------------------------------------------------------------------------
-- 17).


CREATE TABLE adevent(event_type varchar(20) references event on delete set null on update cascade, 
				   media_id int references media on delete set null on update cascade,
				   cost int not null check(cost > 0), 
				   duration int not null check(duration > 0), 
				   start_date_time timestamp, 
				   end_date_time timestamp,
				   UNIQUE(start_date_time, end_date_time, media_id, event_type),
				   CHECK (start_date_time::date < end_date_time::date),
				   id SERIAL check(id >= 0) PRIMARY KEY );
				   
drop table adevent	cascade				

INSERT INTO adevent VALUES 
('Picnic', 1, 500, 15, '2020-06-14 17:18:00', '2020-10-29 17:18:00'), 
('Marriage Ceremony', 8, 250, 2, '2021-08-19 16:15:00', '2021-09-19 16:15:00'),
('Birthday', 7, 550, 5, '2022-03-27 15:25:00', '2022-10-27 15:25:00'),
('Concert', 4, 735, 8, '2022-01-18 06:55:00', '2022-02-18 06:55:00')

SELECT * FROM adevent;

-----------------------------------------------------------------------------------
-- 18).
CREATE TABLE adinstance(event_int_id int references event_instance on delete set null on update cascade, 
				   media_id int references media on delete set null on update cascade,
				   cost int not null check(cost > 0), 
				   duration int not null check(duration > 0), 
				   start_date_time timestamptz, 
				   end_date_time timestamptz,
				   UNIQUE(start_date_time, end_date_time, media_id, event_int_id),
				   CHECK (start_date_time::date < end_date_time::date),
				   id SERIAL check(id >= 0) PRIMARY KEY);
				   
drop table adinstance			

INSERT INTO adinstance VALUES 
(1, 1, 3000, 70, '2021-02-23 18:13:00', '2021-05-03 18:13:00'), 
(2, 3, 400, 3, '2022-01-28', '2022-04-30'),
(3, 6, 270, 2, '2021-04-07 09:46:00', '2021-07-09'),
(4, 5, 1000, 10, '2022-05-16', '2022-09-29 13:30:00')

SELECT * FROM adinstance;

-----------------------------------------------------------------------------------
-- 19).

CREATE TABLE adsite(site_id int references site on delete set null on update cascade,
				   media_id int references media on delete set null on update cascade,
				   cost int not null check(cost > 0), 
				   duration int not null check(duration > 0), 
				   start_date_time timestamp, 
				   end_date_time timestamp,
				   id SERIAL check(id >= 0) PRIMARY KEY,
				   UNIQUE(start_date_time, end_date_time, media_id, site_id),
				   CHECK (start_date_time::date < end_date_time::date));
				   
drop table adsite				

INSERT INTO adsite VALUES 
(1, 7, 200, 2, '2021-10-24 19:35:00', '2021-10-26 19:35:00'), 
(2, 8, 150, 3, '2021-11-17 23:53:00', '2021-11-20 23:53:00'),
(3, 4, 840, 10, '2021-04-07 11:50:00', '2021-06-03 11:50:00'),
(2, 2, 110, 6, '2022-05-13 00:00:00', '2022-06-23 00:00:00'),
(2, 2, 110, 6, '2022-09-13 00:00:00', '2022-11-13 00:00:00'),
(1, 10, 400, 2, '2021-02-24 19:35:00', '2021-10-26 19:35:00');

SELECT * FROM adsite;

-----------------------------------------------------------------------------------
-- 20).
CREATE TABLE media(name varchar(20) not null,
				   typ varchar(20) not null 
				   		check(typ in ('TV channel', 'Radio station', 'Newspaper', 'Billboard')),
				   id SERIAL check(id >= 0) PRIMARY KEY,
				   UNIQUE(name, typ));
				   
drop table media cascade	

INSERT INTO media VALUES 
('Al Jazeera', 'TV channel'), ('CNN', 'TV channel'),
('RAI 1', 'TV channel'), ('RAI 2', 'TV channel'), ('RAI 3', 'TV channel'),
('MTV', 'Radio station'), ('Virgin', 'Radio station'), 
('Radio Deejay', 'Radio station'), ('The Pen', 'Newspaper'), ('Ink out', 'Newspaper')

delete from media where id = 2
update media set id = 100 where id = 3

SELECT * FROM media;

-----------------------------------------------------------------------------------
-- 21).
CREATE TABLE facility(type varchar(25) not null primary key)

drop table facility		

INSERT INTO facility VALUES 
 ('Gym'), ('Swimming Pool'), ('Sports Field')

SELECT * FROM facility;

-----------------------------------------------------------
--22)
drop table facility_rel 

CREATE TABLE facility_rel(fac varchar(25)  references facility on delete set null on update cascade,
				 accom_id int  references accommodation on delete set null on update cascade,
				 PRIMARY KEY (fac, accom_id))
				 
INSERT INTO facility_rel 
VALUES  ('Sports Field', 4),('Gym', 2), ('Gym', 3), ('Gym', 4), ('Swimming Pool', 3),
		 ('Swimming Pool', 2),('Sports Field', 2), ('Sports Field', 3), ('Swimming Pool', 4);
	

SELECT * FROM facility_rel

-----------------------------------------------------------------------------------
-- 23).
CREATE TABLE accommodation(name varchar(20) not null,
						   city_id int not null references city on delete set null on update cascade, 
						   cost int not null check(cost > 0),
						   addr Addr not null,
						   etype varchar(20) check(etype in ( 'Hotel', 'Hostel', 'Bed & Breakfast')),
						   id SERIAL check(id >= 0) PRIMARY KEY,
						   UNIQUE(name, city_id, addr)) ;
				 
drop table accommodation cascade

INSERT INTO accommodation VALUES 
 ('Cavalluccio Marino', '1', '35', ('via Monte Bianco', 25, 00671), 'Hotel'),
 ('Stella', '6', '90', ('via Bligny', 67, 00013), 'Hotel'),
 ('Lo studente', '4', '10', ('via Leonardo da Vinci', 34, 04893), 'Hostel'),
 ('Valle Verde', '8', '30', ('via Garibaldi', 17, 65204), 'Bed & Breakfast')

SELECT * FROM accommodation;

-----------------------------------------------------------------------------------
-- 24).
DROP TABLE site cascade

CREATE TABLE site(name varchar(20),
				 city int references city on delete set null on update cascade,
				 director varchar(20) references director on delete set null on update cascade,
				 insurance int references business on delete set null on update cascade,
				 capacity int check( capacity > 0) not null,
				 address Addr not null,
				 etype varchar(20) check(etype in ( 'Cinema', 'Beach', 'Hall', 'Restaurant')),
				 id SERIAL check( id >= 0) PRIMARY KEY,
				 UNIQUE (name, city) );

INSERT INTO site
VALUES ('Coco Ocean', 1, 'NIBTYL89E92NM', 13, 400, ('via della Liberta', 12, 00342), 'Beach' ),
		('Paradise Zone', 4, 'ALETUDJ89NNSN', 15, 300, ('via Asiago', 140, 00442), 'Beach' ),
		('Goditi', 4, 'ALETUDJ89NNSN', 15, 100, ('via Dolomiti', 50, 00511), 'Cinema' ),
		('Blue Sky', 1, 'NIBTYL89E92NM', 13, 400, ('via maria mamma', 12, 00342), 'Beach' );



SELECT * FROM site
		
-----------------------------------------------------------------------------------
-- 25).
CREATE TABLE city(name varchar(20),
				  county varchar(20),
				 region varchar(20),
				 id SERIAL check(id >= 0) PRIMARY KEY,
				 UNIQUE (name, county));
				 
drop table city cascade;

INSERT INTO city
VALUES ('Viterbo', 'Viterbo', 'Lazio' ),
		('Roma', 'Roma', 'Lazio' ),
		('Napoli', 'Napoli', 'Campania' ),
		('Terni', 'Terni', 'Umbria' ),
		('Perugia', 'Perugia', 'Umbria' ),
		('Marino', 'Roma', 'Lazio' ),
		('Milano', 'Milano', 'Lombardia' ),
		('Catania', 'Catania', 'Sicilia' ),
		('Trevignano Romano', 'Roma', 'Lazio' ),
		('Bracciano', 'Roma', 'Lazio' ),
		('Montecastrelli', 'Terni', 'Umbria');

UPDATE city
set county = 'Viterbo'
where name = 'Viterbo' ;

SELECT * FROM city;

-----------------------------------------------------------
--26)
DROP table if exists advert_business

create table advert_business(business int references business on delete set null on update cascade,
							 site int references site on delete set null on update cascade,
							 cost int not null check(cost > 0),  
							 duration int not null check(duration > 0), 
							 s_date_time timestamp not null , 
							 e_date_time timestamp not null ,
							 id SERIAL check(id >= 0) PRIMARY KEY,
							 UNIQUE(business, site, s_date_time));

INSERT INTO advert_business VALUES
(1, 2, 200, 30, '2020-09-01 08:47:00', '2020-09-30 08:47:00'),
(3, 4, 500, 45, '2021-11-01 10:53:00', '2021-12-15 10:53:00'),
(2, 1, 300, 15, '2021-11-01 12:11:00', '2021-12-15 12:11:00'),
(1, 3, 200, 30, '2021-09-01 08:47:00', '2020-10-10 08:47:00'),
(3, 4, 500, 45, '2021-01-01 10:53:00', '2021-02-15 10:53:00'),
(2, 2, 400, 15, '2021-12-01 12:11:00', '2022-02-15 12:11:00');

SELECT * FROM advert_business;

-----------------------------------------------------------
--27)
drop table play 

CREATE TABLE play(site_id int  references site on delete set null on update cascade,
				 music_id int  references music on delete set null on update cascade,
				 PRIMARY KEY (site_id, music_id))
		
INSERT INTO play 
VALUES  (1, 3),
		(2, 5),
		(1, 4),
		(2, 3), 
		(3, 5),
		(4, 3);

-- cannot add because 2pac, queen, etc were banned. There musics cannot be played on our sites
INSERT INTO play 
VALUES  (3, 1), (1, 1),(3, 2);

SELECT * FROM play

-----------------------------------------------------------
--28)
drop table watch 
truncate watch

CREATE TABLE watch(site_id int  references site on delete set null on update cascade,
				 film_id int  references music on delete set null on update cascade,
				 PRIMARY KEY (site_id, film_id))
				 
INSERT INTO watch 
VALUES  (1, 3),
		(2, 4),
		(1, 2),
		(2, 3),
		(3, 4),
		(3, 3);

-- cannot add because some actors were banned. There films cannot be played on our sites
INSERT INTO watch 
VALUES  (1, 8),
		(2, 8);

SELECT * FROM watch
-----------------------------------------------------------
--29)
DROP table if exists music cascade

-- we can have the same music name and type. No need for unique constraint
create table music(name varchar(30) not null , 
				  typ varchar(20) not null 
				   		check( typ in ('Reggae', 'Hip Hop', 'Rock', 'Traditional Music') ), 
				  id SERIAL check(id >= 0) PRIMARY KEY);

INSERT INTO music VALUES
('Smells Like Teen Spirit', 'Reggae'), ('Bohemian Rhapsody', 'Rock'),
('Imagine', 'Rock'), ('Alright', 'Hip Hop'), ('Be Good', 'Traditional Music'),
('Just Do It Right', 'Traditional Music'), ('Dance And Go', 'Reggae'), ('Be Humble', 'Hip Hop')

select * from music
-----------------------------------------------------------
--30)
drop table sing  cascade

-- The same artiste cannot produce the same music more than once
CREATE TABLE sing(music_id int  references music on delete set null on update cascade,
				 artname_id varchar(20)  references artiste on delete set null on update cascade,
				 PRIMARY KEY (music_id, artname_id),
				 UNIQUE(music_id, artname_id)); 
		 
INSERT INTO sing 
VALUES  (1, 'David Fincher'),
		(2, 'Queen'),
		(7, 'Steven Spielberg'),
		(4, 'Kendrick Lamar'),
		(1, 'Tupac Shakur'),
		(3, 'Nirvana'),
		(2, 'David Fincher'),
		(1, 'Steven Spielberg'),
		(3, 'Kendrick Lamar'),
		(2, 'Kendrick Lamar'),
		(7, 'David Fincher'),
		(4, 'Steven Spielberg'),
		(2, 'Nirvana'),
		(1, 'Dryer Fry'),
		(6, 'Kendrick Lamar');

SELECT * FROM sing
--------------------------------------------------------
--31)
DROP table if exists film cascade

create table film(director varchar(20)references artiste on delete set null on update cascade, 
				  name varchar(20), 
				  typ varchar(20) check( typ in ('Comedy', 'Action Movie', 'Cartoon', 'SciFi Film') ),
				  id SERIAL check(id >= 0) PRIMARY KEY,
				 UNIQUE (director, name, typ) );

INSERT INTO film VALUES
('Steven Spielberg', 'Saving Private Ryan', 'Action Movie'),
('Brad Pitt', 'The Godfather', 'Action Movie'),
('David Fincher', 'Fight Club', 'Comedy'),
('Leman Huss', 'Kill Shadow', 'Action Movie'),
('Dryer Fry', 'Be Gentle', 'Comedy'),
('Steven Spielberg', 'Rock and Duck', 'Comedy'),
('Leman Huss', 'Twist The Plot', 'Comedy'),
('David Fincher', 'Go To School', 'Cartoon');

SELECT * FROM film
-----------------------------------------------------------
--32)

DROP table if exists act cascade

-- The same actor cannot act in the same film more than once
CREATE TABLE act(film_id int  references film on delete set null on update cascade,
				 artname_id varchar(20) references artiste on delete set null on update cascade,
				 PRIMARY KEY (film_id, artname_id),
				 UNIQUE(film_id, artname_id))
				 
INSERT INTO act 
VALUES  (1, 'David Fincher'),
		(1, 'Matt Damon'),
		(1, 'Bryan Cranston'),
		(3, 'Brad Pitt'),
		(6, 'Tupac Shakur'),
		(5, 'Paul McCartney'),
		(5, 'Tom Cruise'),
		(6, 'Steven Spielberg'),
		(2, 'Tom Hanks'),
		(2, 'Bryan Cranston'),
		(5, 'Brad Pitt'),
		(2, 'John Lennon'),
		(6, 'Kendrick Lamar'),
		(6, 'Queen'),
		(1, 'Nirvana'),
		(3, 'David Fincher'),
		(4, 'Leman Huss'),
		(2, 'Dryer Fry');

SELECT * FROM act

--------------------------------------------------------
--33)
DROP table if exists artiste cascade

create table artiste(artname varchar(20) PRIMARY KEY, 
					 rank int UNIQUE check(rank > 0 and rank <= 100),  --in terms of % 
					 age smallint check(rank > 0), 
					 etype varchar(20) NOT NULL check( etype in ('Actor', 'Musician', 'Film Director')) );

INSERT INTO artiste VALUES
('2Pac', 26, null, 'Musician'),
('Paul McCartney', 31, 80, 'Musician'),
('Tom Cruise', 51, 59, 'Actor'),
('Steven Spielberg', 75, 75, 'Film Director'),
('Tom Hanks', 21, 65, 'Actor'),
('Matt Damon', 37, 59, 'Actor'),
('Bryan Cranston', 53, 66, 'Actor'),
('Brad Pitt', 29, 58, 'Film Director'),
('John Lennon', 50, 40, 'Musician'),
('Kendrick Lamar', 69, 35, 'Musician'),
('Queen', 91, 52, 'Musician'),
('Nirvana', 84, 37, 'Musician'),
('David Fincher', 90, 34, 'Film Director'),
('Leman Huss', 78, 40, 'Film Director'),
('Dryer Fry', 8, 32, 'Film Director');

select * from artiste

------------------------------------------------------
--34)

DROP table if exists crime_convict 

create table crime_convict(artname varchar(20) references artiste on delete set null on update cascade,
						  crimetype varchar(30) NOT NULL 
						  	check( crimetype in ('Rape', 'Murder', 'Hate Speech', 'Assault') ),
						  severity int not null check(severity >= 0 and severity <= 100),
						  date_convicted DATE not null,
						  id SERIAL check(id >= 0) PRIMARY KEY)

INSERT INTO crime_convict VALUES
('2Pac', 'Assault', 75, '1995-04-27'),
('2Pac', 'Murder', 50, '1993-10-31'),
('Paul McCartney', 'Hate Speech', 10, '2022-01-24'),
('Tom Hanks', 'Rape', 80, '2022-03-22'),
('Kendrick Lamar', 'Assault', 65, '2022-06-26'),
('Queen', 'Hate Speech', 89, '2022-06-13'),
('Kendrick Lamar', 'Hate Speech', 20, '2022-03-19');

INSERT INTO crime_convict VALUES
('David Fincher', 'Rape', 90, '2021-12-25');

select * from crime_convict

--------------------------------------------------------








