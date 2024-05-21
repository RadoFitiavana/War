import java.util.ArrayList ; //<>//

PImage fireball ;
PImage boum ;
PImage tank ;
PImage magic ;
PImage fire ;
PImage back ;
PImage win ;
PImage over ;

boolean isOverlaped(float x1, float y1, float x2, float y2){
  float d = pow(x1-x2,2)+pow(y1-y2,2) ;
  if (pow(d,0.5)<=40){
    return true ;
  }
  else{
    return false ;
  }
}

abstract class Tick{
  boolean state ;
  float rectX ;
  float rectY ;
  float Cx ;
  float Cy ;
  float rx ;
  float ry ;
  Tick(float rectX, float rectY, float rx, float ry){
    this.state = false ;
    this.rectX = rectX ;
    this.rectY = rectY ;
    this.rx = rx ;
    this.ry = ry ;
  }
  abstract void listen() ;
}

ArrayList<Wall> walls = null ;
ArrayList<Tank> tanks = null ;
ArrayList<Tank> oT = null ;
ArrayList<Tank> you = null ;
float v ;
float ti ;
float tf ;
float a ;
float u ;
float stepRate ;
Ball cur = null ;
Tank T = null ;
Wall w = null ;
float fact ;

void setup(){
  size(800,600) ;
  a = millis() ;
  u = millis() ;
  back = loadImage("img/back.png") ;
  back.resize(width,height) ;
  fireball = loadImage("img/fireball.jpg") ;
  fireball.resize(20,20) ;
  boum = loadImage("img/boum.jpg") ;
  boum.resize(100,100) ;
  tank = loadImage("img/tank.jpg") ;
  tank.resize(50,50) ;
  magic = loadImage("img/magic.jpg") ;
  magic.resize(20,20) ;
  fire = loadImage("img/fire.jpg") ;
  fire.resize(75,75) ;
  win = loadImage("img/win.jpg") ;
  win.resize(200,60) ;
  over= loadImage("img/over.jpg") ;
  over.resize(200,60) ;
  v = 15 ;
  T = new Tank(random(0,width-50),height-50,50,50,0,255,0) ;
  T.state = true ;
  you = new ArrayList<Tank>() ;
  you.add(T) ;
  oT = new ArrayList<Tank>() ;
  tanks = new ArrayList<Tank>() ;
  tanks.add(T) ;
  for (int i=0; i<2; i++){
    tanks.add(new Tank(int(random(0,width-50)),int(random(0,height/4)),50,50,255,0,0)) ;
    tanks.get(i+1).state = true ;
    oT.add(tanks.get(i+1)) ;
  }
  walls = new ArrayList<Wall>() ;
  float x,y ;
  for (int i=0; i<20; i++){
    x = random(0,width-20) ;
    y = random(0,height-20) ;
    for (Wall w:walls){
      while(isOverlaped(x,y,w.x,w.y)){
        x = random(0,width-20) ;
        y = random(0,width-20) ;
      }
    }
    walls.add(new Wall(x,y,20,(random(-1,1)>=0),tanks)) ;
    walls.get(i).state = true ;
  }
  ti = millis() ;
  stepRate = 2 ;
  fact = 2 ;
}

void draw(){
  imageMode(CENTER) ;
  image(back,width/2,height/2) ;
  tf = millis() ;
  for (int i=0; i<walls.size(); i++){
    w = walls.get(i) ;
    if (w.state == true){
      w.display() ;
      w.listen() ;
    }
    else{
      w = null ;
      walls.remove(i) ;
    }
  }
  T.display(mouseX,mouseY) ;
  T.listen() ;
  for (int i=0; i<T.balls.size(); i++){
    T.balls.get(i).shoot() ;
  }
  if(T.balls.size() == 10){
    T.balls.removeAll(T.balls) ;
  }
  for (Tank tk:oT){
    if (millis() - ti >= 300){
      moovOpponent(tk) ;
      ti = millis() ;
    }
    tk.display(T.rectX,T.rectY) ;
    if (millis()-u >= 4000){
      if (random(-1,1)>=0){
      tk.shield=true ;
      tk.t_shield=millis() ;
      }
      else{
        tk.shield=false ;
      }
      u = millis() ;
    }
    tk.listen() ;
    if (millis()-a>=2500){
      tk.shoot(you) ;
      a = millis() ;
    }
    for (int i=0; i<tk.balls.size(); i++){
      tk.balls.get(i).shoot() ;
    }
    if (tk.balls.size() == 10){
      tk.balls.removeAll(tk.balls) ;
    }
  }
  for (int i=0; i<tanks.size(); i++){
    if (tanks.get(i).state==false){
      tanks.remove(i) ;
    }
  }
  for (int i=0; i<oT.size(); i++){
    if (oT.get(i).state==false){
      oT.remove(i) ;
    }
  }
  if (T.state == false){
    //fill(255) ;
    imageMode(CENTER) ;
    image(over,width/2,height/2) ;
    noLoop() ;
  }
  if (oT.size() == 0){
    //fill(255) ;
    imageMode(CENTER) ;
    image(win,width/2,height/2) ;
    noLoop() ;
  }
  
}

