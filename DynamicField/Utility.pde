class Utility {
  void drawArrow(PVector base, PVector vec, int arrowSize, int arrowLength) {
    float amt = map(sqrt(vec.mag()), 0, 10, 0, 1);
    color c = lerpColor(10, 255, amt);
    PVector v = vec.copy().normalize().mult(arrowLength);
    
    stroke(c);
    strokeWeight(1);
    line(base.x - v.x/2, base.y - v.y/2, base.x + v.x/2, base.y + v.y/2);
  
    // Draw arrowhead
    pushMatrix();
    translate(base.x + v.x/2, base.y + v.y/2);
    float angle = atan2(v.y, v.x);
    rotate(angle);
    line(0, 0, -arrowSize, arrowSize / 2);
    line(0, 0, -arrowSize, -arrowSize / 2);
    popMatrix();
  }
  
  PVector calcElectrostaticForce(float charge, PVector pos1, PVector pos2) {
    // F = kQq/r^2 (q = 1)
    int k_constant = 90000;
    PVector dir = PVector.sub(pos2, pos1);
    float r = dir.mag();
    return dir.normalize().mult(charge * k_constant).div(r*r);
  }
}
