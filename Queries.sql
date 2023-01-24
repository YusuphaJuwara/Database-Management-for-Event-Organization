--1 Find the cost, type and code of the event instance that was rated the best (above 75% ratings) by most of our clients.

-- Create a view 
CREATE VIEW query_1 AS  SELECT r.event_instance, count(*) as counter
						FROM rating AS r
						WHERE r.rate_value > 75
						GROUP BY r.event_instance ;

SELECT e.cost, e.typ, ei.id
FROM event_instance AS ei JOIN event AS e ON e.typ = ei.typ
WHERE ei.id = ANY  (SELECT q.event_instance
					FROM query_1 AS q
					WHERE q.counter = ( SELECT max(q.counter)
										FROM query_1 AS q )
				  );
				  
------------------------------------------------------------------------------
-- 2. Find the ArtNames and Ranks of all artistes that play music genre Rock and were banned for having committed a hate speech crime (note: banned if the severity is 76-100%).

SELECT a.artname, a.rank
FROM artiste a
WHERE a.artname IN  (SELECT s.artname_id
					FROM sing s JOIN music m ON s.music_id = m.id
					WHERE m.typ = 'Rock' and 
					 	s.artname_id IN ( SELECT c.artname
										FROM crime_convict AS c
									    WHERE c.severity > 75 and crimetype='Hate Speech')
				  );

------------------------------------------------------------------------------
-- 3. Which EVENT type is advertised most (birthday, picnic, etc) to MEDIA type TV.
-- view
DROP VIEW IF EXISTS query_3 cascade;

CREATE VIEW query_3 AS
SELECT ae.event_type, count(*) as counter
FROM adevent ae
WHERE ae.media_id IN (SELECT m.id
					FROM media m
					WHERE m.typ = 'TV' )
GROUP BY ae.event_type ;

SELECT q.event_type, q.counter
FROM query_3 q
WHERE q.counter = (SELECT MAX(q.counter)
					FROM query_3 q);

------------------------------------------------------------------------------
-- 4. Total cost spent on each media channel's ads (so how much for billboards? How much for newspaper? How much for TV ads? How much for Radio ads?).

DROP VIEW IF EXISTS union_query_3 cascade;

-- view
CREATE VIEW query_4 AS
SELECT *
FROM media m;

CREATE VIEW union_query_4 AS
SELECT q.typ, sum(ae.cost) as total_sum, count(*) as counter
FROM adevent ae INNER JOIN query_4 q on ae.media_id = q.id
GROUP BY q.typ
UNION
SELECT q.typ, sum(ai.cost) as total_sum, count(*) as counter
FROM adinstance ai INNER JOIN query_4 q on ai.media_id = q.id
GROUP BY q.typ
UNION
SELECT q.typ, sum(ads.cost) as total_sum, count(*) as counter
FROM adsite ads INNER JOIN query_4 q on ads.media_id = q.id
GROUP BY q.typ ;

SELECT uq.typ, sum(uq.total_sum), count(*) as counter
from union_query_4 uq
group by uq.typ ;

------------------------------------------------------------------------------
-- 5. SSNs and Names of Organisers/DJs who organise an EVENT in a site s

SELECT d.ssn, d.firstname, d.surname, s.name
FROM site s, organiser_dj d JOIN event_instance ei ON d.ssn = ei.organiser_dj
WHERE ei.site = 2 and s.id = 2--siteID

------------------------------------------------------------------------------
-- 6. ArtNames, Ages and Ranks of Musicians whose musics were not banned even though they are/were crime convicts, but the severity is not grave enough for their musics to be banned. 

drop view query_6
--view
--First get the banned names... why?
CREATE VIEW query_6 AS
SELECT cc.artname
FROM crime_convict AS cc
WHERE cc.severity > 75 ;

SELECT a.artname, a.age, a.rank, cc.severity, cc.crimetype
FROM artiste a INNER JOIN crime_convict cc ON a.artname = cc.artname
WHERE a.etype = 'Musician' and a.artname NOT IN (SELECT *
												 FROM query_6)
ORDER BY a.artname ;

------------------------------------------------------------------------------
-- 7. ArtNames and Ages of Film Directors who are in the top 25% rank, act in their own directed movies and have never been a crime convict.

SELECT a.artname, a.age, a.rank, f.name, f.typ
FROM artiste a INNER JOIN film f ON a.artname = f.director, act
WHERE act.artname_id = f.director and 
	  a.rank > 75 and 
	  f.director NOT IN (SELECT DISTINCT cc.artname
						FROM crime_convict cc);

