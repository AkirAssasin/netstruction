/* @pjs font='fonts/joystix.ttf' */ 

var myfont = loadFont("fonts/joystix.ttf"); 

ArrayList computers;

ArrayList securities;

ArrayList bullets;

ArrayList particles;

int score = 0;
int pX = 480;
int pY = 400;
int pRotation;
int pStorage = 400;
int pFlash = 0;

int aimX = 480;
int aimY = 400;
int aimRotation;

void setup() {
    width = 960;
    height = 800;
    size(width, height);
    computers = new ArrayList();
    securities = new ArrayList();
    bullets = new ArrayList();
    particles = new ArrayList();
    textFont(myfont);
};
 
Number.prototype.between = function (min, max) {
    return this > min && this < max;
}; 

void draw() {
    fill(0,30);
    stroke(0,10);
    rect(0,0,width,height);
    for (int i=computers.size()-1; i>=0; i--) {
        Particle c = (Computer) computers.get(i);
        c.draw();
        c.enter();
    }
    
    for (int i=particles.size()-1; i>=0; i--) {
        Particle p = (Particle) particles.get(i);
        p.update();
        if (p.lifeTime <= 0) {particles.remove(i);}
    }
    
    for (int i=securities.size()-1; i>=0; i--) {
        Particle s = (Security) securities.get(i);
        s.update();
        if (s.health <= 0) {
            securities.remove(i);
        }
    }
    
    for (int i=bullets.size()-1; i>=0; i--) {
        Particle b = (Bullet) bullets.get(i);
        b.update();
        if (b.x < 0 || b.x > width || b.y < 0 || b.y > height) {bullets.remove(i);}
    }
    stroke(255,0,0);
    strokeWeight(10);
    line(pX,pY,pX,pY);
    
    aimRotation = atan2(mouseY - aimY, mouseX - aimX) / PI * 180;
    if (dist(aimX,aimY,mouseX,mouseY) > 5) {
    aimX += cos(aimRotation/180*PI)*2;
    aimY += sin(aimRotation/180*PI)*2;
    }
    
    for (int i=bullets.size()-1; i>=0; i--) {
        Particle b = (Bullet) bullets.get(i);
        if (dist(b.x,b.y,pX+5,pY+5) < 5 && b.shotBy == 1) {bullets.remove(i); pStorage -= 50;}
    }
    
    strokeWeight(1);
    line(pX,pY,aimX,aimY);
    
    stroke(255);
    fill(0);
    rect(0,0,pStorage,10);
    fill(255);
    text(round(pStorage) + "GB",0,10);
    
    if (pStorage > 0) {pStorage -= 0.05;}

    
}

void mouseClicked() {
    // if (pStorage > 4) {
        bullets.add(new Bullet(pX-5,pY-5,aimX,aimY,0));
        pStorage -= 4;
    // }
    
    if (mouseX.between(0,0) && mouseY.between(0,0)) {}
};

void keyPressed() {
    
    // if (key == 'd' || key == 'D') {
    //     if (pStorage > 1) {pStorage -= 0.1;}
    //     pRotation = atan2(aimY - pY, aimX - pX) / PI * 180;
    //     if (dist(aimX,aimY,pX,pY) > 5) {
    //         pX += cos(pRotation/180*PI)*8;
    //         pY += sin(pRotation/180*PI)*8;
    //     }
    // }
    
    if (key == 'd' || key == 'D') {pX += 8;}
    if (key == 'w' || key == 'W') {pY -= 8;}
    if (key == 'a' || key == 'A') {pX -= 8;}
    if (key == 's' || key == 'S') {pY += 8;}
    
    if (key == 'h' || key == 'H') {
        fill(0,0);
        stroke(255,0,0);
        pFlash -= 10;
        if (pFlash <= 0) {pFlash = 300;}
        ellipse(pX, pY, pFlash, pFlash);
        for (int i=securities.size()-1; i>=0; i--) {
            Particle s = (Security) securities.get(i);
            if (dist(pX,pY,s.x,s.y) < 151 && s.mode == 0) {
                    for (int i=computers.size()-1; i>=0; i--) {
                        Particle c = (Computer) computers.get(i);
                        if (dist(c.x,c.y,s.x,s.y) < 50 && c.infested == 1) {
                            s.tx = c.x;
                            s.ty = c.y;
                            mode = 1;
                            s.switchT = random(100,1000);
                        }
                    }
                }
            
        }
        for (int i=computers.size()-1; i>=0; i--) {
            Particle c = (Computer) computers.get(i);
            c.hack();
        }
    }
    
    if (key == 'u' || key == 'U') {
        for (int i=computers.size()-1; i>=0; i--) {
            Particle c = (Computer) computers.get(i);
            c.unhack();
        }
    }
    
    if (key == 'c' || key == 'C') {
        computers.add(new Computer(mouseX,mouseY));
    }
    
    if (key == 'q' || key == 'Q') {
        securities.add(new Security(mouseX,mouseY));
    }
};

