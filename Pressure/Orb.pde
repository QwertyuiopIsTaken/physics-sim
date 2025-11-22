abstract class Orb {
  int RADIUS = 8; // Radius of each orb for drawing and collision detection
  
  PVector position;      // Current position
  PVector velocity;      // Current velocity
  PVector acceleration;  // Current acceleration (gravity)
  float mass;            // Mass of the orb
  color c;               // Display color

  Orb() {
    // Start somewhere randomly inside the box
    position = new PVector(
      b.position.x + (int)(Math.random() * b.SIZE - b.SIZE/2),
      b.position.y + (int)(Math.random() * b.SIZE - b.SIZE/2)
    );

    // Give each orb a random direction with magnitude 1
    velocity = PVector.random2D().normalize().mult(1);

    acceleration = gravity;   // All orbs experience the same gravity
    mass = 1;                 // Default mass
    c = color(255, 255, 0);   // Default color (yellow)
  }
  
  Orb(float m) {
    this();        // Use default constructor setup
    mass = m;      // Override mass
  }

  Orb(float m, PVector v) {
    this();        // Use default constructor setup
    mass = m;      // Override mass
    velocity = v;  // Override starting velocity
  }

  void display() {
    fill(c);
    strokeWeight(0);
    circle(position.x, position.y, RADIUS * 2);  // Draw the orb
  }

  void orbInteraction(ArrayList<Orb> orbs) {
    // Double loop to check all unique orb pairs
    for (int i = 0; i < orbs.size(); i++) {
      Orb a = orbs.get(i);
      for (int j = i + 1; j < orbs.size(); j++) {
          Orb b = orbs.get(j);
  
          // Vector from b to a
          PVector diff = a.position.copy();
          diff.sub(b.position);
  
          // Check if the two spheres intersect
          if (diff.mag() <= a.RADIUS + b.RADIUS) {

              // Normal vector from a to b (collision axis)
              PVector normal = PVector.sub(b.position, a.position).normalize();
  
              // Project velocities onto the normal direction
              float v1n = normal.dot(a.velocity);
              float v2n = normal.dot(b.velocity);

              // Compute new velocities along the collision normal
              float[] result = elasticCollision(v1n, v2n, a.mass, b.mass);
  
              // Update velocities (only the normal components change)
              a.velocity.x += (result[0] - v1n) * normal.x;
              a.velocity.y += (result[0] - v1n) * normal.y;
              b.velocity.x += (result[1] - v2n) * normal.x;
              b.velocity.y += (result[1] - v2n) * normal.y;
              
              // Correct overlap so they don't get stuck together
              float overlap = a.RADIUS + b.RADIUS - diff.mag();
              PVector correction = PVector.mult(normal, overlap / 2);

              a.position.sub(correction);
              b.position.add(correction);
          }
      }
    }
  }

  abstract void checkCollision();

  float[] elasticCollision(float v1, float v2, float m1, float m2) {
    // 1D elastic collision equations
    float v1p = ((m1 - m2) / (m1 + m2)) * v1 + (2 * m2 / (m1 + m2)) * v2;
    float v2p = (2 * m1 / (m1 + m2)) * v1 - ((m1 - m2) / (m1 + m2)) * v2;

    return new float[]{v1p, v2p};
  }

  void run() {
    position.add(velocity);      // Update position
    velocity.add(acceleration);  // Apply gravity
    checkCollision();            // Boundary or box collisions (handled externally)
  }
}
