Utility ut = new Utility();

final int FIELD_INTERVALS = 25;
final int ARROW_HEAD_SIZE = 5;
final int ARROW_LENGTH = 15;
final boolean OPTIMIZE = false; // turn off optimization for increased accuracy
final boolean DISPLAY_WAVE = false;
int WAVE_LIFESPAN;

ArrayList<Particle> particles = new ArrayList<>();
ArrayList<Propagation> props = new ArrayList<>();
FieldPoint[][] fieldPoints;

Particle selected = null;

void setup() {
  size(1200, 800);
  frameRate(120);
  
  fieldPoints = new FieldPoint[width/FIELD_INTERVALS + 1][height/FIELD_INTERVALS + 1];
  WAVE_LIFESPAN = max(width, height);
}

void draw() {
  background(10);
  
  for (int i = 0; i < fieldPoints.length; i++) {
    for (int j = 0; j < fieldPoints[0].length; j++) {
      if (fieldPoints[i][j] == null) {
        continue;
      }
      
      PVector fieldPos = new PVector(i * FIELD_INTERVALS, j * FIELD_INTERVALS);
      PVector netForce = fieldPoints[i][j].netForce;
      ut.drawArrow(fieldPos, netForce, ARROW_HEAD_SIZE, ARROW_LENGTH);
    }
  }
  
  for (int i = props.size() - 1; i >= 0; i--) {
    Propagation pr = props.get(i);
    if (pr.radius >= pr.lifespan) {
      props.remove(i);
    } else {
      if (DISPLAY_WAVE) {
        pr.display();
      }
      pr.radius++;
    }
  }
  
  for (Particle p : particles) {
    p.display();
  }
  
  dragParticle();
  updateField();
}

void dragParticle() {
  if (selected != null) {
    PVector newPos = new PVector(mouseX, mouseY);
    if (!selected.pos.equals(newPos)) {
      PVector dir = PVector.sub(newPos, selected.pos);
      
      // Optimization trick
      int span = WAVE_LIFESPAN;
      if (OPTIMIZE) {
        if (props.size() > 0) {
          Propagation lastProp = props.get(props.size() - 1);
          if (lastProp.propagate == true && lastProp.pos.equals(selected.pos) && frameCount - 1 == lastProp.frame) {
            props.remove(props.size() - 1);
            span = 0;
          }
        }
      }
      
      props.add(new Propagation(selected.pos.x, selected.pos.y, -selected.charge, false, span));
      
      if (dir.mag() <= 0.5) { // snap it to the mouse position
        selected.pos.x = mouseX;
        selected.pos.y = mouseY;
        props.add(new Propagation(mouseX, mouseY, selected.charge, true, WAVE_LIFESPAN));
      } else {
        dir.normalize();
        dir.add(selected.pos);
        selected.pos.x = dir.x;
        selected.pos.y = dir.y;
        props.add(new Propagation(dir.x, dir.y, selected.charge, true, WAVE_LIFESPAN));
      }
    }
  }
}

void updateField() {
  for (Propagation pr : props) {
    float minX = pr.pos.x - pr.radius;
    float maxX = pr.pos.x + pr.radius;
    float minY = pr.pos.y - pr.radius;
    float maxY = pr.pos.y + pr.radius;
    
    int col = fieldPoints.length - 1;
    int row = fieldPoints[0].length - 1;
    
    int startI = max(0, floor(minX / FIELD_INTERVALS));
    int endI = min(col, ceil(maxX / FIELD_INTERVALS));
    
    int startJ = max(0, floor(minY / FIELD_INTERVALS));
    int endJ = min(row, ceil(maxY / FIELD_INTERVALS));
    
    for (int i = startI; i <= endI; i++) {
      for (int j = startJ; j <= endJ; j++) {
        PVector fieldPos = new PVector(i * FIELD_INTERVALS, j * FIELD_INTERVALS);
        if (pr.containsPoint(fieldPos.x, fieldPos.y)) {
          PVector netForce;
          if (fieldPoints[i][j] != null) {
            netForce = fieldPoints[i][j].netForce;
          } else {
            netForce = new PVector(0, 0);
          }
          
          netForce.add(ut.calcElectrostaticForce(pr.sourceCharge, pr.pos, fieldPos));
          fieldPoints[i][j] = new FieldPoint(netForce);
        }
      }
    }
  }
}

void mouseReleased() {
  if (selected != null) {
    selected = null;
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    for (Particle p : particles) {
      if (p.isClicked(mouseX, mouseY)) {
        selected = p;
        return;
      }
    }
  }
  
  float charge = 5;
  if (mouseButton == RIGHT) {
    charge = -5;
  }
  particles.add(new Particle(mouseX, mouseY, charge));
  props.add(new Propagation(mouseX, mouseY, charge, true, WAVE_LIFESPAN));
}
