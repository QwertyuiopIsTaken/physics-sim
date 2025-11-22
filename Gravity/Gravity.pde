// Physical constants
final int SETUP = 0;
final int SIM = 1;
int mode = SETUP;

ArrayList<Planet> planets;

float currentMass = 10;

float DT = 0.05; // time step (frames per update)

final float G_SIM = 20000;

Planet selected = null;
boolean draggingVelocity = false;

void setup() {
  size(900, 750);
  frameRate(240);
  planets = new ArrayList<>();
}

void draw() {
  background(0);

  if (mode == SETUP) {
    drawSetupMode();
  } else if (mode == SIM) {
    runSimulation();
  }

  // Top text information
  fill(255);
  textSize(16);
  // Display framerate
  text("Framerate: " + nf(frameRate, 0, 2), 10, height - 16);
}

void drawSetupMode() {
  fill(255);
  textSize(18);
  text("Setup mode: Click to add planets. Drag to set velocity. Up/down arrow keys to change mass. Press enter to start.", 10, 20);

  // Draw current mass indicator
  text("Current mass: " + nf(currentMass, 1, 1), 10, 50);

  // Draw all planets
  for (Planet p : planets) {
    p.display();

    // If dragging velocity of this planet, draw preview arrow
    if (p == selected && draggingVelocity) {
      stroke(255, 150, 0);
      strokeWeight(2);
      line(p.position.x, p.position.y, mouseX, mouseY);
    }
  }
}

void runSimulation() {
  for (Planet p : planets) {
    p.acc.set(0, 0);
  }

  for (int i = 0; i < planets.size(); i++) {
    Planet a = planets.get(i);
    for (int j = i + 1; j < planets.size(); j++) {
      Planet b = planets.get(j);

      PVector r = PVector.sub(b.position, a.position);
      float distSq = max(r.magSq(), 25);  // avoid singularity
      float force = G_SIM / distSq;

      PVector dir = r.copy().normalize();

      // Acceleration = F/m
      a.applyAcceleration(PVector.mult(dir, force / a.mass));
      b.applyAcceleration(PVector.mult(dir, -force / b.mass));
    }
  }

  for (Planet p : planets) {
    p.leapfrogUpdate(DT);
  }

  for (Planet p : planets) {
    p.acc.set(0, 0);
  }
  for (int i = 0; i < planets.size(); i++) {
    Planet a = planets.get(i);
    for (int j = i + 1; j < planets.size(); j++) {
      Planet b = planets.get(j);

      PVector r = PVector.sub(b.position, a.position);
      float distSq = max(r.magSq(), 25);
      float force = G_SIM / distSq;

      PVector dir = r.copy().normalize();

      a.applyAcceleration(PVector.mult(dir, force / a.mass));
      b.applyAcceleration(PVector.mult(dir, -force / b.mass));
    }
  }

  for (Planet p : planets) {
    p.finishVelocityUpdate(DT);
    p.display();
  }

  fill(255);
  text("Simulation: Press R to restart.", 10, 20);
}


void drawArrow(PVector base, PVector vec, float arrowSize) {
  line(base.x, base.y, base.x + vec.x, base.y + vec.y);

  // Draw arrowhead
  pushMatrix();
  translate(base.x + vec.x, base.y + vec.y);
  float angle = atan2(vec.y, vec.x);
  rotate(angle);
  line(0, 0, -arrowSize, arrowSize / 2);
  line(0, 0, -arrowSize, -arrowSize / 2);
  popMatrix();
}

void mousePressed() {
  if (mode == SETUP) {

    // Check if clicking an existing planet
    for (Planet p : planets) {
      if (p.isMouseOver()) {
        selected = p;
        draggingVelocity = true;
        return;
      }
    }

    // Otherwise create a new planet
    planets.add(new Planet(new PVector(mouseX, mouseY), currentMass));
  }
}

void mouseReleased() {
  if (draggingVelocity && selected != null) {
    // Apply the velocity to the planet
    selected.velocity = selected.velocityPreview.copy().mult(0.04);
    draggingVelocity = false;
    selected = null;
  }
}

void mouseDragged() {
  if (mode == SETUP && selected != null) {
    // Update the preview vector while dragging
    selected.velocityPreview = PVector.sub(new PVector(mouseX, mouseY), selected.position);
  }
}

void keyPressed() {
  if (mode == SETUP) {
    if (keyCode == UP) currentMass += 10;

    if (keyCode == DOWN) currentMass = max(10, currentMass - 10);

    if (keyCode == ENTER) {
      mode = SIM;
    }
  }

  // Restart
  if (mode == SIM && key == 'r') {
    planets.clear();
    mode = SETUP;
  }
}
