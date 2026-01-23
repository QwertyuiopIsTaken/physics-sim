class Propagation {
  int radius = 0;
  PVector pos;
  float sourceCharge;
  boolean propagate;
  
  Propagation(float x, float y, float charge, boolean propagate) {
    this.pos = new PVector(x, y);
    this.sourceCharge = charge;
    this.propagate = propagate;
  }
  
  void display() {
    noFill();
    if (propagate) {
      stroke(255, 0, 0);
    } else {
      stroke(0, 255, 0);
    }
    strokeWeight(2);
    circle(pos.x, pos.y, radius * 2);
  }
  
  boolean containsPoint(float x, float y) {
    PVector pointPos = new PVector(x, y);
    return (int)(pointPos.sub(pos).mag()) == radius;
  }
}
