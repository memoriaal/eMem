# Tehnoloogilised piirangud memoriaal.ee veebiportaalile

## Lähtekood
  Lähtekood on avalik ja publitseeritud https://github.com/memoriaal
repositooriumis

## CI
  Taaskäivitamisel laeb rakendus versiooni uuenemisel repositooriumist värske
lähtekoodi.

## Dokumentatsioon
  Repositooriumi README faili juhtnööride järgi on võimalik igal soovijal see
rakendus oma soovitud masinasse paigaldada.
  Andmebaasi kirjeldus asub eraldi konfiguratsioonifailis.

## Mobile first
  Responsive layout, millel peab olema kujundatud ka desktop ja print vaated.

## Andmed ja internetisõltuvus
  Lisaks staatilisele infole on lehel ka otsitav isikute register u. 100 000
struktureeritud, omavahel seotud kirjega.
  Vajalikud kirjed peavad olema kohapeale sünkroniseeritud, et kodulehet poleks
sõltuvuses interneti olemasolust. Soovitav on kohalik read-only slave andmebaas,
mis ühenduse olemasolul end masteriga sünkroniseerib. Andmete uuenemine toimub
eeldatavasti iga päev.

## Ei
  Välistatud on kõikvõimalikud Joomla, Drupali ja WordPressi laadsed
raskekaallased.
