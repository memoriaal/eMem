create or replace view v_prioriteedid as
select kood, prioriteetPerenimi, prioriteetEesnimi, prioriteetIsanimi, prioriteetSünd, prioriteetSurm, prioriteetKirje
from allikad 
group by kood 
order by prioriteetPerenimi, prioriteetEesnimi, prioriteetIsanimi, prioriteetSünd, prioriteetSurm, prioriteetKirje;
