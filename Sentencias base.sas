/********PARA SACAR LOS INDIVIDUOS CON UNA UNICA OBSERVACION********/

proc sort data=creatinina; 
by ndo; 
run; 
*NOTA: There were 19879 observations read from the data set WORK.CREATININA.
*NOTA: The data set WORK.CREATININA has 19879 observations and 17 variables;

proc sort data=creat1; 
by ndo; 
run; 
*NOTA: There were 8369 observations read from the data set WORK.CREAT1.
*NOTA: The data set WORK.CREAT1 has 8369 observations and 2 variables;

/*para poder juntar deben estar ordenadas las bases y no haber observaciones duplicados*/
data creatinina01; 
merge creatinina (in=x) creat1 (in=y); 
by ndo;
if x and not y; /*me quedo solo con las solicitudes x y no las que estan en y*/
run;
*NOTA: There were 19879 observations read from the data set WORK.CREATININA.
*NOTA: There were 8369 observations read from the data set WORK.CREAT1.
*NOTA: The data set WORK.CREATININA01 has 11510 observations and 17 variables;


/********SOLO INDIVIDUOS CON OBSERVACION MINIMA MENOR A 60********/

proc sort data=creatinina01; 
by ndo; 
run; 
proc sort data=creat60; 
by ndo; 
run; 


/*para poder juntar deben estar ordenadas las bases y no haber observaciones duplicados*/
data creatinina02; 
merge creatinina01 (in=x) creat60 (in=y); 
by ndo;
if x and y; /*me quedo solo con las solicitudes x y no las que estan en y*/
run;
*NOTA: There were 11510 observations read from the data set WORK.CREATININA01.
*NOTA: There were 4289 observations read from the data set WORK.CREAT60.
*NOTA: The data set WORK.CREATININA02 has 7396 observations and 18 variables.;


/********SOLO INDIVIDUOS CON MAS DE 3 OBSERVACIONES********/

proc sort data=creatinina; 
by ndo; 
run; 
proc sort data=creat4; 
by ndo; 
run; 


/*para poder juntar deben estar ordenadas las bases y no haber observaciones duplicados*/
data creatinina4; 
merge creatinina (in=x) creat4 (in=y); 
by ndo;
if x and y; /*me quedo solo con las solicitudes x y no las que estan en y*/
run;
*NOTA: There were 7396 observations read from the data set WORK.CREATININA.
*NOTA: There were 706 observations read from the data set WORK.CREAT4.
*NOTA: The data set WORK.CREATININA4 has 4220 observations and 14 variables;



data creatinina01;
set creatinina;
if primer_consulta=fecha then tiempo_dias=0;
run;

data creatinina02;
set creatinina01;
if primer_consulta=fecha then tiempo_meses=0;
run;



*****************CREACION VARIABLE TIEMPO*****************;


data creatinina;
set creatinina;
dias=0;
run;

proc sort data=creatinina;
by ndo fecha;
run;

proc iml;
use creatinina;
read all var{ndo} into ndo;
read all var{fecha} into fecha;
read all var{primer_consulta} into pcon;
read all var{dias} into dias;
close creatinina;
datos=ndo||fecha||pcon||dias;
m=4220;
do i=1 to (m-1);
		if Datos[(i+1),1]=Datos[i,1] then Datos[(i+1),4]=Datos[(i+1),2]-Datos[i,3];
end;
name={"ndo" "fecha" "primer consulta" "dias"};
create datos from datos[colname=name];
append from datos;
quit;
