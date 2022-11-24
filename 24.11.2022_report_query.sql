
WITH
    album_narrow
    AS
    (
        select distinct
            albumid, title, artistid
        from album
    ),
    genre_narrow
    as
    (
        select
            genreid, "name"
        from public.genre
    ),
    invoiceline_narrow
    as
    (
        select
            trackid, sum(quantity) as sales_quantity
        from public.invoiceline
        group by trackid
    ),
	composer_narrow
	as
	(-- add flags here
		SELECT t.composer, 
		case
		when t.composer like '%Angus%' then 'Y'
		else 'N'
		end as Angus_Young_flag,
		case
		when t.composer like '%Malcolm%' then 'Y'
		else 'N'
		end as Malcolm_Young_flag,
		case
		when t.composer like '%Brian%' then 'Y'
		else 'N'
		end as Brian_Johnson_flag,
		case
        when t.composer like '%,%' or t.composer like '%&%' then 'Y'
        else 'N'
        end as Multiple_composer
		FROM track t
		group by t.composer
	),
    track_narrow
    as
    (
        SELECT t.AlbumId, count(t.trackid) as track_count
        FROM track t
        GROUP by t.AlbumId
    ),
	    customer_
    as
    (
        SELECT t.customerid, t.country
        FROM customer t
		where t.country in ('Canada', 'Finland')
	),
    combined
    as
    (
        select
            t.trackid,
            (case
        when t.name = '' then 'unkown'
        when t.name = '?' then 'unkown'
        when left(t.name,1) = '0' then substring(t.name,5,20)
        when t.name = '.07%' then 'unkown'
        else upper (t."name")
    end)as track_name,
            a.title as album_title,
            case
        when a.title like '%Rock%' then 'Y'
        else 'N'
        end as Biggest_album_flag,
            c.name as artist_name,
            g.name as music_type,
            (case
        when t.composer = '' then 'unkown'
        else t.composer
    end) as name_of_composer,
			com.Angus_Young_flag,
			com.Malcolm_Young_flag,
			com.Brian_Johnson_flag,
			com.Multiple_composer,
            CONCAT(t.milliseconds, ' ms') as time_in_mills,
            CONCAT(ROUND(t.milliseconds*0.001, 1) , ' s')as time_in_sec,
            CONCAT(ROUND(t.milliseconds*0.001/60, 1) , ' min')as time_in_min,
            t.unitprice,
            k.sales_quantity,
            (t.unitprice*k.sales_quantity) as sales,
            track_countt.track_count as track_in_album,
			cus.country as 	Country
        from track t
            left join album_narrow a on t.albumid = a.albumid
            left join artist c on a.artistid = c.artistid
            left join genre_narrow g on t.genreid = g.genreid
            left join invoiceline_narrow k on k.trackid = t.trackid
            left join track_narrow track_countt on t.AlbumId = track_countt.AlbumId
			left join composer_narrow com on t.composer = com.composer			
			left join invoiceline i on t.trackid = i.trackid 
			left join invoice i2 on i.invoiceid = i2.invoiceid 
			inner join customer_ cus on i2.customerid = cus.customerid
        group by t.trackid, a.title, c.name, g.name, k.sales_quantity, track_countt.track_count, t.name,t.composer,
		t.milliseconds,t.unitprice, cus.country, com.Angus_Young_flag,com.Malcolm_Young_flag,com.Brian_Johnson_flag,com.Multiple_composer
        order by t.trackid
    )
select
    *
from combined;



----------------------------------------------
--INDEXES EXAMPLE--

select 
tu.name,
tu.composer,
tu.unitprice
from track tu
where composer = 'Angus Young, Malcolm Young, Brian Johnson'
	
	
drop index if exists ifk_testindex;
drop index if exists ifk_testindex2;

CREATE INDEX IF NOT EXISTS ifk_testindex
    ON public.track (composer ASC NULLS LAST)
	
CREATE INDEX IF NOT EXISTS ifk_testindex2
    ON public.track (composer ASC NULLS LAST)
	INCLUDE ( name, unitprice )

----------------------------------------------

DROP INDEX IF EXISTS public.ifk_country;
DROP INDEX IF EXISTS public.ifk_customersupportrepid;
DROP INDEX IF EXISTS public.ifk_albumartistid;
DROP INDEX IF EXISTS public.ifk_composer;
DROP INDEX IF EXISTS public.ifk_trackalbumid;
DROP INDEX IF EXISTS public.ifk_albumid;
DROP INDEX IF EXISTS public.ifk_trackgenreid;
DROP INDEX IF EXISTS public.ifk_trackmediatypeid;

------------------------------------------------------

CREATE INDEX IF NOT EXISTS ifk_country
    ON public.customer 
    (customerid  ASC NULLS LAST)
	INCLUDE (country);

CREATE INDEX IF NOT EXISTS ifk_customersupportrepid
    ON public.customer 
    (supportrepid ASC NULLS LAST);

CREATE INDEX IF NOT EXISTS ifk_albumartistid
    ON public.album 
    (artistid ASC NULLS LAST);

CREATE INDEX IF NOT EXISTS ifk_albumid
    ON public.album 
    (albumid ASC NULLS LAST)
	INCLUDE (title, artistid);

CREATE INDEX IF NOT EXISTS ifk_composer
    ON public.track 
    (composer ASC NULLS LAST)
    WHERE composer::text ~~* '%Brian%'::text OR composer::text ~~* '%Steven%'::text;

CREATE INDEX IF NOT EXISTS ifk_trackalbumid
    ON public.track 
    (albumid ASC NULLS LAST);
	
CREATE INDEX IF NOT EXISTS ifk_trackgenreid
    ON public.track 
    (genreid ASC NULLS LAST);

CREATE INDEX IF NOT EXISTS ifk_trackmediatypeid
    ON public.track 
    (mediatypeid ASC NULLS LAST);