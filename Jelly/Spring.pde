class Spring {
  Orb a, b;
  float restLength;
  float k;
  float damping;
  color c;

  Spring(Orb a_, Orb b_, float k_, float damping_) {
    a = a_;
    b = b_;
    k = k_;
    damping = damping_;
    restLength = PVector.dist(a.pos, b.pos);
  }

  void apply() {
    PVector dir = PVector.sub(b.pos, a.pos);
    float currentLen = dir.mag();
    dir.normalize();

    float x = currentLen - restLength;
    
    // Apply maximum stretch limit
    if (currentLen > restLength * 10) {
      x = restLength * 10 - restLength; // limit the extension
    }
    
    c = x >= 0 ? color(0, 255, 0) : color(255, 0, 0);
    PVector force = PVector.mult(dir, k * x);

    // damping
    PVector relVel = PVector.sub(b.vel, a.vel);
    PVector dampForce = PVector.mult(relVel, damping);
    force.add(dampForce);

    a.applyForce(force);
    b.applyForce(PVector.mult(force, -1));
  }

  void display() {
    stroke(255);
    strokeWeight(2);
    stroke(c);
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
  }
}