class Tank extends Tick{
  float Cx, Cy ;
  float Hx, Hy ;
  float Qx, Qy ;
  float r ;
  float red ;
  float green ;
  float blue ;
  int life ;
  boolean shield ;
  int n_shield ;
  float t_shield ;
  ArrayList<Ball> balls ;
  ArrayList<Ball> Rballs ;
  Tank(float rectX, float rectY, float rx, float ry, float red, float green, float blue){
    super(rectX,rectY,rx,ry) ;
    this.r = 50 ;
    this.Cx = this.rectX + (this.rx/2) ;
    this.Cy = this.rectY + (this.ry/2) ;
    this.Hx = this.Cx ;
    this.Hy = this.Cy ;
    this.Qx = this.Cx ;
    this.Qy = this.Cy - this.r ;
    this.red = red ;
    this.green = green ;
    this.blue = blue ;
    this.life = 10 ;
    this.balls = new ArrayList<Ball>() ;
    this.Rballs = new ArrayList<Ball>() ;
    this.shield = false ;
    this.t_shield = 0 ;
  }
  void display(float X, float Y){
    if (this.state){
    if (this.shield == true){
      float t = millis() ;
      fill(0,0,100) ;
      ellipse(this.Cx,this.Cy,3*this.r/2,3*this.r/2) ;
      if (t-this.t_shield >= 5000){
        this.shield = false ;
      }
    }
    float d = pow(X-Hx,2) + pow(Y-Hy,2) ;
    d = pow(d,0.5) ;
    float a = r/d ;
    Qx = Hx + a*(X - Hx) ;
    Qy = Hy + a*(Y - Hy) ;
    fill(red,green,blue) ;
    imageMode(CENTER) ;
    image(tank,Cx,Cy) ;
    stroke(50) ;
    line(Hx,Hy,Qx,Qy) ;
    fill(255) ;
    stroke(0) ;
    fill(red,green,blue) ;
    ellipse(Cx,Cy,15,15) ;
    }
  }
  void moov(float dx, float dy){
    if (dx < 0){
      if (this.rectX>=stepRate){
        this.rectX += dx ;
        this.Cx += dx ;
        this.Hx += dx ;
        this.Qx += dx ;
      }
    }
    else{
      if (this.rectX+this.rx <= width-stepRate){
       this.rectX += dx ;
       this.Cx += dx ;
       this.Hx += dx ;
       this.Qx += dx ;
      }
    }
    if (dy < 0){
      if (this.rectY>=stepRate){
       this.rectY += dy ;
       this.Cy += dy ;
       this.Hy += dy ;
       this.Qy += dy ;
      }
    }
    else{
      if (this.rectY+this.ry <= height-stepRate){
       this.rectY += dy ;
       this.Cy += dy ;
       this.Hy += dy ;
       this.Qy += dy ;
      }
    }
   }
  void listen(){
    for (int i=0; i<this.Rballs.size(); i++){
      if (dTB(this,Rballs.get(i))<=this.rx/2){
        Rballs.get(i).state=false ;
        if (!this.shield){
          this.state = false ;
          imageMode(CENTER) ;
          image(boum,this.Cx,this.Cy) ;
        }
      }
    }
  }
 
