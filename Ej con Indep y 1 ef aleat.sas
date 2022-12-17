* EJEMPLO con indep con 1 EA;

PROC IML;

   N=25;  * CANTIDAD DE INDIVIDUOS;	
   M=4;   * OCASIONES DE MEDICIÓN;

   /* Parámetros para errores */
   MEDIA=REPEAT(0,1,M);
   sigma2=0.6;
   R=sigma2*{1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1};

   /* Parámetros para ef aleatorio */
   MEDIA_EA=0; /* EF ALEATOR IO EN INTERCEPTO*/
   D=2;

      /* GENERACIÓN DE LOS ERRORES */
   CALL VNORMAL(E,MEDIA,R,N);

	  /* GENERACIÓN DE LOS EFECTOS ALEATORIOS */
   b=sqrt(d)*normal(repeat(0,N,1));
   print b;
   *CALL VNORMAL(B,MEDIA_EA,D,N); 

   Y=REPEAT(0,N,4); * PARA GUARDAR LOS VALORES DE LA RTA;
   T={1 2 3 4};    * TIEMPO;
  
   * EFECTOS FIJOS;
   B0=5;
   B1=2.5;

      /* GENERACIÓN DE LOS DATOS */
   DO A1=1 TO N;
      DO A2=1 TO 4; 
         Y[A1,A2]=(B0+b[a1,1])+(B1)*T[A2]+E[A1,A2];
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
outfile="F:\Tesis\SAS\Programas (27-07)\indep1.cvs"
dbms=csv replace;
run;

proc glm data=datos2;
  model y=t / solution;
  output out=residuos r=resid;
quit;

/*Càlculo del variograma*/
proc variogram data=rescond outpair=out;
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
	/ overlay haxis=axis1 vaxis=axis2 vref=2.787; 
symbol1 c=red v=dot h=0.2 mode=include;
symbol2 c=black i=join w=2 mode=include; 
axis1  label=(h=2 "Intervalo de tiempo") value=(h=1.5) 	
	order=(0 to 4 by 1) minor=none; 
axis2  label=(h=2 A=90 "Variograma") value=(h=1.5) 
	order=(0 to 5 by 0.5) minor=none; 
title h=2 "Variograma muestral";
run;quit;




