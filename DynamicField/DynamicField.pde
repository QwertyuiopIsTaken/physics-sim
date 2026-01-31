import java.util.Iterator;
Utility ut = new Utility();

final int FIELD_INTERVALS = 20;
final int ARROW_HEAD_SIZE = 5;
final int ARROW_LENGTH = 15;
final boolean OPTIMIZE = true; // turn off optimization for increased accuracy
final boolean DISPLAY_WAVE = false;
int WAVE_LIFESPAN;

ArrayList<Particle> particles = new ArrayList<>();
ArrayList<Propagation> props = new ArrayList<>();
FieldPoint[][] fieldPoints;

Particle selected = null;

void setup() {
  size(1200, 800);
  frameRate(240);
  
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
  
  for (Particle p : particles) {
    p.display();
  }
  
  Iterator<Propagation> iterator = props.iterator();
  while (iterator.hasNext()) {
    Propagation pr = iterator.next();
    if (pr.radius >= pr.lifespan) {
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
  props.add(new Propagation(mouseX, mouseY, charge, true, WAVE_LIFESPAN));
}
