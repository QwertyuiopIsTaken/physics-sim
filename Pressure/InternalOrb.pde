class InternalOrb extends Orb {
  InternalOrb() {
    super();
  }

  InternalOrb(float m) {
    super(m);
  }

  InternalOrb(float m, PVector v) {
    super(m, v);
  }

  void checkCollision() {
    // Compute box boundaries
    float half = b.SIZE / 2.0;
    float left   = b.position.x - half;
    float right  = b.position.x + half;
    float top    = b.position.y - half;
    float bottom = b.position.y + half;

    // Keep the orb inside the box
    // Ensures the orb never leaves the box before resolving physics
    this.position.x = constrain(this.position.x, left, right);
    this.position.y = constrain(this.position.y, top, bottom);

    // Distances to each wall
    float dxLeft   = abs(this.position.x - left);
    float dxRight  = abs(this.position.x - right);
    float dyTop    = abs(this.position.y - top);
    float dyBottom = abs(this.position.y - bottom);

    // Choose the nearest vertical wall OR horizontal wall.
    float closestX = dxLeft < dxRight ? left : right;
    float closestY = dyTop < dyBottom ? top : bottom;

    // Determine whether the collision came from a vertical or horizontal side
    PVector closest = 
      abs(this.position.x - closestX) >= abs(this.position.y - closestY)
      ? new PVector(this.position.x, closestY)    // Horizontal collision
      : new PVector(closestX, this.position.y);  // Vertical collision

    // Vector from orb to box surface
    PVector diff = PVector.sub(closest, this.position);
    float dist = diff.mag();

    // No collision if the orb is farther than one radius from the wall
    if (dist > RADIUS) {
      return;
    }

    PVector normal;

    // Special case: orb exactly aligned with a wall edge (no clear direction)
    if (dist == 0) {

      // Choose normal based on smallest distance to a wall
      if (min(dxLeft, dxRight) < min(dyTop, dyBottom)) {
        normal = (dxLeft < dxRight) ? new PVector(1, 0) : new PVector(-1, 0);
      } else {
        normal = (dyTop < dyBottom) ? new PVector(0, 1) : new PVector(0, -1);
      }

    } else {
      // Normal points *into the interior* of the box
      normal = diff.copy().normalize().mult(-1);
    }

    float overlap = RADIUS - dist;
    this.position.add(PVector.mult(normal, overlap));

    float v1n = normal.dot(this.velocity);   // Orb's normal velocity
    float v2n = normal.dot(b.velocity);      // Box's normal velocity

    float[] result = elasticCollision(v1n, v2n, this.mass, b.mass);
    float v1nAfter = result[0];
    float v2nAfter = result[1];

    // Change in velocity along the normal
    PVector deltaV1 = PVector.mult(normal, v1nAfter - v1n);
    PVector deltaV2 = PVector.mult(normal, v2nAfter - v2n);

    this.velocity.add(deltaV1);
    this.velocity.mult(1 - ENERGY_LOSS);

    b.velocity.add(deltaV2);
  }

  // Standard 1D elastic collision formula
  float[] elasticCollision(float v1, float v2, float m1, float m2) {
    float v1p = ((m1 - m2) / (m1 + m2)) * v1 + (2 * m2 / (m1 + m2)) * v2;
    float v2p = (2 * m1 / (m1 + m2)) * v1 - ((m1 - m2) / (m1 + m2)) * v2;
    return new float[]{v1p, v2p};
  }

  @Override
  void run() {
    // Color maps from blue -> red depending on speed
    c = lerpColor(color(0, 0, 255), color(255, 0, 0), velocity.mag() / 4);

    position.add(velocity);       // Move orb
    velocity.add(acceleration);   // Apply gravity
    checkCollision();             // Bounce inside the box
    orbInteraction(internal);     // Interact with other internal orbs
  }
}
