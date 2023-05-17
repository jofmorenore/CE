/*
El conjunto de datos en el archivo ofrecidos.xlsx contiene información sobre
los cursos ofrecidos por el departamento de Estadı́stica durante varios semestres
(Semestre: “2014-I”, “2014-II”, “2015-I”, “2015-II”, “2016-I” y “2016-II”),
incluyendo el código del curso (CodigoCurso), número de grupo (GrupoN), 
número de cupos (CuposN), programa al que pertenece el curso (Programa: “Pregrado”,
“Especialización”, “Maestrı́a”, “Doctorado”, “Otros pregrados”), 
agrupación a la que pertenece el curso (Agrupacion: “Fundamentación”, “Núcleo”, 
“Metodologia”, “Aplicación”, “Complementación” y “Consolidación” para el pregrado 
en Estadı́stica y vacio para los demás programas), identificador del(a) profesor(a)
a cargo (IdDocente para los profesores de planta del departamento de Estadı́stica y
 vacio para los demás), ası́ como el(los) dı́a(s) (Dia), horario (Horario) y salón
(Salon) en que se dictó el curso. 

El conjunto de datos en el archivo cursos.txt (separado por “;”) contiene un
listado con los códigos (CodigoCurso) y el nombre (NombreCurso) de los cursos. 

Finalmente, el conjunto de datos en el archivo docentes.csv (separado por “,”)
contiene un listado con el identificador (IdDocente), nombre (NombreDocente) y 
correo electrónico (Correo Electronico) de los docentes de planta del 
departamento de Estadı́stica. Use estos conjuntos de datos y SAS Studio 
para responder las siguientes preguntas:
*/

proc import out=cursos dbms=tab datafile="/home/u40904561/Curso/cursos.txt" replace;
  getnames=yes;
  delimiter=";";
run;

proc contents data=cursos varnum;
run;

proc print data=cursos (obs=20) noobs;
run;

proc import out=docentes dbms=csv datafile="/home/u40904561/Curso/docentes.csv" replace;
  getnames=yes;
  delimiter=",";
run;

proc contents data=docentes varnum;
run;

proc print data=docentes (obs=20) noobs;
run;

proc import out=ofrecidos dbms=xlsx datafile="/home/u40904561/Curso/ofrecidos.xlsx" replace;
  getnames=yes;
run;

proc contents data=ofrecidos varnum;
run;

proc print data=ofrecidos (obs=20) noobs;
run;

proc sql;
	create table ofrecidos2 as
	select ofrecidos.*, nombrecurso
	from ofrecidos left join cursos on (ofrecidos.codigocurso=cursos.codigocurso);

	create table ofrecidos3 as
    select ofrecidos2.*, nombredocente
    from ofrecidos2 left join docentes on (ofrecidos2.iddocente=docentes.iddocente);
quit;

proc contents data=ofrecidos3 varnum;
run;

	/* Rta: 2014-II	| Bioestadística Fundamental | 16 grupos
	(A) En cual semestre del periodo comprendido entre 2014-I y 2016-II hubo 
	más grupos de “Bioestadı́stica Fundamental”? 
	*/

proc freq data=work.ofrecidos3 order =freq;
table nombrecurso;
run;

proc sql;
	select Semestre, nombrecurso, count(distinct GrupoN) as n_grupos
	from ofrecidos3
	where nombrecurso='Bioestadística Fundamental'
	group by Semestre, nombrecurso
	order by n_grupos desc;	
quit;

	/* Rta: 2015-II	| Probabilidad y Estadística Fundamental | 1168 cupos
	(B) En cual semestre del periodo comprendido entre 2014-I y 2016-II hubo 
	más cupos de “Probabilidad y Estadı́stica Fundamental”? 
	*/
proc sql;
	select Semestre, nombrecurso, sum(CuposN) as n_cupos
	from ofrecidos3
	where nombrecurso='Probabilidad y Estadística Fundamental'
	group by Semestre, nombrecurso
	order by n_cupos desc;	
quit;

	/* Rta: 2016-I	| Estadística Social Fundamental | 18.80815 %
	(C) En cual semestre del periodo comprendido entre 2014-I y 2016-II hubo 
	mayor homogeneidad (de acuerdo al coeficiente de variación) entre los grupos 
	de “Estadı́stica Social Fundamental” en relación al número de cupos ofrecidos? 
	*/
proc sql; 
	select Semestre, nombrecurso, cv(CuposN) as cvar
	from ofrecidos3
	where nombrecurso='Estadística Social Fundamental'
	group by Semestre, nombrecurso
	order by cvar;
quit;

	/* Rta: 2016321	Finanzas y Modelos de Inversión		| 	1
			2016332	Teoría Estadística del Riesgo		| 	1
			2016334	Análisis de Datos Longitudinales	| 	1
			2016340	Series de Tiempo Multivariadas		| 	1
	(D) Cuales cursos del pregrado en Estadı́stica (código y nombre) se abrieron 
	solo un semestre en el periodo comprendido entre 2014-I y 2016-II? 
	*/
proc sql;
	select codigocurso, nombrecurso, count(distinct semestre) as n_semestres
	from ofrecidos3
	where Programa = 'Pregrado'
	group by codigocurso, nombrecurso
	having n_semestres=1;
