-------------------------SUBQUERIES---------------------------

select distinct
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
	case
		when t.composer like '%Angus%' then 'Y'
		else 'N'
		end as Angus_Young_flag,
		case
		WHEN t.composer like '%Steven%' then 'Y'
		ELSE 'N'
		END AS Steven_Young_flag,
		CASE
		WHEN t.composer LIKE '%Brian%' THEN 'Y'
		ELSE 'N'
		END AS Brian_Johnson_flag,
	t.unitprice,
	k.sales_quantity,
	(t.unitprice*k.sales_quantity) as sales,
	track_countt.track_count as track_in_album,
	cus.country AS country
FROM  track t
LEFT JOIN (SELECT DISTINCT albumid, title, artistid FROM album) a ON t.albumid = a.albumid
LEFT JOIN artist c ON a.artistid = c.artistid
LEFT JOIN (SELECT * FROM public.genre) g ON t.genreid = g.genreid
LEFT JOIN (SELECT trackid, SUM(quantity) AS sales_quantity FROM public.invoiceline GROUP BY trackid) k on k.trackid = t.trackid
LEFT JOIN
	(SELECT t.AlbumId, COUNT(t.trackid) AS track_count
     FROM track t
	 GROUP by t.AlbumId) as track_countt ON t.AlbumId = track_countt.AlbumId
LEFT JOIN (SELECT t.composer from track t) com ON t.composer LIKE '%Brian%' OR t.composer LIKE '%Steven%'
LEFT JOIN invoiceline i ON t.trackid = i.trackid 
LEFT JOIN invoice i2 ON i.invoiceid = i2.invoiceid 
LEFT JOIN customer cus ON i2.customerid = cus.customerid
WHERE cus.country = 'Canada'

union

select distinct
	tu.trackid,
	(case
		when tu.name = '' then 'unkown'
		when tu.name = '?' then 'unkown'
		when left(tu.name,1) = '0' then substring(tu.name,5,20)
		when tu.name = '.07%' then 'unkown'
		else upper (tu."name")
	end)as track_name,
	au.title as album_title,
	case
		when au.title like '%Rock%' then 'Y'
		else 'N'
		end as Biggest_album_flag,
	cu.name as artist_name,
	gu.name as music_type,
	(case
		when tu.composer = '' then 'unkown'
		else tu.composer
	end) as name_of_composer,
	case
		when tu.composer like '%Angus%' then 'Y'
		else 'N'
		end as Angus_Young_flag,
		case
		when tu.composer like '%Malcolm%' then 'Y'
		else 'N'
		end as Malcolm_Young_flag,
		case
		when tu.composer like '%Brian%' then 'Y'
		else 'N'
		end as Brian_Johnson_flag,
	tu.unitprice,
	ku.sales_quantity,
	(tu.unitprice*ku.sales_quantity) as sales,
	track_countt.track_count as track_in_album,
	cusu.country as country
from  track tu
left join (select distinct albumid, title, artistid from album) au on tu.albumid = au.albumid
left join artist cu on au.artistid = cu.artistid
left join (select * from public.genre) gu on tu.genreid = gu.genreid
left join (select trackid, sum(quantity) as sales_quantity from public.invoiceline group by trackid) ku on ku.trackid = tu.trackid
left join
	(SELECT tu.AlbumId, count(tu.trackid) as track_count
     FROM track tu
	 GROUP by tu.AlbumId) as track_countt on tu.AlbumId = track_countt.AlbumId
left join (select tu.composer from track tu) comu on tu.composer ilike '%Brian%' or tu.composer ilike '%Steven%' 
left join invoiceline iu on tu.trackid = iu.trackid 
left join invoice i2u on iu.invoiceid = i2u.invoiceid 
left join customer cusu on i2u.customerid = cusu.customerid
where cusu.country = 'Finland' 
order by trackid 	


-------------------------CTE---------------------------
WITH
    album_narrow
    AS
    (
        SELECT DISTINCT
            albumid, title, artistid
        FROM album
    ),
    genre_narrow
    AS
    (
        SELECT
            genreid, "name"
        FROM public.genre
    ),
    invoiceline_narrow
    AS
    (
        SELECT
            trackid, sum(quantity) as sales_quantity
        FROM public.invoiceline
        GROUP BY trackid
    ),
	composer_narrow
	AS
	(
		SELECT t.composer 
		FROM track t
	),
    track_narrow
    AS
    (
        SELECT t.AlbumId, count(t.trackid) as track_count
        FROM track t
        GROUP BY t.AlbumId
    ),
    canada
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
        end as Multiple_composer,
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
			left join composer_narrow com on t.composer ilike '%Brian%' or t.composer ilike '%Steven%'			
			left join invoiceline i on t.trackid = i.trackid 
			left join invoice i2 on i.invoiceid = i2.invoiceid 
			left join customer cus on i2.customerid = cus.customerid
		where cus.country = 'Canada'
        group by t.trackid, a.title, c.name, g.name, k.sales_quantity, track_countt.track_count, t.name,t.composer,
		t.milliseconds,t.unitprice, cus.country
        order by t.trackid
    ),
    finland
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
        end as Multiple_composer,
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
			left join composer_narrow com on t.composer ilike '%Brian%' or t.composer ilike '%Steven%'			
			left join invoiceline i on t.trackid = i.trackid 
			left join invoice i2 on i.invoiceid = i2.invoiceid 
			left join customer cus on i2.customerid = cus.customerid
		where cus.country = 'Finland'
        group by t.trackid, a.title, c.name, g.name, k.sales_quantity, track_countt.track_count, t.name,t.composer,
		t.milliseconds,t.unitprice, cus.country
        order by t.trackid
    )
