*********************************DIAS**********************************;


/*Grafico de perfiles individuales*/
proc gplot data=creatinina	;
plot rdo*tiempo__dias_/ vaxis=axis1 haxis=axis2;
symbol v=diamond interpol=none;
axis1 label = (angle=90 'Rdo') major=(height=2) minor=(height=1)width=3;
axis2 label =('tiempo en dias'); 
title 'Grafico de perfiles individuales';
run; 


/*Loess*/
proc loess data=creatinina; 
      model rdo=tiempo__dias_/select=AICC( global range(0.2,0.8) )residual details; 
      ods output OutputStatistics=Results fitsummary =summary modelsummary=creatininasummary; 
   run;  
proc print data=Results(obs=5);  
     id obs; 
run;
symbol1 color=black value=diamond interpol=none;   
symbol2 color=green interpol=join value=none; 
   proc gplot data=Results; 
      plot (depvar pred)*tiempo__dias_ / overlay  
           hminor = 0 
           vminor = 0 
           vaxis  = axis1 
           frame;           
title 'Grafico de perfiles individuales y curva Loess';
   run; quit;
      proc sort data=creatininasummary; 
       by smooth; 
   run; 
    symbol1 color=black interpol=join value=none width=2; 
   proc gplot data=creatininasummary; 
      format AICC f4.1; 
      format smooth f4.1; 
      plot AICC*Smooth /  
           hminor = 0 vminor = 0 
           vaxis  = axis1 frame; 
           axis1 label = ( r=0 a=90 ); 
title 'AICC';
   run; quit;

/*Con un valor especifacado del parametro de suavizado*/
proc loess data=creatinina; 
      model rdo=tiempo__dias_/smooth=0.2 all details; 
      ods output OutputStatistics=Results fitsummary =summary modelsummary=creatininasummary; 
   run;  
proc print data=Results(obs=5);  
     id obs; 
run;
symbol1 color=black value=diamond interpol=none;   
symbol2 color=red interpol=join value=none; 
   proc gplot data=Results; 
      plot (depvar pred)*tiempo__dias_ / overlay  
           hminor = 0 
           vminor = 0 
           vaxis  = axis1 
           frame;           
   run; quit;



proc glm data=creatinina;
  model rdo=tiempo__dias_ / solution;
  output out=residuos r=resid;
quit;

/*Càlculo del variograma*/
proc variogram data=residuos outpair=out;
coordinates xc=tiempo__dias_ yc=ndo;
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
	/ overlay haxis=axis1 vaxis=axis2 vref=216.498; 
symbol1 c=red v=dot h=0.2 mode=include;
symbol2 c=black i=join w=2 mode=include; 
axis1  label=(h=2 "Rezago") value=(h=1) 	
	order=(0 to 1200 by 100) minor=none; 
axis2  label=(h=2 A=90 "Variograma") value=(h=1.5) 
	order=(0 to 2800 by 100) minor=none; 
run;quit;


options ls=80 ps=59 nodate; run;


/*******************************************************************
  Use PROC MIXED to fit linear mixed effects model (i); we use
  normal ML rather than REML to get likelihood ratio tests
*******************************************************************/

title 'MODEL (i)';
proc mixed method=ml data=creatinina;
  class ndo sexo lab_inicio;
  model rdo = sexo lab_inicio edad_inicio tiempo__meses_ tiempo__meses_*lab_inicio/ solution;
*  random tiempo__meses_/ type=un subject=rdo;
 * estimate "slp w/diet" time 1 time*diet 1;
run;


/*******************************************************************
  Model (iii) includes this adjustment plus the possibility that
  rate of change depends on both diet and previous experience.
  We include estimate statements to estimate each slope and
  contrast statements to make some comparisons.
*******************************************************************/

title 'MODEL (iii)';
proc mixed method=ml data=press;
  class id;
  model press = weight prev age 
               time time*diet time*prev time*diet*prev / solution;
  random intercept time / solution type=un subject=id; /* solution:da lois valores de los efectos aleatorios predichos para cada individuo*/
  estimate "slp, diet, no prev" time 1 time*diet 1;
  estimate "slp, no diet, prev" time 1 time*prev 1;
  estimate "slp, diet, prev" time 1 time*prev 1 time*diet 1 time*diet*prev 1;
  contrast "overall slp diff" time*diet 1, 
                              time*prev 1, 
                              time*diet*prev 1 / chisq;
  contrast "prev effect" time*prev 1, time*diet*prev 1 / chisq;
  contrast "diet effect" time*diet 1, time*diet*prev 1 /chisq;
run;


/*******************************************************************
  Model (iv) -- "reduced" model with no diet or previous weightlifting 
  effect
*******************************************************************/

title 'MODEL (iv)';
proc mixed method=ml data=press;
  class id;
  model press = weight prev age time  / solution;
  random intercept time / type=un subject=id;
run;




*********************************MESES**********************************;


/*Grafico de perfiles individuales*/
proc gplot data=creatinina;
plot rdo*tiempo__meses_/ vaxis=axis1 haxis=axis2;
symbol v=diamond interpol=join;
axis1 label = (angle=90 'Rdo') major=(height=2) minor=(height=1)width=3;
axis2 label =('tiempo en meses'); 
title 'Grafico de perfiles individuales';
run; 

