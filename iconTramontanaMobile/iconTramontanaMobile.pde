/**
 * Color Variables (Homage to Albers). 
 * 
 * This example creates variables for colors that may be referred to 
 * in the program by a name, rather than a number. 
 */

size(1024, 1024);
noStroke();
background(185 , 197 , 197);

color mountain1 = color(146 , 181  ,148    );//(204, 102, 0); //49  50  98  
color mountain2 = color(148,  169 , 164   );//(204, 153, 0);// 185  197  197  
color lake = color(156,  189,  213   );//120  148  185   (153, 51, 0)
color snow = color (239,  239 , 239  );
// These statements are equivalent to the statements above.
// Programmers may use the format they prefer.
//color inside = #CC6600;
//color middle = #CC9900;
//color outside = #993300;


fill(mountain1);
triangle((width/8)*6, height/32, (width/8), (height/6)*4,(width/8)*11, (height/6)*4);

fill(mountain2);
triangle((width/10)*3, height/6, -width/10, (height/6)*4,(width/10)*7, (height/6)*4);


fill(snow);

triangle((width/10)*3, height/6, (width/10)*3-((width/10)*3*0.09), (height/6)*1.2,(width/10)*3+((width/10)*3*0.09), (height/6)*1.2);

triangle((width/8)*6, height/32,((width/8)*6)-( (width/8)*6*0.09), (height/12)*1.2,(width/8)*6+((width/8)*6*0.09), (height/12)*1.2);
fill(lake);
rect(0,(height/6)*4,width,(height/6));
save("test.png");
/*
pushMatrix();
translate(80, 80);
fill(outside);
rect(0, 0, 200, 200);
fill(middle);
rect(40, 60, 120, 120);
fill(inside);
rect(60, 90, 80, 80);
popMatrix();

pushMatrix();
translate(360, 80);
fill(inside);
rect(0, 0, 200, 200);
fill(outside);
rect(40, 60, 120, 120);
fill(middle);
rect(60, 90, 80, 80);
popMatrix();*/
