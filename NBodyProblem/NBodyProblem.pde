// Physical constants
final int SETUP = 0;
final int SIM = 1;
int mode = SETUP;

ArrayList<Planet> planets;

float currentMass = 1;

float SIM_MASS_SCALE = 1;  // makes gravity stronger/weaker
float DT = 0.1;

Planet selected = null;  // planet currently being edited
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
  // Reset accelerations
  for (Planet p : planets) {
    p.acc.mult(0);
  }

  for (int i = 0; i < planets.size(); i++) {
    Planet a = planets.get(i);

    for (int j = i + 1; j < planets.size(); j++) {
      Planet b = planets.get(j);

      PVector r = PVector.sub(b.position, a.position);
      float distSq = max(r.magSq(), 0.1);  // avoid division by zero
      float forceMag = SIM_MASS_SCALE * a.mass * b.mass / distSq;
      PVector force = r.copy().normalize().mult(forceMag * DT);
      
      // Apply to both planets
      a.applyForce(force);
      b.applyForce(force.mult(-1));
    }
  }

  // Update positions
  for (Planet p : planets) {
    p.update();
    p.display();
    p.velocityPreview.mult(0); // hide preview
  }

  fill(255);
  text("Simulation mode: Press R to restart.", 10, 20);
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
    selected.velocity = selected.velocityPreview.copy().mult(0.005);
    draggingVelocity = false;
    selected = null;
    // Keep the preview visible until simulation starts
  }
}

void mouseDragged() {
  if (mode == SETUP && selected != null) {
    // Update the preview vector while dragging
    selected.velocityPreview = PVector.sub(new PVector(mouseX, mouseY), selected.position);
  }
}

// call loadPreset(n) while in SETUP mode (e.g. press keys '1'..'5')
void loadPreset(int n) {
  planets.clear();
  
  // center for placing presets
  PVector C = new PVector(width/2, height/2);
  float scale = 120;    // geometric scale (pixels)
  float velScale = 0.01; // velocity scale (pixels/frame) — tweak this to stabilize

  if (n == 1) {
    // 1) Lagrange equilateral triangle (three equal masses rotating)
    // place at vertices of an equilateral triangle, give tangential velocities
    
    float m = 10; // simulation mass
    float r = scale;
    PVector A = PVector.add(C, new PVector(-r, 0));
    PVector B = PVector.add(C, new PVector(r * 0.5, r * 0.8660254)); // cos/sin 60°
    PVector Cpos = PVector.add(C, new PVector(r * 0.5, -r * 0.8660254));
    // velocities: perpendicular to radius from center, same magnitude (for rotation)
    PVector vA = PVector.sub(A, C).rotate(HALF_PI).normalize().mult(velScale);
    PVector vB = PVector.sub(B, C).rotate(HALF_PI).normalize().mult(velScale);
    PVector vC = PVector.sub(Cpos, C).rotate(HALF_PI).normalize().mult(velScale);
    planets.add(new Planet(A, m)); planets.get(0).velocity = vA;
    planets.add(new Planet(B, m)); planets.get(1).velocity = vB;
    planets.add(new Planet(Cpos, m)); planets.get(2).velocity = vC;

  } else if (n == 2) {
    // 2) Figure-8 choreography (Moore/Chenciner) — approximate, rescaled
    // dimensionless initial conditions (classic): scale them so they fit the window
    
    float m = 10;
    
    // dimensionless positions from the known solution
    PVector p1 = new PVector( 0.97000436, -0.24308753);
    PVector p2 = new PVector(-0.97000436,  0.24308753);
    PVector p3 = new PVector( 0.0,  0.0);
    
    // dimensionless velocities (approx)
    PVector v1 = new PVector( 0.4662036850,  0.4323657300);
    PVector v2 = new PVector( 0.4662036850,  0.4323657300);
    PVector v3 = PVector.mult(PVector.add(v1, v2), -1);

    // scale positions & velocities to pixels / pixels/frame
    float posScale = scale * 1.1;   // tune so figure fits screen
    float velScaleF = 8.5 * velScale; // tune for stability

    planets.add(new Planet(PVector.add(C, PVector.mult(p1, posScale)), m));
    planets.get(0).velocity = PVector.mult(v1, velScaleF);

    planets.add(new Planet(PVector.add(C, PVector.mult(p2, posScale)), m));
    planets.get(1).velocity = PVector.mult(v2, velScaleF);

    planets.add(new Planet(PVector.add(C, PVector.mult(p3, posScale)), m));
    planets.get(2).velocity = PVector.mult(v3, velScaleF);

  } else if (n == 3) {
    // 3) Collinear Euler-like configuration (two large masses and a small one between)
    // Two heavy bodies on either side and a small one in the middle
    
    float M = 200;
    float m = 8;
    PVector left = PVector.add(C, new PVector(-scale*1.6f, 0));
    PVector right = PVector.add(C, new PVector(scale*1.6f, 0));
    PVector mid = PVector.add(C, new PVector(0, 0));
    planets.add(new Planet(left, M)); planets.get(0).velocity = new PVector(0, -0.15f);
    planets.add(new Planet(right, M)); planets.get(1).velocity = new PVector(0, 0.15f);
    planets.add(new Planet(mid, m)); planets.get(2).velocity = new PVector(0.0f, 0.0f);

  } else if (n == 4) {
    // 4) Binary + small third: a binary pair orbited by a lighter third body
    
    float big = 20;
    float small = 1;
    PVector b1 = PVector.add(C, new PVector(-scale*0.7f, 0));
    PVector b2 = PVector.add(C, new PVector(scale*0.7f, 0));
    PVector s  = PVector.add(C, new PVector(0, scale*1.4f));
    
    // binary tangential velocities (opposite)
    planets.add(new Planet(b1, big)); planets.get(0).velocity = new PVector(0, -0.03f);
    planets.add(new Planet(b2, big)); planets.get(1).velocity = new PVector(0,  0.03f);
    planets.add(new Planet(s, small)); planets.get(2).velocity = new PVector(0.04f, 0);
  } else if (n == 5) {
    // 5) 3-4-5 triangle
    planets.add(new Planet(new PVector(width/4, 4*150 + 100), 1)); // Planet A
    planets.add(new Planet(new PVector(width/4 + 3*150, 4*150 + 100), 1)); // Planet B
    planets.add(new Planet(new PVector(width/4, 100), 1)); // Planet C
  }
}

// helper to compute total mass
float totalMass(ArrayList<Planet> ps) {
  float s = 0;
  for (Planet p : ps) s += p.mass;
  return s;
}

void keyPressed() {
  if (mode == SETUP) {
    if (keyCode == UP) currentMass += 1;
    
    if (keyCode == DOWN) currentMass = max(1, currentMass - 1);

    if (keyCode == ENTER) {
      mode = SIM;
    }
    
    // Load presets with number keys
    if (key == '1') {
      loadPreset(1);
    }
    if (key == '2') {
      loadPreset(2);
    }
    if (key == '3') {
      loadPreset(3);
    }
    if (key == '4') {
      loadPreset(4);
    }
    if (key == '5') {
      loadPreset(5);
    }
  }

  // Restart
  if (mode == SIM && key == 'r') {
    planets.clear();
    mode = SETUP;
  }
}
