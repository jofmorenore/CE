/*
Los conjuntos de datos delimitados por tabulaciones en los archivos 
covid2020.tsv y covid2021.tsv contienen información diaria (date) y por paí́s (iso code) 
sobre el número de nuevos casos (new cases), el número acumulado de casos (total cases), 
el número de nuevas muertes (new deaths), y el número acumulado de muertes (total deaths) 
por Covid-19 en 2020 y 2021, respectivamente. El conjunto de datos delimitado por 
tabulaciones en el archivo pop.tsv contiene información por continente (continent) y 
por paí́s (iso code y location) de la población (population). 
Use estos conjuntos de datos y SAS Studio para responder las siguientes preguntas:
*/

proc import datafile='/home/u40904561/covid2020.tsv' dbms=tab out=covid2020 replace; 
	getnames=yes;
	delimiter="09"x;
run;

proc contents data=covid2020 varnum;
run;

proc import datafile='/home/u40904561/covid2021.tsv' dbms=tab out=covid2021 replace; 
	getnames=yes;
	delimiter="09"x;
run;

data covid;
  set covid2020 covid2021;
run;

proc import datafile='/home/u40904561/pop.tsv' dbms=tab out=pop replace; 
	getnames=yes;
	delimiter="09"x;
run;

data pop;
  infile   '/home/u40904561/pop.tsv' dsd delimiter="09"x firstobs=2;
  informat iso_code $5. continent location $20.;
  input    iso_code continent location populaton;
run;

proc sql;
create table covid3 as
select covid.*, continent, location, populaton
from covid left join pop on (covid.iso_code=pop.iso_code);
quit;

proc freq data=work.covid3 order =freq;
table continent;
run;

/***********************************************************************
***** Punto 1
************************************************************************/

    /* Rta: Perú | 78 días sin casos
    (A) Cuál fue el paı́s (iso code y location) de América del Sur con el mayor número de
    dí́as, consecutivos o no, sin nuevos casos de Covid-19 entre el 1 de junio de 2020 y el 31
    de mayo de 2021?
    */
proc sql outobs=1;
	select location, count(*) as dias_sin_casos   
	from covid left join pop on (covid.iso_code=pop.iso_code)
	where continent= 'South America' and (Date >= '01JUN2020'd and Date <='31MAY2021'd) and new_cases=0
	group by location
	order by dias_sin_casos desc;
quit;	
	
    /* Rta: 23/07/2021 | 8 países
    (B) Cuál fue el día (date) de 2021 con mayor número de paises de América del Sur sin
    nuevos casos de Covid-19?
    */
proc sql outobs=1;
	select Date, count(distinct iso_code) as num_paises
	from covid left join pop on (covid.iso_code=pop.iso_code)
	where new_cases=0 and Date >= '01JAN2021'd and continent='South America'
	group by Date
	order by num_paises desc;
quit;

proc freq data=work.covid3 order =freq;
table Date /nopercent nocum maxlevels=3;
where new_cases=0 and continent = 'South America' and Date >= '01JAN2021'd;
run;

proc means data=covid3 n nonobs;
class date / order=freq;
var   new_cases;
where continent="South America" and new_cases=0 and
      date >= '01JAN2021'd;
run;
	
    /* Rta: Tanzania | 364 días
    (C) Cuál fue el paí́s (iso code y location) de Africa con el mayor número de dı́as, 
    consecutivos o no, sin nuevas muertes por Covid-19 entre el 1 de mayo de 2020 y el 30 de
    abril de 2021?
    */
proc sql outobs=1;
	select iso_code, location count(distinct Date) as num_dias
	from covid left join pop on (covid.iso_code=pop.iso_code)
	where continent='Africa' and new_deaths=0 and (Date >= '01MAY2020'd and Date <= '30APR2021'd)
	group by iso_code, location
	order by num_dias desc;	
quit; 

    /* Rta: 21/04/2020	| 46 países
    (D) Cuál fue el día (date) de 2020 con mayor número de paises de Africa sin nuevas muertes
    por Covid-19?
    */
proc sql outobs=1;
	select Date, count(distinct location) as num_paises
	from covid left join pop on (covid.iso_code=pop.iso_code)
	where continent='Africa' and new_deaths=0 and Date < '01JAN2021'd
	group by Date
	order by num_paises desc;
quit;   

/***********************************************************************
***** Punto 2
************************************************************************/

    /* Rta: CZE	Czechia	| 8906.057 casos por 100 mil habitantes
    (A) Cual fue el paí́s (iso code y location) de Europa con el mayor número de casos de
    Covid-19 por 100 mil habitantes (100000×casos/poblacion) durante 2021? 
    */