class Computer {
    float x = 0.0;
    float y = 0.0;
    float dataLeft = 0;
    float dataSpace = 0;
    float infested = 0;
    float toughness = 0;
    
    Computer(ox,oy) {
        x = ox;
        y = oy;
        dataLeft = round(random(100,300));
        dataSpace = dataLeft;
        toughness = random(1);
    };
    
    void draw() {
        fill(0,0);
        strokeWeight(1);
        stroke(255,255 * (dataLeft/dataSpace),255 * (dataLeft/dataSpace));
        rect(this.x - 40/2, this.y - 40/2, 40, 40);
        
        if (infested == 1) {
            stroke(255,50);
            line(this.x,this.y,pX,pY);
        }
    };
    
    void enter() {
        if (pX.between(this.x - 20,this.x + 20) && pY.between(this.y - 20,this.y + 20) && infested == 0) {
            for (int i; i <= 10; i++) {
                particles.add(new Particle(pX,pY,0,100));
            }
            infested = 1;
            
        }
    };
    
    void unhack() {
        if (aimX.between(this.x - 20,this.x + 20) && aimY.between(this.y - 20,this.y + 20) && infested == 1) {
            infested = 0;
        }
    };
    
    void hack() {
        if (infested == 1 && dataLeft > 0 && pStorage < 960 && dist(x,y,pX,pY) < 151) {
            dataLeft -= toughness;
            pStorage += toughness/2;
            stroke(255,0,0);
            line(this.x,this.y,pX,pY);
        }
    };
}

class Security {
    float x = 0.0;
    float y = 0.0;
    float vx = 0.0;
    float vy = 0.0;
    float tx = 0.0;
    float ty = 0.0;
    float rotation = 0;
    float mode = 0;
    float rank = 0;
    float switchT = 0;
    float sDelay = 0;
    float sMaxDel = 0;
    float health;
    
    Security(ox,oy) {
        x = ox;
        y = oy;
        tx = random(960);
        ty = random(800);
        rank = round(random(5));
        switch(rank) {
            case 0:
            case 1:
                health = random(2,4);
                sMaxDel = round(random(30,45));
                break;
            case 2:
            case 3:
            case 4:
                health = random(4,6);
                sMaxDel = round(random(25,35));
                break;
            case 5:
                health = random(10,20);
                sMaxDel = round(random(20,30));
                break;
        }
    };
    