select
    *
from canada
union
select
    *
from finland;


-------------------------TEMP-TABLES---------------------------
DROP TABLE IF EXISTS album_narrow;
DROP TABLE IF EXISTS genre_narrow;
DROP TABLE IF EXISTS invoiceline_narrow;
DROP TABLE IF EXISTS composer_narrow;
DROP TABLE IF EXISTS track_narrow;
DROP TABLE IF EXISTS canada;
DROP TABLE IF EXISTS finland;
DROP TABLE IF EXISTS final_report;

	SELECT DISTINCT
		albumid, title, artistid
	INTO TEMPORARY TABLE album_narrow
	FROM album;
		

	SELECT
		genreid, "name"
	INTO TEMPORARY TABLE genre_narrow
	FROM public.genre;
	
	
	SELECT
		trackid, sum(quantity) as sales_quantity
	INTO TEMPORARY TABLE invoiceline_narrow
	FROM public.invoiceline
	GROUP BY trackid;
	
	
	SELECT 
		t.composer 
	INTO TEMPORARY TABLE composer_narrow
	FROM track t;
	
	
	SELECT 
		t.AlbumId, count(t.trackid) as track_count
	INTO TEMPORARY TABLE track_narrow
	FROM track t
	GROUP by t.AlbumId;


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
	end as Multiple_composer,
		CONCAT(t.milliseconds, ' ms') as time_in_mills,
		CONCAT(ROUND(t.milliseconds*0.001, 1) , ' s')as time_in_sec,
		CONCAT(ROUND(t.milliseconds*0.001/60, 1) , ' min')as time_in_min,
		t.unitprice,
		k.sales_quantity,
		(t.unitprice*k.sales_quantity) as sales,
		track_countt.track_count as track_in_album,
		cus.country as 	Country
	INTO TEMPORARY TABLE canada
	from track t
		left join album_narrow a on t.albumid = a.albumid
		left join artist c on a.artistid = c.artistid
		left join genre_narrow g on t.genreid = g.genreid
		left join invoiceline_narrow k on k.trackid = t.trackid
		left join track_narrow track_countt on t.AlbumId = track_countt.AlbumId
		left join composer_narrow com on t.composer ilike '%Brian%' or t.composer ilike '%Steven%'			
		left join invoiceline i on t.trackid = i.trackid 
		left join invoice i2 on i.invoiceid = i2.invoiceid 
		left join customer cus on i2.customerid = cus.customerid
	where cus.country = 'Canada'
	group by t.trackid, a.title, c.name, g.name, k.sales_quantity, track_countt.track_count, t.name,t.composer,
	t.milliseconds,t.unitprice, cus.country
	order by t.trackid;


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
	end as Multiple_composer,
		CONCAT(t.milliseconds, ' ms') as time_in_mills,
		CONCAT(ROUND(t.milliseconds*0.001, 1) , ' s')as time_in_sec,
		CONCAT(ROUND(t.milliseconds*0.001/60, 1) , ' min')as time_in_min,
		t.unitprice,
		k.sales_quantity,
		(t.unitprice*k.sales_quantity) as sales,
		track_countt.track_count as track_in_album,
		cus.country as 	Country
	INTO TEMPORARY TABLE finland
	from track t
		left join album_narrow a on t.albumid = a.albumid
		left join artist c on a.artistid = c.artistid
		left join genre_narrow g on t.genreid = g.genreid
		left join invoiceline_narrow k on k.trackid = t.trackid
		left join track_narrow track_countt on t.AlbumId = track_countt.AlbumId
		left join composer_narrow com on t.composer ilike '%Brian%' or t.composer ilike '%Steven%'			
		left join invoiceline i on t.trackid = i.trackid 
		left join invoice i2 on i.invoiceid = i2.invoiceid 
		left join customer cus on i2.customerid = cus.customerid
	where cus.country = 'Finland'
	group by t.trackid, a.title, c.name, g.name, k.sales_quantity, track_countt.track_count, t.name,t.composer,
	t.milliseconds,t.unitprice, cus.country
	order by t.trackid;


	select
	*
	INTO TEMPORARY TABLE final_report
	from canada
	union
	select
	*
	from finland;
	
	select 
	* 
	from final_report;
	
DROP TABLE IF EXISTS album_narrow;
DROP TABLE IF EXISTS genre_narrow;
DROP TABLE IF EXISTS invoiceline_narrow;
DROP TABLE IF EXISTS composer_narrow;
DROP TABLE IF EXISTS canada;
DROP TABLE IF EXISTS finland;
DROP TABLE IF EXISTS final_report;