proc sql outobs=3;
	select iso_code, location, 100000*sum(new_cases)/mean(populaton) as casosx100milhab
	from covid3
	where continent='Europe' and Date >= '01JAN2021'd
	group by iso_code, location
	order by casosx100milhab desc;
quit;
    /* Rta: AUS	Australia | 111.4711
    (B) Cual fue el paı́s (iso code y location) de Oceania con el mayor número de casos de 
    Covid-19 por 100 mil habitantes durante 2020? 
    */
proc sql;
	select iso_code, location, 100000*sum(new_cases)/mean(populaton) as casosx100milhab
	from covid3
	where continent='Oceania' and Date < '01JAN2021'd
	group by iso_code, location
	order by casosx100milhab desc;
quit;   
    /* Rta: Oceania	| 171.1056 %
    (C) Cual fue el continente (continent) menos homogeneo, de acuerdo al coeficiente de 
    variación, con respecto al número de casos de Covid-19 por 100 mil habitantes durante
    2020 en los paı́ses que lo integran? 
    */
proc sql;
	create table paises_casosx1000milhab as
	select iso_code, location, continent, 100000*sum(new_cases)/mean(populaton) as casosx100milhab
	from covid3
	where Date < '01JAN2021'd
	group by iso_code, location, continent
	order by continent;
quit;   

proc sql;
	select continent, cv(casosx100milhab) as cvar, sqrt(var(casosx100milhab))/mean(casosx100milhab) as cvar2
	from paises_casosx1000milhab 
	group by continent
	order by cvar desc;
quit;

    /* Rta: Europe	| 50.60165%
    (D) Cual fue el continente (continent) más homogeneo, de acuerdo al coeficiente de 
    variación, con respecto al número de casos de Covid-19 por 100 mil habitantes durante 2021
    en los paı́ses que lo integran? 
    */
proc sql;
	create table paises2021_casosx1000milhab as
	select iso_code, location, continent, 100000*sum(new_cases)/mean(populaton) as casosx100milhab
	from covid3
	where Date >= '01JAN2021'd
	group by iso_code, location, continent
	order by continent;
quit;   

proc sql;
	select continent, cv(casosx100milhab) as cvar, sqrt(var(casosx100milhab))/mean(casosx100milhab) as cvar2
	from paises2021_casosx1000milhab 
	group by continent
	order by cvar;
quit;

/***********************************************************************
***** Punto 3
************************************************************************/

    /* Rta: PER	Peru | 01/01/2020 - 05/03/2020 | 0 | 65 días consecutivos
    (A) Cual fue el paı́s (iso code y location) de América del Sur con el mayor número de días
    consecutivos sin nuevos casos de Covid-19 en 2020?
    */
proc sql;
	select iso_code, location, Date, total_cases, count(*) as consecutivos
	from covid3
	where continent='South America' and Date < '01JAN2021'd
	group by iso_code, location, total_cases
	order by consecutivos desc, Date;
quit;    

    /* Rta: LAO	Laos | 12/04/2020 - 23/07/2020 | 19 | 103 días consecutivos      
    (B) Cual fue el paı́s (iso code y location) 
    de Asia con el mayor número de días consecutivos sin nuevos casos de Covid-19 en 2020? 
    */
proc sql;
	select iso_code, location, Date, total_cases, count(*) as consecutivos
	from covid3
	where continent='Asia' and Date < '01JAN2021'd
	group by iso_code, location, total_cases
	order by consecutivos desc, Date;
quit;    
    
    /* Rta: DMA	Dominica | 01/01/2021 - 25/07/2021 | 0 | 206 días consecutivos
    (C) Cual fue el paı́s (iso code y location) de América del Norte con el mayor número de
    días consecutivos sin nuevas muertes por Covid-19 en 2021? 
    */
proc sql;
	select iso_code, location, Date, total_deaths, count(*) as consecutivos
	from covid3
	where continent='North America' and Date >= '01JAN2021'd
	group by iso_code, location, total_deaths
	order by consecutivos desc, Date;
quit; 

    /* Rta: BRN	Brunei | 01/01/2021 - 25/07/2021 | 3 | 206
    (D) Cual fue el paı́s (iso code y location) de Asia con el mayor número de días consecutivos
    sin nuevas muertes por Covid-19 en 2021? 
    */
proc sql;
	select iso_code, location, Date, total_deaths, count(*) as consecutivos
	from covid3
	where continent='Asia' and Date >= '01JAN2021'd
	group by iso_code, location, total_deaths
	order by consecutivos desc, Date;
quit; 