------------------------------------------------------------------------------
-- 8. Clients (Name and SSN)  who had been given promo codes but failed to use them (expired or decided not to) .

SELECT c.ssn, c.firstname, c.surname, pc.typ
FROM client c INNER JOIN promocode pc ON c.ssn = pc.client
WHERE etype = 'Expired Promo' and used_or_not = 'No' ;

------------------------------------------------------------------------------
-- 9. Which SITE generates more money in terms of AD from companies and in which CITY/Location is the site

CREATE VIEW query_9 AS
SELECT ab.site, count(*) as counter
FROM advert_business ab
GROUP BY ab.site;

DROP VIEW query_9

SELECT s.name site_name, c.name city_name, county
FROM site s JOIN city c ON c.id = s.city
WHERE s.id IN (SELECT q9.site
			 	FROM query_9 q9
			 	WHERE q9.counter = (SELECT max(q.counter)
								    FROM query_9 q) );	    

------------------------------------------------------------------------------
-- 10. Which accommodation is the most booked among our clients and in which Region is it located?

CREATE VIEW query_10 AS
SELECT ab.accommodatio_id, count(*) as counter
FROM book_accommodation ab
GROUP BY ab.accommodatio_id;

SELECT a.name accommodation_name, c.name city_name, county, region, q10.counter
FROM accommodation a JOIN city c ON c.id = a.city_id, query_10 q10
WHERE q10.accommodatio_id = a.id and q10.counter = (SELECT max(q.counter)
								    				FROM query_10 q) ;	 

------------------------------------------------------------------------------
-- 11. Find food IDs  and  their suppliers BusinessTypes and names and also the date supplied (a food can be supplied by more than one supplier).

SELECT fd.id, fd.name food_or_drnks_name, s.date, b.business_type, b.name business_name
FROM fooddrinks fd, supply s, business b
WHERE fd.id = s.food_id and s.bus_id = b.id

------------------------------------------------------------------------------
-- 12. Find clients (SSN and Name) that buy event instances in a site which is not in the same city they live

SELECT DISTINCT ssn, c.firstname, c.surname, c.city city_client, s.city city_site
FROM client c, event_instance ei, site s
WHERE c.ssn = ei.client and c.city <> s.city and ei.site = s.id

------------------------------------------------------------------------------
-- 13. Find clients (Name and SSN) who booked accommodation in a city which is different from the city in which the site they booked their seats is located.

drop view query_accom

CREATE VIEW query_accom AS
SELECT ba.client, ac.city_id as city
FROM accommodation ac JOIN book_accommodation ba ON ac.id = ba.accommodatio_id

CREATE VIEW query_site AS
SELECT bmt.client, s.city
FROM site s JOIN book_many_times bmt ON s.id = bmt.site

SELECT DISTINCT ssn, c.firstname, c.surname
FROM client c
WHERE c.ssn IN (SELECT qa.client
				FROM query_accom qa JOIN query_site qs 
				ON qa.client = qs.client and qa.city <> qs.city);

------------------------------------------------------------------------------
-- 14. Which ARTISTE within the top 25% has had his music played in our SITE less than any other singer not in the top 25% (collaboration between musicians is allowed).

drop view query_14

CREATE VIEW query_14 AS
SELECT artname, rank, count(*) as counter
FROM sing s JOIN play p ON s.music_id = p.music_id, artiste a
WHERE s.artname_id = artname
GROUP BY artname ;

SELECT a.artname artname1, a.counter counter1, q14.artname artname2, q14.counter counter2, a.rank rank1, q14.rank rank2
FROM query_14 a JOIN query_14 q14 ON a.artname <> q14.artname
WHERE 	a.rank > 75 and 
		q14.rank <= 75 and
		a.counter < q14.counter ;

------------------------------------------------------------------------------
-- 15. Find MUSICs that have their singers convicted ( not necessarily banned) together with the crime type, severity and date convicted.

SELECT c.artname, crimetype, m.name music_name, severity, date_convicted
FROM music m, sing s, crime_convict c
WHERE m.id = s.music_id and s.artname_id = c.artname
ORDER BY artname

------------------------------------------------------------------------------
-- 16. Get the names, locations and regions of the companies at which our sites are insured.

SELECT b.name insurance_comp, c.name city_name, county, region, s.name site_name
FROM business b, site s, city c
WHERE b.city = c.id and s.insurance = b.id
ORDER BY b.name

