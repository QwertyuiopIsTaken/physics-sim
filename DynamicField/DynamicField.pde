import java.util.Iterator;
Utility ut = new Utility();

final int FIELD_INTERVALS = 20;
final int ARROW_HEAD_SIZE = 5;
final int ARROW_LENGTH = 15;
final int TIME_STEP = 1000; // in millisecond
final boolean DISPLAY_WAVE = false;

ArrayList<Particle> particles = new ArrayList<>();
ArrayList<Propagation> props = new ArrayList<>();
FieldPoint[][] fieldPoints;

Particle selected = null;

void setup() {
  size(1000, 600);
  frameRate(120);
  
  fieldPoints = new FieldPoint[width/FIELD_INTERVALS + 1][height/FIELD_INTERVALS + 1];
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
  
  for (Particle p : particles) {
    p.display();
  }
  
  Iterator<Propagation> iterator = props.iterator();
  while (iterator.hasNext()) {
    Propagation pr = iterator.next();
    if (pr.radius >= 1000) {
      iterator.remove();
    } else {
      if (DISPLAY_WAVE) {
        pr.display();
      }
      pr.radius++;
    }
  }
  
  dragParticle();
  updateField();
}

void dragParticle() {
  if (selected != null) {
    PVector newPos = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(newPos, selected.pos).normalize();
    dir.add(selected.pos);
    
    if (!selected.pos.equals(newPos)) {
      props.add(new Propagation(selected.pos.x, selected.pos.y, -selected.charge, false));
      selected.pos = dir;
      props.add(new Propagation(dir.x, dir.y, selected.charge, true));
    }
  }
}

void updateField() {
  for (int i = 0; i < fieldPoints.length; i++) {
    for (int j = 0; j < fieldPoints[0].length; j++) {
      PVector fieldPos = new PVector(i * FIELD_INTERVALS, j * FIELD_INTERVALS);
      
      for (Propagation pr : props) {
        if (pr.containsPoint(fieldPos.x, fieldPos.y)) {
          PVector netForce = new PVector(0, 0);
          if (fieldPoints[i][j] != null) {
            netForce = fieldPoints[i][j].netForce;
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
  for (Particle p : particles) {
    if (p.isClicked(mouseX, mouseY)) {
      selected = p;
      return;
    }
  }
  
  if (mouseButton == LEFT) {
    particles.add(new Particle(mouseX, mouseY, 5));
    
  } else {
    particles.add(new Particle(mouseX, mouseY, -5));
  }
  float charge = particles.get(particles.size() - 1).charge;
  props.add(new Propagation(mouseX, mouseY, charge, true));
}
