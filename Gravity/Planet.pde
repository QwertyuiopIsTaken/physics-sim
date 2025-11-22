class Planet {
  PVector position, velocity, acc;
  float mass;
  color c;
  
  // Store the velocity arrow for preview
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

  void applyAcceleration(PVector a) {
    acc.add(a);
  }

  void leapfrogUpdate(float dt) {
    velocity.add(PVector.mult(acc, 0.5 * dt));

    position.add(PVector.mult(velocity, dt));

    // Save trail
    if (mode == SIM) {
      trail.add(position.copy());
      if (trail.size() > 300) trail.remove(0);
    }
  }
  
  void finishVelocityUpdate(float dt) {
    // Step 4: complete the second half of velocity update
    velocity.add(PVector.mult(acc, 0.5 * dt));
  }

  void update() {
    velocity.add(acc);
    position.add(velocity);
    acc.mult(0);
    
    // Add current position to trail
    if (frameCount % 10 == 0) {
      trail.add(position.copy());
    }
  
    if (trail.size() > 500) {
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
    circle(position.x, position.y, sqrt(mass) * 2 * 2);
  
    // Draw velocity preview
    if (velocityPreview.mag() > 0 && mode == SETUP) {
      stroke(255, 150, 0);
      strokeWeight(2);
      drawArrow(position, velocityPreview, 10);
    }
  }


  boolean isMouseOver() {
    return dist(mouseX, mouseY, position.x, position.y) < sqrt(mass) * 2;
  }
}
