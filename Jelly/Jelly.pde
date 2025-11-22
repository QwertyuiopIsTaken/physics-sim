final int GRID_SIZE = 7;
final float ORB_MASS = 1;
final float SPRING_K = 0.1;
final float SPRING_DAMP = 0.1;
final float ORB_RADIUS = 20;
final float DT = 0.5;
final float GRAVITY = 0.2;
final float FLOOR_Y = 750;

ArrayList<Orb> orbs = new ArrayList<Orb>();
ArrayList<Spring> springs = new ArrayList<Spring>();

Orb dragged = null;  // Currently dragged orb

void setup() {
  size(750, 750);
  frameRate(60);

  // Create a grid of orbs
  float spacing = 80; // space between orbs
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      Orb o = new Orb(new PVector(200 + i*spacing, 100 + j*spacing), ORB_MASS);
      orbs.add(o);
    }
  }

  // Connect neighbors with springs
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      int idx = i * GRID_SIZE + j;
      Orb o = orbs.get(idx);

      // Connect right neighbor
      if (i < GRID_SIZE - 1) {
        springs.add(new Spring(o, orbs.get((i+1)*GRID_SIZE + j), SPRING_K, SPRING_DAMP));
      }

      // Connect bottom neighbor
      if (j < GRID_SIZE - 1) {
        springs.add(new Spring(o, orbs.get(i*GRID_SIZE + (j+1)), SPRING_K, SPRING_DAMP));
      }
    }
  }
  
  // Shear springs
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      int idx = i * GRID_SIZE + j;
      Orb o = orbs.get(idx);
      
      if (i < GRID_SIZE - 1 && j < GRID_SIZE - 1) {
        springs.add(new Spring(o, orbs.get((i+1)*GRID_SIZE + j+1), SPRING_K, SPRING_DAMP));
      }
      if (i < GRID_SIZE - 1 && j > 0) {
        springs.add(new Spring(o, orbs.get((i+1)*GRID_SIZE + j-1), SPRING_K, SPRING_DAMP));
      }
    }
  }
}

void draw() {
  background(0);

  // Apply gravity
  for (Orb o : orbs) {
    o.applyForce(new PVector(0, GRAVITY * o.mass));
  }

  // Apply spring forces
  for (Spring s : springs) {
    s.apply();
  }

  // Update positions
  for (Orb o : orbs) {
    o.update(DT);

    // Floor collision
    if (o.pos.y > FLOOR_Y - ORB_RADIUS) {
      o.pos.y = FLOOR_Y - ORB_RADIUS;
      o.vel.y *= -0.5; // bounce
    }
  }

  // Draw springs
  for (Spring s : springs) {
    s.display();
  }

  // Draw orbs
  for (Orb o : orbs) {
    o.display();
  }
}

void mousePressed() {
  for (Orb o : orbs) {
    if (PVector.dist(new PVector(mouseX, mouseY), o.pos) < ORB_RADIUS) {
      dragged = o;
      break;
    }
  }
}

void mouseDragged() {
  if (dragged != null) {
    dragged.pos.set(mouseX, mouseY);
    dragged.vel.set(0, 0);
  }
}

void mouseReleased() {
  dragged = null;
}
