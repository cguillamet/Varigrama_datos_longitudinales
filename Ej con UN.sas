PROC IML;

   N=25;  * CANTIDAD DE INDIVIDUOS;	
   M=4;   * OCASIONES DE MEDICIÓN;

   /* Parámetros para errores */
   MEDIA=REPEAT(0,1,M);
   R={2.9 2.5 0.9 2.8, 2.5 4.4 3.4 4.8, 0.9 3.4 7.4 2.6, 2.8 4.8 2.6 10.5}; 

      /* GENERACIÓN DE LOS ERRORES */
   CALL VNORMAL(E,MEDIA,R,N);

   Y=REPEAT(0,N,4); * PARA GUARDAR LOS VALORES DE LA RTA;
   T={1 2 3 4};    * TIEMPO;
  
   * EFECTOS FIJOS;
   B0=5;
   B1=2.5;

      /* GENERACIÓN DE LOS DATOS */
   DO A1=1 TO N;
      DO A2=1 TO 4; 
         Y[A1,A2]=B0+B1*T[A2]+E[A1,A2];
       END;
   END; 

   id=T(1:n);
   datos=id||y;
   
   VARNAME={ID t1 t2 t3 t4};
   CREATE Datos FROM DATOS[COLNAME=VARNAME];
   APPEND FROM DATOS;
QUIT;

data datos2 ; set datos;
  array wt(4) t1 t2 t3 t4;
  do t = 1 to 4;
     y = wt(t);
     output;
  end;
  drop t1 t2 t3 t4;
run;

proc export data=work.datos2
outfile="F:\Tesis\SAS\Programas (27-07)\un.cvs"
dbms=csv replace;
run;

proc glm data=datos2;
  model y=t / solution;
  output out=residuos r=resid;
quit;


/*Càlculo del variograma*/
proc variogram data=residuos outpair=out;
coordinates xc=t yc=id;
compute robust novariogram;
var resid;
run;

data variogram; set out;
	if y1=y2; vario=(v1-v2)**2/2; run;
data variance; set out;
	if y1<y2; vario=(v1-v2)**2/2; run;


/*calculo de la variancia total*/
proc means data=variance mean;
var vario;
run;

/*suavizado loess del variograma*/
proc loess data=variogram;
ods output scoreresults=out;
model vario=distance;
score data=variogram;
run;

proc sort data=out; by distance; run;

filename fig1 "E:\Tesis\file.jpg";
goptions reset=all ftext=swiss device=jpeg gsfname=fig1 
gsfmode=replace rotate=landscape; 
proc gplot data=out; 
plot vario*distance=1 p_vario*distance=2
	/ overlay haxis=axis1 vaxis=axis2 vref=5.2745 lvref=7; 
symbol1 c=red v=dot h=0.2 mode=include;
symbol2 c=black i=join w=2 mode=include; 
axis1  label=(h=2 "Intervalo de tiempo") value=(h=1.5) 	
	order=(0 to 4 by 1) minor=none; 
axis2  label=(h=2 A=90 "Variograma") value=(h=1.5) 
	order=(0 to 40 by 2) minor=none; 
title h=2 "Variograma muestral";
run;quit;

