--constraint 2). A user cannot rate an event they didn’t book or buy
CREATE OR REPLACE FUNCTION cant_rate_if_not_b()
	RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
	count1 int DEFAULT 0;
	count2 int DEFAULT 0;
BEGIN
	
	SELECT count(*) INTO count1
	FROM book_many_times bmt INNER JOIN event_instance ei 
	ON bmt.start_date_time::date = ei.start_date_time::date and bmt.site = ei.site
	WHERE NEW.client = bmt.client;
	
	SELECT count(*) INTO count2
	FROM event_instance ei 
	WHERE 	NEW.client = ei.client 
			and ei.start_date_time::date < now()::date 
			and NEW.event_instance = ei.id;
	
	-- print what is in the count variables
	RAISE NOTICE 'count1: %, count2: %', count1, count2;
	
	count1 := count1 + count2;
	
	IF count1 = 0 THEN
		RAISE EXCEPTION '% cannot rate an event s/he did not buy or book', NEW.client;
	END IF;
	
RETURN NEW;
END; $$;

drop trigger cant_rate_if_not_b on rating

CREATE OR REPLACE TRIGGER cant_rate_if_not_b
BEFORE INSERT ON rating
FOR EACH ROW
	EXECUTE PROCEDURE cant_rate_if_not_b();

--------------------------------------------------------------------------

--constraint 7). The number of reservations for a site cannot exceed the site capacity
CREATE OR REPLACE FUNCTION cannot_exceed_capacity()
	RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
	r RECORD;
	count1 int DEFAULT 0;
	
BEGIN
	SELECT * INTO r
	FROM site s 
	WHERE s.id = NEW.site ;
	
	SELECT count(*) INTO count1
	FROM book_many_times bmt
	WHERE NEW.site = bmt.site;
		
	IF r.capacity <= count1 THEN
		RAISE EXCEPTION '% in % cannot be booked more than its capacity: % < %', r.name, r.city, r.capacity, count1 + 1;
	END IF;
RETURN NEW;
END; $$;

drop trigger cannot_exceed_capacity on site

CREATE OR REPLACE TRIGGER cannot_exceed_capacity
BEFORE INSERT ON book_many_times
FOR EACH ROW
	EXECUTE PROCEDURE cannot_exceed_capacity();
	
--------------------------------------------------------------------------
--constraint 11). An Organiser/DJ cannot earn more than or equal to any of the Directors
CREATE OR REPLACE FUNCTION dj_cannot_earn_more_than_any_director()
	RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE min_amount int DEFAULT 0;

BEGIN
	SELECT min(salary) INTO min_amount
	FROM director d ;
	
	-- print to see the minimum amount of the directors
	RAISE NOTICE 'Minimum salary for directors is %', min_amount;

	IF NEW.salary >= min_amount THEN
		RAISE EXCEPTION '% with %$ cannot earn more than or equal to any of the directors with min salary of %', NEW.name, NEW.salary, min_amount;
	END IF;
RETURN NEW;
END; $$;

drop trigger dj_cannot_earn_more_than_any_director on site

CREATE OR REPLACE TRIGGER dj_cannot_earn_more_than_any_director
BEFORE INSERT OR UPDATE OF salary ON organiser_dj
FOR EACH ROW
	EXECUTE PROCEDURE dj_cannot_earn_more_than_any_director();
	
--------------------------------------------------------------------------
--constraint 13). If an Artiste is banned (severity > 75% ), his musics and/or films must not be played in our sites
CREATE OR REPLACE FUNCTION ban_music_if_artiste_banned()
	RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE r int := 0;	
BEGIN
	SELECT count(*) INTO r
	FROM crime_convict c JOIN sing s ON c.artname = s.artname_id
		WHERE c.severity > 75 and s.music_id = NEW.music_id ;
	
	IF r > 0 THEN
		RAISE EXCEPTION 'A banned Musician cannot have his/her Music played on our sites';
	END IF;
RETURN NEW;
END; $$;

drop trigger ban_music_if_artiste_banned on play

CREATE OR REPLACE TRIGGER ban_music_if_artiste_banned
BEFORE INSERT ON play
FOR EACH ROW
	EXECUTE PROCEDURE ban_music_if_artiste_banned();
	
--############################	

CREATE OR REPLACE FUNCTION ban_film_if_artiste_banned()
	RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE r int := 0;	
BEGIN
	SELECT count(*) INTO r
	FROM crime_convict c, act a, film f
	WHERE c.severity > 75 and ( (a.film_id = NEW.film_id and c.artname = a.artname_id)
							        OR
							    (f.id = NEW.film_id and c.artname = f.artname_id) );
	
	IF r > 0 THEN
		RAISE EXCEPTION 'A banned Actor/Director cannot have his/her Films played on our sites';
	END IF;
RETURN NEW;
END; $$;

drop trigger ban_film_if_artiste_banned on watch

CREATE OR REPLACE TRIGGER ban_film_if_artiste_banned
BEFORE INSERT ON watch
FOR EACH ROW
	EXECUTE PROCEDURE ban_film_if_artiste_banned();
	
	
--------------------------------------------------------------------------

