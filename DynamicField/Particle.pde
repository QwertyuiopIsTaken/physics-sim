class Particle {
  float charge;
  PVector pos;
  int radius = 10;
  color c;
  
  Particle(float x, float y, float charge) {
    this.pos = new PVector(x, y);
    this.charge = charge;
    if (charge > 0) {
      this.c = color(200, 0, 0);
    } else {
      this.c = color(0, 0, 200);
    }
  }
  
  void display() {
    strokeWeight(0);
    fill(c);
    circle(pos.x, pos.y, radius * 2);
  }
  
  boolean isClicked(float x, float y) {
    PVector clickPos = new PVector(x, y);
    return (clickPos.sub(pos).mag() <= radius);
  }
}
