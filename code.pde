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

void setup() {
    width = 960;
    height = 800;
    size(width, height);
    computers = new ArrayList();
    securities = new ArrayList();
    bullets = new ArrayList();
    particles = new ArrayList();
    textFont(myfont);
    for (int i; i<=30; i++) {
            computers.add(new Computer(random(width),random(height)));
    };
    Particle c = (Computer) computers.get(0);
        c.x = width/2;
        c.y = height/2;
        c.isMain = 1;
        c.dataLeft = 0;
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
    
    for (int i=bullets.size()-1; i>=0; i--) {
        Particle b = (Bullet) bullets.get(i);
        if (dist(b.x,b.y,pX+5,pY+5) < 5 && b.shotBy == 1) {bullets.remove(i); pStorage -= 50;}
    }
    
    strokeWeight(1);
    
    line(pX,pY,mouseX,mouseY);
    
    stroke(255);
    fill(0);
    rect(0,0,pStorage,10);
    fill(255);
    textSize(12);
    text(round(pStorage) + "GB",0,10);
    
    if (pStorage > 0) {pStorage -= 0.1;}
}

void mouseClicked() {
    // if (pStorage > 4) {
        bullets.add(new Bullet(pX-5,pY-5,mouseX,mouseY,0));
        pStorage -= 4;
    // }
    
    if (mouseX.between(0,0) && mouseY.between(0,0)) {}
};

void keyPressed() {
    if (key == 'h' || key == 'H') {
        fill(0,0);
        stroke(255,0,0);
        pFlash -= 10;
        if (pFlash <= 0) {pFlash = 300;}
        ellipse(mouseX, mouseY, pFlash, pFlash);
        for (int i=securities.size()-1; i>=0; i--) {
            Particle s = (Security) securities.get(i);
            if (dist(mouseX,mouseY,s.x,s.y) < 151 && s.mode == 0) {
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
        line(mouseX,mouseY,pX,pY);
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
    float weakness = 0;
    float hasSecurity = 0;
    float isMain = 0;
    float tier = 0;
    float job = 0;
    float pT = 0;
    
    Computer(ox,oy) {
        x = ox;
        y = oy;
        tier = round(random(4));
        job = round(random(tier));
        dataLeft = round(random(100,300));
        dataSpace = dataLeft;
        weakness = random(0.2,1);
        if (weakness < 0.4) {hasSecurity = round(random(5));}
    };
    
    void draw() {
        fill(0,0);
        strokeWeight(1);
        stroke(255,255 * (dataLeft/dataSpace),255 * (dataLeft/dataSpace));
        
        if (isMain == 1) {strokeWeight(4);}
        rect(this.x - 20, this.y - 20, 40, 30);
        rect(this.x - 10, this.y + 10, 20, 5);
        rect(this.x - 18, this.y + 15, 36, 5);
        
        if (dist(x,y,mouseX,mouseY) < 30) {
            fill(255,255 * (dataLeft/dataSpace),255 * (dataLeft/dataSpace));
            textSize(10);
            text("Tier " + tier + " com",this.x - 45,this.y - 30);
        }
        
        for (int i=computers.size()-1; i>=0; i--) {
            Particle c = (Computer) computers.get(i);
            if (c.isMain == 0 && dist(x,y,c.x,c.y) < 40 && dist(x,y,c.x,c.y) > 1) {computers.remove(i);}
        }
        
        if (isMain == 1) {
            pX = x; pY = y;
        }
        
        if (dataLeft <= 0) {
            stroke(255,0,0,50);
            line(this.x,this.y,pX,pY);
        }
    };
    
    void hack() {
        if (dataLeft > 0 && pStorage < 960 && dist(x,y,mouseX,mouseY) < 151) {
            dataLeft -= weakness;
            pStorage += weakness/2;
            stroke(255,0,0);
            
            if (pT <= 0) {
                pT = 20;
                particles.add(new Particle(x - random(-15,15),y - random(-15,15), 0, random(30,70)));
                particles.add(new Particle(pX - random(-15,15),pY - random(30,50), 1, random(30,70)));
            } else {pT -= 1;}
            
            line(this.x,this.y,mouseX,mouseY);
            if (hasSecurity > 0) {
                securities.add(new Security(x,y));
                hasSecurity -= 1;
            }
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
                if (dist(c.x,c.y,x,y) < 100 && c.dataLeft < (c.dataSpace - 30) && dist(c.x,c.y,x,y) > 10) {
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
            fill(255);
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
    if (shotBy == 0) {fill(255,0,0);}
    if (shotBy == 1) {fill(255);}
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
    float digit = 0;
    
    Particle(ox,oy,ot,ol) {
        x = ox;
        y = oy;
        type = ot;
        lifeTime = ol;
        oLifeTime = ol;
        digit = round(random(9));
        if (type == 0) {
            this.vy += 0 - random(1,2);
            this.vy *= .96;
        }
        if (type == 1) {
            this.vy += 1.5;
            this.vy *= .96;
        }
    };
    
    void update() {
        if (lifeTime > 0 && type == 0) {lifeTime -= 1;}
        if (type == 1 && y > pY - 30) {lifeTime -= 1;}
        this.x += this.vx;
        this.y += this.vy;
        this.y += this.gravity;
        if (type == 0 || type == 1) {
        fill(255,0,0,255*(lifeTime/oLifeTime));
        text(digit,this.x-10,this.y-10);
        }
    };
}