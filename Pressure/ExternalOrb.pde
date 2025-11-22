class ExternalOrb extends Orb {
  // Random position constructor (default mass from Orb)
  ExternalOrb() {
    super();
    int w = constrain((int)(Math.random() * width), RADIUS, width - RADIUS);
    int h = constrain((int)(Math.random() * height), RADIUS, height - RADIUS);
    position = new PVector(w, h); // Place orb randomly within screen bounds
  }
  
  // Random position constructor with custom mass
  ExternalOrb(float m) {
    super(m);
    int w = constrain((int)(Math.random() * width), RADIUS, width - RADIUS);
    int h = constrain((int)(Math.random() * height), RADIUS, height - RADIUS);
    position = new PVector(w, h);
  }
  
  // Random position constructor with custom mass + velocity
  ExternalOrb(float m, PVector v) {
    super(m, v);
    int w = constrain((int)(Math.random() * width), RADIUS, width - RADIUS);
    int h = constrain((int)(Math.random() * height), RADIUS, height - RADIUS);
    position = new PVector(w, h);
  }

  // Simple reflection from the outer border of the screen
  void borderCollision() {
    // Top wall
    if (position.y - RADIUS < 0) {
      position.y = RADIUS;
      velocity.y *= -1;  // Reflect vertical velocity
    }

    // Bottom wall
    if (position.y + RADIUS > height) {
      position.y = height - RADIUS;
      velocity.y *= -1;
    }

    // Right wall
    if (position.x + RADIUS > width) {
      position.x = width - RADIUS;
      velocity.x *= -1;
    }

    // Left wall
    if (position.x - RADIUS < 0) {
      position.x = RADIUS;
      velocity.x *= -1;
    }
  }

  void checkCollision() {
    // Compute box boundaries
    float half = b.SIZE / 2.0;
    float left   = b.position.x - half;
    float right  = b.position.x + half;
    float top    = b.position.y - half;
    float bottom = b.position.y + half;

    // Distances to each wall (used for resolving ambiguous cases)
    float dxLeft   = abs(this.position.x - left);
    float dxRight  = abs(this.position.x - right);
    float dyTop    = abs(this.position.y - top);
    float dyBottom = abs(this.position.y - bottom);
    
    // If the orb is inside the box, push it to the nearest wall
    if (this.position.x > left && this.position.x < right &&
        this.position.y > top  && this.position.y < bottom) {

      // Push toward nearest vertical OR horizontal wall
      if (min(dxLeft, dxRight) < min(dyTop, dyBottom)) {
        this.position.x = (dxLeft < dxRight) ? left : right;
      } else {
        this.position.y = (dyTop < dyBottom) ? top : bottom;
      }
    }
    
    // Closest point on the box perimeter to the orb
    float closestX = constrain(this.position.x, left, right);
    float closestY = constrain(this.position.y, top, bottom);
    PVector closest = new PVector(closestX, closestY);

    // Vector from orb to nearest point on box
    PVector diff = PVector.sub(closest, this.position);
    float dist = diff.mag();

    // If the orb is not touching the box, exit
    if (dist > RADIUS) {
      return;
    }

    PVector normal;

    // Special case: orb directly overlapping the boundary without direction
    if (dist == 0) {

      // Choose the normal based on the closest wall
      if (min(dxLeft, dxRight) < min(dyTop, dyBottom)) {
        normal = (dxLeft < dxRight) ? new PVector(-1, 0) : new PVector(1, 0);
      } else {
        normal = (dyTop < dyBottom) ? new PVector(0, -1) : new PVector(0, 1);
      }

    } else {
      // Normal is opposite of diff (since diff points from orb to box)
      normal = diff.copy().normalize().mult(-1);
    }

    // Push orb out of the box
    float overlap = RADIUS - dist;
    this.position.add(PVector.mult(normal, overlap));

    // 1D elastic collision along normal
    float v1n = normal.dot(this.velocity);
    float v2n = normal.dot(b.velocity);

    float[] result = elasticCollision(v1n, v2n, this.mass, b.mass);
    float v1nAfter = result[0];
    float v2nAfter = result[1];

    // Apply velocity changes along the collision normal
    PVector deltaV1 = PVector.mult(normal, v1nAfter - v1n);
    PVector deltaV2 = PVector.mult(normal, v2nAfter - v2n);

    this.velocity.add(deltaV1);
    this.velocity.mult(1 - ENERGY_LOSS); // Apply slight energy loss

    b.velocity.add(deltaV2); // Push box in opposite direction
  }

  @Override
  void run() {
    position.add(velocity);       // Move orb
    velocity.add(acceleration);   // Apply gravity
    checkCollision();             // Collide with the box
    borderCollision();            // Collide with world boundaries
    orbInteraction(external);     // Collide with other external orbs
  }
}