    void update() {
        switchT -= 1;
        
        for (int i=bullets.size()-1; i>=0; i--) {
            Particle b = (Bullet) bullets.get(i);
            if (b.x.between(x-10,x+10) && b.y.between(y-10,y+10) && b.shotBy == 0) {bullets.remove(i); health -= round(random(2));}
        }
        if (mode == 0) {
            for (int i=computers.size()-1; i>=0; i--) {
                Particle c = (Computer) computers.get(i);
                if (dist(c.x,c.y,x,y) < 50) {
                    tx = c.x;
                    ty = c.y;
                    mode = 1;
                    switchT = random(100,1000);
                }
            }
            
            if (dist(x,y,pX,pY) < 30) {
                    mode = 2;
                    switchT = random(100,1000);
                }
            
            if (switchT <= 0) {
                tx = random(960);
                ty = random(800);
                switchT = random(100,1000);
            }
        }
        
        if (mode == 2) {
            if (dist(x,y,pX,pY) < 300) {text("!",x-5,y-10);} else {text("?",x-5,y-10);}
            
            if (sDelay <= 0 && dist(x,y,pX,pY) < 300) {
                text("!",x-5,y-10);
                bullets.add(new Bullet(x,y,pX + random(-30,30),pY + random(-30,30),1));
                sDelay = sMaxDel;
            }
            
            if (dist(x,y,tx,ty) < 30 || dist(x,y,pX,pY) < 50) {
                    if (random(1) < 0.7) {
                        tx = pX;
                        ty = pY;
                    } else {
                        mode = 0;
                        switchT = random(100,1000);
                    }
                    
                }
            
            sDelay -= 1;
            if (switchT <= 0) {
                for (int i=computers.size()-1; i>=0; i--) {
                Particle c = (Computer) computers.get(i);
                if (dist(c.x,c.y,x,y) < 50) {
                    tx = c.x;
                    ty = c.y;
                    mode = 1;
                    switchT = random(100,1000);
                }
            }
            }
        }
        
        if (mode == 1) {
            text("?",x-5,y-10);
            for (int i=computers.size()-1; i>=0; i--) {
                Particle c = (Computer) computers.get(i);
                if (dist(c.x,c.y,x,y) < 30 && c.infested == 1) {
                    mode = 2;
                    tx = pX;
                    ty = pY;
                    switchT = random(100,1000);
                }
            }
            if (dist(c.x,c.y,x,y) < 50) {
                    tx = c.x;
                    ty = c.y;
                    mode = 1;
                    switchT = random(100,1000);
                }
            if (dist(x,y,pX,pY) < 30) {
                    mode = 2;
                    switchT = random(100,1000);
                }
            if (switchT <= 0) {
                mode = 0;
                switchT = random(100,1000);
            }
        }
        
        if (tx < x) {this.vx -= random(0.05); this.vx *= .96;}
        if (tx > x) {this.vx += random(0.05); this.vx *= .96;}
        if (ty < y) {this.vy -= random(0.05); this.vy *= .96;}
        if (ty > y) {this.vy += random(0.05); this.vy *= .96;}
        
        this.x += this.vx;
        this.y += this.vy;
        fill(255);
        stroke(0,0);
        rect(this.x - (5 + rank/2),this.y - (5 + rank/2),10 + rank,10 + rank);
    };
}

class Bullet {
  float x, y, targetX, targetY, rotation, speed, shotBy;

  Bullet(ox,oy,otx,oty,o) {
    //places the bullet in the middle of the room
    x = ox;
    y = oy;
    shotBy = o;

    targetX = otx;
    targetY = oty;
    rotation = atan2(targetY - y, targetX - x) / PI * 180;
    
    speed = 10;
  }
  
  void update() {
    //move the bullet
    x += cos(rotation/180*PI)*speed;
    y += sin(rotation/180*PI)*speed;
    fill(255);
    translate(x+5, y+5);  
    rotate(rotation/180*PI);  
    rect(-5, -5, 10, 10); 
    rotate(0-rotation/180*PI); 
    translate(-(x+5), -(y+5)); 
    for (int i=securities.size()-1; i>=0; i--) {
        Particle s = (Security) securities.get(i);
        if (dist(x,y,s.x,s.y) < 100 && s.mode == 0) {s.mode = 2;}
    }
  }
}


class Particle {
    float x = 0.0;
    float y = 0.0;
    float vx = 0.0;
    float vy = 0.0;
    float rotation = 0;
    float type = 0;
    float lifeTime = 0;
    float oLifeTime = 0;
    float gravity = 0;
    
    Particle(ox,oy,ot,ol) {
        x = ox;
        y = oy;
        type = ot;
        lifeTime = ol;
        oLifeTime = ol;
        if (type == 0 || type == 1) {
            this.vx += random(2) - 1;
            this.vx *= .96;
            this.vy += random(2) - 1;
            this.vy *= .96;
            gravity = random(1);
        }
    };
    
    void update() {
        if (lifeTime > 0) {lifeTime -= 1;}
        if (lifeTime > 0 && type == 1) {lifeTime -= 1;}
        this.x += this.vx;
        this.y += this.vy;
        this.y += this.gravity;
        if (type == 0) {
        stroke(255,0,0,255*(lifeTime/oLifeTime));
        fill(0,0);
        rect(this.x-10,this.y-10,10,10);
        }
        if (type == 1) {
        stroke(0,0);
        fill(255,155*(lifeTime/oLifeTime));
        rect(this.x-1,this.y-1,2,2);
        }
    };
}