  void shoot(ArrayList<Tank> t){
     float xi = this.Hx ;
     float yi = this.Hy ;
     float xf = this.Qx ;
     float yf = this.Qy ;
     float cos = (xf - xi)/this.r ;
     float sin = (yf - yi)/this.r ;
     Ball b = new Ball(xf,yf,cos,sin,true) ;
     this.balls.add(b) ;
     for (int i=0; i<walls.size(); i++){
       walls.get(i).Rballs.add(b) ;
     }
     for (Tank T: t){
       T.Rballs.add(b) ;
     }
  }    
}

class Ball{
  boolean state ;
  float x ;
  float y ;
  float cos ;
  float sin ;
  Ball(float x, float y, float cos, float sin, boolean state){
    this.x = x ;
    this.y = y ;
    this.cos = cos ;
    this.sin = sin ;
    this.state = state ;
  }
  void display(){
     imageMode(CENTER) ;
     image(fireball,x,y) ;
     noFill() ;
     ellipse(this.x,this.y,20,20) ;
     if ((this.x<=10)||(this.x>=width-10)||(this.y<=10)||(this.y>=height-10)){
       this.state = false ;
     }
    }
  void shoot(){
    if (state == true){
      this.x += cos*v ;
      this.y += sin*v ;
      this.display() ;
    }
  }
}

class Wall{
  boolean state ;
  float x ;
  float y ;
  float r ;
  boolean bomb ;
  ArrayList<Ball> Rballs ;
  ArrayList<Tank> Rtanks ;
  Wall(float x, float y, float r, boolean bomb, ArrayList<Tank> Rtanks){
    this.Rballs = new ArrayList<Ball>() ;
    this.Rtanks = Rtanks ;
    this.bomb = bomb ;
    this.r = r ;
    this.x = x ;
    this.y = y ;
    this.state = false ;
  }
  void display(){
    if (this.state == true){
      imageMode(CENTER) ;
      //fill(0) ;
      //ellipse(x,y,100,100) ;
      image(magic,x,y) ;
    } 
  }
  void listen(){
    float d ;
    for (Ball tmp: this.Rballs){
      d = pow(tmp.x-this.x-this.r/2,2)+pow(tmp.y-this.y-this.r/2,2) ;
      d = pow(d,0.5) ;
      if (d<=50){
        tmp.state = false ;
        this.state = false ;
        this.Rballs.remove(tmp) ;
        imageMode(CENTER) ;
        if (this.bomb){
          image(fire,this.x,this.y) ;
        }
        else{
          image(boum,this.x,this.y) ;
        }
        break ;
      }
    }
    for (Tank t: this.Rtanks){
      d = dTW(t,this) ;
      if (d<=20){
        if (this.bomb && t.shield==false){
          this.state = false ;
          t.state = false ;
          imageMode(CENTER) ;
          image(fire,t.Cx,t.Cy) ;
        }
        else{
          this.state = false ;
        }
        break ;
      }
    }
  }
}

void keyPressed(){
   if(key=='z'){
      T.moov(0,-stepRate) ;
   }
   if(key=='s'){
     T.moov(0,stepRate) ;
   }
   if(key=='q'){
     T.moov(-stepRate,0) ;
   }
   if(key=='d'){
     T.moov(stepRate,0) ;
   }
  if ((key=='a') || (key=='A')){
    stepRate *= fact ;
    fact = 1/fact ;
  }
}

void mousePressed(){
  if (mouseButton==LEFT){
    T.shoot(oT) ;
  }
  if (mouseButton==RIGHT){
    T.shield = true ;
    T.t_shield = millis() ;
  }
}

float dTB(Tank t, Ball b){
  float d = pow(t.Cx-b.x,2)+pow(t.Cy-b.y,2) ;
  return pow(d,0.5);
}

float dTW(Tank t, Wall w){
  float d = pow(t.Cx-(w.x),2)+pow(t.Cy-(w.y),2) ;
  return pow(d,0.5) ;
}

void moovOpponent(Tank t){
  boolean isX = random(-1,1)>=0 ;
  float len = random(-50,50) ;
  float f ;
  if (len < 0){
    f = -1 ;
  }
  else{
    f = 1 ;
  }
  float cumul = 0f ;
  if (isX){
    while (cumul<f*len){
      t.moov(f*stepRate,0) ;
      cumul += stepRate ;
    }
  }
  else{
    while (cumul<f*len){
      t.moov(0,f*stepRate) ;
      cumul += stepRate ;
    }    
  }
}
