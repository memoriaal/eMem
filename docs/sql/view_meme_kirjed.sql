CREATE OR REPLACE VIEW meme_kirjed AS
select k.emi_id, k.kirje as Memento, k.kivi, k.mittekivi, k.rel, k.mr, e.kirjed as EMI_kirjed, ifnull(e.EmiSurm,e.Surm) as EMI_surm
from kirjed k, EMIR e
where k.allikas = 'r86'
and k.emi_id = e.id
and k.nimekiri not in ('R9','R10','R11')
and k.kivi = ''
and k.mittekivi = ''
;