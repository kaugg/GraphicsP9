/******** Editor of an Animated Coons Patch

Implementation steps:
**<01 Manual control of (u,v) parameters. 
**<02 Draw 4 boundary curves CT(u), CB(u), SL(v), CR(v) using proportional Neville
**<03 Compute and show Coons point C(u,v)
**<04 Display quads filed one-by-one for the animated Coons patch
**<05 Compute and show normal at C(u,v) and a ball ON the patch

*/
//**<01: mouseMoved; 'v', draw: uvShow()

float ball_s = 0.5;  // default position for ball on coonc patch surface.  This will place the ball in the middle.
float ball_t = 0.5;  // ''

float u=0, v=0; 
void uvShow() { 
  fill(red);
  if(keyPressed && key=='v')  text("u="+u+", v="+v,10,30);
  noStroke(); fill(blue); ellipse(u*width,v*height,5,5); 
  }
/*
0 1 2 3 
11    4
10    5
9 8 7 6
*/
pt coons(pt[] P, float s, float t) {
  pt Lst = L( L(P[0],s,P[3]), t, L(P[9],s,P[6]) ) ;
  pt Lt = L( N( 0,P[0], 1./3,P[1],  2./3,P[2],  1,P[3], s) ,t, N(0,P[9], 1./3,P[8], 2./3,P[7], 1,P[6], s) ) ;
  pt Ls = L( N( 0,P[0], 1./3,P[11], 2./3,P[10], 1,P[9], t) ,s, N(0,P[3], 1./3,P[4], 2./3,P[5] ,1,P[6], t) ) ;
  return P(Ls,V(Lst,Lt));
}
pt B(pt A, pt B, pt C, float s) {return L(L(A,s,B),s,L(B,s,C)); } 
pt B(pt A, pt B, pt C, pt D, float s) {return L(B(A,B,C,s),s,B(B,C,D,s)); } 
pt B(pt A, pt B, pt C, pt D, pt E, float s) {return L(B(A,B,C,D,s),s,B(B,C,D,E,s)); } 
pt N(float a, pt A, float b, pt B, float t) {return L(A,(t-a)/(b-a),B);}
pt N(float a, pt A, float b, pt B, float c, pt C, float t) {return N(a,N(a,A,b,B,t),c,N(b,B,c,C,t),t);}
pt N(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float t) {return N(a,N(a,A,b,B,c,C,t),d,N(b,B,c,C,d,D,t),t);}
pt N(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float e, pt E, float t) {return N(a,N(a,A,b,B,c,C,d,D,t),e,N(b,B,c,C,d,D,e,E,t),t);}

void drawBorders(pt[] P){
  float e=0.01;
  beginShape(); for(float t=0; t<1.001; t+=e) v(coons(P,0,t)); endShape();
  beginShape(); for(float t=0; t<1.001; t+=e) v(coons(P,1,t)); endShape();
  beginShape(); for(float t=0; t<1.001; t+=e) v(coons(P,t,0)); endShape();
  beginShape(); for(float t=0; t<1.001; t+=e) v(coons(P,t,1)); endShape();
  }

void shadeSurface(pt[] P, float e, boolean ballOn)
{ 
  for(float s=0; s<1.001-e; s+=e) for(float t=0; t<1.001-e; t+=e) 
  {
        beginShape(); 
        v(coons(P,s,t)); 
        v(coons(P,s+e,t)); 
        v(coons(P,s+e,t+e)); 
        v(coons(P,s,t+e)); 
        endShape(CLOSE);
        if(normals)
        {  
          // These are the three points we need to compute vectors U and V to obtain normal vector N (othogonal)
          pt P_point    = coons(P,s,t);    // Base point
          pt U_point    = coons(P,s+e,t);   // U point
          pt V_point    = coons(P,s,t+e);   // V point
     
          vec U_vector = V(P_point, U_point);  // Vectors to find cross product of
          vec V_vector = V(P_point, V_point);
  
          vec N_normal = N(U_vector, V_vector);  // This is the vector Normal
    
          // Display all of the vector Normals
          show(P_point,N_normal);
        }
    } 
}

void drawBall(pt[] P, float e)
  {
    pt ball_position = coons(P,ball_s,ball_t);
    float ball_radius = 14;
    
    // Let's find the lowest Z value for one of the neighbors of the Ball's location
    // These are the 4 points adjacent to the ball's location on the coons patch
    pt A_point    = coons(P,ball_s+e,ball_t);   
    pt B_point    = coons(P,ball_s,ball_t+e);   
    pt C_point    = coons(P,ball_s-e,ball_t);  
    pt D_point    = coons(P,ball_s,ball_t-e);   
    
    if(
          (A_point.z < B_point.z) &&
          (A_point.z < C_point.z) &&
          (A_point.z < D_point.z)
      )
      {
         ball_position = A_point;
         ball_s += e;
      }
    else if(
          (B_point.z < A_point.z) &&
          (B_point.z < C_point.z) &&
          (B_point.z < D_point.z)
           )
     {
            ball_position = B_point; 
            ball_t += e;    
     }
     else if(
          (C_point.z < A_point.z) &&
          (C_point.z < B_point.z) &&
          (C_point.z < D_point.z)
           )
     {
            ball_position = C_point;
            ball_s -= e;     
     }
     else if(
          (D_point.z < A_point.z) &&
          (D_point.z < B_point.z) &&
          (D_point.z < C_point.z)
           )
     {
            ball_position = D_point;
            ball_t -= e;     
     }
    if(ball_t < 0) ball_t = 0; if(ball_t > 1) ball_t = 1; if(ball_s < 0) ball_s = 0; if(ball_s > 1) ball_s = 1;
    
      
    // Draw ball onto coons patch
    fill(red);
    noStroke();
    pushMatrix();
    translate( ball_position.x,  ball_position.y,  ball_position.z + ball_radius);
    sphere(ball_radius);
    popMatrix();
 }  
  
