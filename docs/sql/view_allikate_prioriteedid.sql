create or replace view v_prioriteedid as
select kood, prioriteet 
from allikad 
group by kood 
order by prioriteet desc;