quit;

	/* Rta: 2015178	Probabilidad							| 	6
			2016360	Análisis de Regresión					| 	6
			2016366	Estadística Descriptiva y Exploratoria	| 	6
	(E) Cuales cursos del pregrado en Estadı́stica (código y nombre) se abrieron 
	todos los semestres en el periodo comprendido entre 2014-I y 2016-II? 
	*/
proc sql;
	select codigocurso, nombrecurso, count(distinct semestre) as n_semestres
	from ofrecidos3
	where Programa = 'Pregrado'
	group by codigocurso, nombrecurso
	having n_semestres=6;
quit;

	/* Rta: 32710817	Mayo Luz Polo Gonzalez		|	1
			35324340	Nelcy Rodriguez Malagon		|	1
			52866185	Diana Carolina Franco Soto	|	1
			65734135	Sandra Vergara Cardozo		|	1
			79550569	Carlos Arturo Panza Ospino	|	1
	(F) Cuales profesores(as) (identificador y nombre) dictaron en solo uno de 
	los programas del departamento de Estadı́stica (Pregrado, Especialización, 
	Maestrı́a y Doctorado) en el periodo comprendido entre 2014-I y 2016-II? 
	*/
proc freq data=work.ofrecidos3 order =freq;
table programa;
run;	
	
proc sql;
	select IdDocente, nombredocente, count(distinct programa) as n_programas
	from ofrecidos3
	where programa NE 'Otros pregrados' and IdDocente is not NULL
	group by IdDocente, nombredocente
	having n_programas=1; 
quit;
	/* Rta: 19258429	Jose Alberto Vargas Navas		| 4
			79386588	Ruben Dario Guevara Gonzalez	| 4
			79560032	Carlos Eduardo Alonso Malaver	| 4
			79640675	Leonardo Trujillo Oyola			| 4
	(G) Cuales profesores(as) (identificador y nombre) dictaron en todos los 
	programas del departamento de Estadı́stica (Pregrado, Especialización, 
	Maestrı́a y Doctorado) en el periodo comprendido entre 2014-I y 2016-II?
	*/
proc sql;
	select IdDocente, nombredocente, count(distinct programa) as n_programas
	from ofrecidos3
	where programa NE 'Otros pregrados' and IdDocente is not NULL
	group by IdDocente, nombredocente
	having n_programas=4; 
quit;

	/* Rta: 32710817	Mayo Luz Polo Gonzalez	| 1
			65734135	Sandra Vergara Cardozo	| 1 	 
	(H) Cual(es) es(son) el(los) profesor(es) con el menor número de cursos 
	diferentes en los programas del departamento de Estadı́stica (Pregrado, 
	Especialización, Maestrı́a y Doctorado) en el periodo de tiempo comprendido 
	entre 2014-I y 2016-II? 
	*/
proc sql outobs = 2;
	select IdDocente, nombredocente, count(distinct codigocurso) as n_cursos
	from ofrecidos3
	where Programa in ('Pregrado','Especialización','Maestría','Doctorado')
	group by IdDocente, nombredocente
	order by n_cursos; 
quit;

	/* Nucleo
	(I) Cuales de las agrupaciones del pregrado en Estadı́stica (nombre) han 
	tenido número de cursos y número de cupos mayores al 35 % del total que 
	se ofrecieron en todos los semestres comprendidos entre 2014-I y 2016-II? 
	*/
proc freq data=work.ofrecidos3 order =freq;
table agrupacion;
run;

proc freq data=ofrecidos3;
	table Agrupacion*Semestre/ norow nopercent;
	where Programa="Pregrado";
run;

proc freq data=ofrecidos3;
	table Agrupacion*Semestre/ norow nopercent;
	weight CuposN;
	where Programa="Pregrado";
run;

proc sgplot data=ofrecidos3 pctlevel=group;
  hbar Semestre /  group=Agrupacion stat=pct groupdisplay=cluster;
  refline 0.35 / axis=x;
  where Programa="Pregrado";
run;
proc sgplot data=ofrecidos3 pctlevel=group;
  hbar Semestre / group=Agrupacion response=CuposN stat=pct groupdisplay=cluster;
  refline 0.35 / axis=x;
  where Programa="Pregrado";
run;

	/*		  lunes: 	NO		SI
		Rta: 2014-I	| 340	 |	181 	| 	521
					| 65.26  | 34.74	|

	(J) En cual de los semestres comprendidos entre 2014-I y 2016-II se tuvo 
	el mayor porcentaje de cupos ofrecidos en cursos con clases los lunes 
	(y por lo tanto perjudicados por los feriados) del total de cupos ofrecidos 
	en los programas de posgrado (Especialización, Maestrı́a y Doctorado)? 
	*/
data ofrecidos3;
set ofrecidos3;
  if substrn(Dia,1,2)="LU" then Lunes="Si";
  else Lunes="No";
run;	
	
proc freq data=ofrecidos3;
	table  Semestre*Lunes / nocol nopercent;
	weight CuposN;
	where Programa in ("Especialización","Maestría","Doctorado");
run;
