ArrayList<Orb> internal;   // Internal orbs (small particles inside the box)
ArrayList<Orb> external;   // External orbs (particles outside the box)

Box b;                     // The box that interacts with internal orbs

final float ENERGY_LOSS = 0.02;              // Energy loss factor per collision
final PVector gravity = new PVector(0, 0.1); // Constant downward gravity

final int N = 200;   // Number of internal orbs
final int Q = 400;   // Number of external orbs

final float internalDensity = 0.05/N;              // Density of internal orbs
final float externalDensity = internalDensity * 8; // Density of external orbs

boolean paused = false;

void setup() {
  size(350, 600);
  frameRate(60);

  internal = new ArrayList<>(N);
  external = new ArrayList<>(Q);
  b = new Box(0.1); // Create box with given mass

  // Create N internal orbs with mass internalDensity * 1
  for (int i = 0; i < N; i++) {
    internal.add(new InternalOrb(internalDensity * 1));
  }

  // Create Q external orbs with mass externalDensity * 1
  for (int i = 0; i < Q; i++) {
    external.add(new ExternalOrb(externalDensity * 1));
  }
}

// Computes total momentum of internal orbs + box
PVector getMomentum() {
  PVector momentum = new PVector(0, 0);

  // Sum momentum of all internal orbs
  for (Orb o : internal) {
    PVector v = o.velocity.copy();
    momentum.add(v.mult(o.mass));
  }

  // Add momentum of the box
  momentum.add(PVector.mult(b.velocity, b.mass));

  return momentum;
}

// Computes average kinetic energy of internal orbs
float getAverageKineticEnergy() {
  float total = 0;

  for (Orb o : internal) {
    total += 0.5 * o.mass * o.velocity.magSq(); // KE = 1/2 m v^2
  }

  return total / internal.size();
}

void draw() {
  if (paused) {
    return;
  }
  
  background(255);

  // Update and display internal orbs
  for (Orb o : internal) {
    o.display();
    o.run();
  }

  // Update and display external orbs
  for (Orb o : external) {
    o.display();
    o.run();
  }

  // Update and display the box
  b.display();
  b.run();

  // Top text information
  fill(0);
  textSize(16);

  // Display average kinetic energy (scaled by 1000)
  text("Avg KE: " + nf(getAverageKineticEnergy() * 1000, 0, 3), 10, 20);

  // Display box position
  text("Box position: (" + nf(b.position.x, 0, 2) + ", " + nf(b.position.y, 0, 2) + ")", 10, 36);

  // Display framerate
  text("Framerate: " + nf(frameRate, 0, 2), 10, height - 16);

  // Momentum magnitude of the box + internal orbs system
  // text("Magnitude of p: " + nf(getMomentum().mag(), 0, 3), 10, 68); // Optional line
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}
