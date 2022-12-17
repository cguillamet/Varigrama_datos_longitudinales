* EJEMPLO con sc y ro=0,9 sin EA;

PROC IML;

   N=25;* CANTIDAD DE INDIVIDUOS;	
   M=4;   * OCASIONES DE MEDICIÓN;
   MEDIA=REPEAT(0,1,M);
   R={0.6 0.54 0.54 0.54, 0.54 0.6 0.54 0.54, 0.54 0.54 0.6 0.54, 0.54 0.54 0.54 0.6};

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
         Y[A1,A2]=(B0)+(B1)*T[A2]+E[A1,A2];
       END;
   END; 

   * REACOMODO LOS DATOS PARA CREAR EL DATA SET;
   DO U=1 TO N;
   RTA=RTA//T(Y[U,]);
   TPO=TPO//T(T);
   END; 

   IDENT=T(1:N);
   ID=IDENT@REPEAT(1,4,1);

   * CREACIÓN DEL DATA SET;
   DATOS=ID||TPO||RTA;
   VARNAME={ID TPO Y};
   CREATE DATOS FROM DATOS[COLNAME=VARNAME];
   APPEND FROM DATOS;
QUIT;

proc print data=datos;
run;

proc export data=work.datos
outfile="F:\Tesis\SAS\Programas (27-07)\sc.cvs"
dbms=csv replace;
run;

*Ajuste del modelo*;

proc mixed method=ml data=datos;
  class id ;
  model y = tpo / solution outp=rescond outpm=resmarg;
run;


/*Càlculo del variograma*/
proc variogram data=rescond outpair=out;
coordinates xc=tpo yc=id;
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
	/ overlay haxis=axis1 vaxis=axis2 vref=0.5118 lvref=7; 
symbol1 c=red v=dot h=0.2 mode=include;
symbol2 c=black i=join w=2 mode=include; 
axis1  label=(h=2 "Intervalo de tiempo") value=(h=1.5) 	
	order=(0 to 4 by 1) minor=none; 
axis2  label=(h=2 A=90 "Variograma") value=(h=1.5) 
	order=(0 to 1 by 0.2) minor=none; 
title h=2 "Variograma muestral";
run;quit;

