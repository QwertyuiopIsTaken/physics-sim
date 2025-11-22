class Orb {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;

  Orb(PVector p, float m) {
    pos = p.copy();
    vel = new PVector();
    acc = new PVector();
    mass = m;
  }

  void applyForce(PVector f) {
    acc.add(PVector.div(f, mass));
  }

  void update(float dt) {
    vel.add(PVector.mult(acc, dt));
    pos.add(PVector.mult(vel, dt));
    acc.mult(0);
  }

  void display() {
    fill(0, 200, 255);
    noStroke();
    circle(pos.x, pos.y, ORB_RADIUS*2);
  }
}
