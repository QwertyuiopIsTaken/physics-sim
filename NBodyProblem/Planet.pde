class Planet {
  PVector position, velocity, acc;
  float mass;
  color c;
  
  // Store the velocity arrow
  PVector velocityPreview;
  ArrayList<PVector> trail; // Store previous positions

  Planet(PVector p, float m) {
    position = p.copy();
    velocity = new PVector(0, 0);
    acc = new PVector(0, 0);
    mass = m;
    c = color(random(100,255), random(100,255), random(100,255));
    
    velocityPreview = new PVector(0, 0);
    trail = new ArrayList<PVector>();
  }

  void applyForce(PVector f) {
    acc.add(PVector.div(f, mass));
  }

  void update() {
    velocity.add(acc);
    position.add(velocity);
    acc.mult(0);
    
    // Add current position to trail
    if (frameCount % 10 == 0) {
      trail.add(position.copy());
    }
  
    // Optional: limit trail length to avoid memory issues
    if (trail.size() > 300) {  // max 100 points
      trail.remove(0);
    }
  }

  void display() {
    // Draw trail
    noFill();
    stroke(c, 150); // semi-transparent trail
    strokeWeight(2);
    for (int i = 1; i < trail.size(); i++) {
      PVector prev = trail.get(i-1);
      PVector curr = trail.get(i);
      line(prev.x, prev.y, curr.x, curr.y);
    }
  
    // Draw planet
    fill(c);
    noStroke();
    circle(position.x, position.y, sqrt(mass) * 2 * 2.5);
  
    // Draw velocity preview
    if (velocityPreview.mag() > 0) {
      stroke(255, 150, 0);
      strokeWeight(2);
      drawArrow(position, velocityPreview, 10);
    }
  }

  boolean isMouseOver() {
    return dist(mouseX, mouseY, position.x, position.y) < sqrt(mass) * 2.5;
  }
}