------------------------------------------------------------------------------
-- 17. Names of artistes who act in a Film type comedy and also sing Music type Reggae.

SELECT DISTINCT a.artname_id
FROM act a JOIN film f ON a.film_id = f.id, music m JOIN sing s ON m.id = s.music_id
WHERE a.artname_id = s.artname_id and f.typ = 'Comedy' and m.typ = 'Reggae'

------------------------------------------------------------------------------
-- 18. Add a new client who bought a food type Pakistani Biryani Rice with 2 ingredients, appetiser (Jumbo) and coloriser (Rice Color))

drop procedure add_clint_buy_food

CREATE OR REPLACE PROCEDURE add_clint_buy_food(
	ssn_id varchar(20), fname varchar(20), sname varchar(20), city int, age int, email varchar(20), sex varchar(6), ingredient_id int,
	fd_id int, etype varchar(20), food_type varchar(20), food_name varchar(20), cost int, qnt int default 1)
	
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM client WHERE ssn = ssn_id) THEN
		INSERT INTO client
		VALUES (ssn_id, fname, sname, city, age, email, sex);
	END IF;
	
	-- if the food was already made, check if someone has already bought it
	IF NOT EXISTS (SELECT * FROM buyfood b WHERE  b.food_id = fd_id) THEN
		INSERT INTO buyfood
		VALUES (ssn_id, fd_id, now());
	ELSE
		RAISE EXCEPTION 'That food id is not availabe, somebody has bought it';
	END IF;

	IF NOT EXISTS (SELECT * FROM fooddrinks WHERE id = fd_id) THEN
		INSERT INTO fooddrinks
		VALUES (etype, food_type, food_name, cost, qnt, fd_id);
	
		INSERT INTO ingfood
		VALUES (ingr_id, fd_id), (3, fd_id);
	ELSE
		IF NOT EXISTS (SELECT * FROM ingfood i WHERE i.food_id = fd_id and i.ingr_id = ingredient_id) THEN
			INSERT INTO ingfood
			VALUES (ingr_id, fd_id);
		END IF;

		IF NOT EXISTS (SELECT * FROM ingfood i WHERE i.food_id = fd_id and i.ingr_id = 3) THEN
			INSERT INTO ingfood
			VALUES (3, fd_id);
		END IF;
	END IF;
END; $$;

CALL add_clint_buy_food('ADNAN89BAYD', 'Adnan', 'Bay', 6, 89, 'adnan@hotmail.com', 'MALE', 1, 200, 'Rice', 'Biryani', 'Pakistani Biryani', 10, 1);

------------------------------------------------------------------------------
-- 19 Assign a new promo code to an existing  client

CREATE OR REPLACE PROCEDURE add_promo_existing_client(ssn_id varchar(20), event_type varchar(20), st_date date, en_date date, entity_type varchar(20))
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS (SELECT * FROM client WHERE ssn = ssn_id) THEN
		INSERT INTO promocode
		VALUES (ssn_id, event_type, st_date, en_date, NULL,  entity_type);
	ELSE
		RAISE EXCEPTION 'Cannot assign promocode to new clients';
	END IF;
END;$$;

CALL add_promo_existing_client('SEBAS888BSBSN', 'Marriage Ceremony', '2022-07-05', '2022-08-24', 'Not Expired Promo')

------------------------------------------------------------------------------
-- 20. An existing client wants to buy an event type 'Picnic' in a site type 'Beach' and name 'Coco Ocean'.

drop procedure if exists buy_event_existing_client

CREATE OR REPLACE PROCEDURE buy_event_existing_client(client_ssn varchar(20), org_ssn varchar(20), event_type varchar(20), st_date timestamptz, en_date timestamptz, event_ins_id int, s_id int)
LANGUAGE plpgsql
AS $$
DECLARE promo_deduction_amount int DEFAULT 0;
BEGIN
	-- first check if the client has a promo 
	IF EXISTS (SELECT * FROM promocode WHERE client = client_ssn) THEN
		promo_deduction_amount := 100; -- fixed deduction amount
		RAISE NOTICE '% you are eligilble for a deduction of amount %.', client_ssn, promo_deduction_amount;
	END IF;
	
	INSERT INTO event_instance
	VALUES (event_type, org_ssn, client_ssn, now(), s_id, st_date, en_date, event_ins_id);
END;$$;

CALL buy_event_existing_client('YPHA10WQEWAAWAQ', 'DUGOHB05NICEB', 'Picnic', '2022-10-10 15:30:00', '2022-10-10 22:30:00', 20, 1);

-- THE END ...
