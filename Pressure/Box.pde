class Box {
  final int SIZE = 250;        // Side length of the square box
  PVector position;            // Box center position
  PVector velocity;            // Current velocity of the box
  PVector acceleration;        // Acceleration applied to the box (gravity)
  float mass;                  // Mass of the box
  
  Box() {
    position = new PVector(width / 2, height / 2 - SIZE / 4);
    velocity = new PVector(0, 0);
    acceleration = gravity;
    mass = 1;
  }
  
  Box(float m) {
    this();
    mass = m;
  }
  
  void display() {
    stroke(0);
    strokeWeight(5);
    noFill();
    rectMode(CENTER);
    rect(position.x, position.y, SIZE, SIZE);
  }
  
  void run() {
    position.add(velocity);
    velocity.add(acceleration);
  }
}
