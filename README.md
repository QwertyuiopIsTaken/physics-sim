# physics-sim

Collection of simple physic simulations created from Newtonian mechanics.

* [Jelly](#jelly)
* [N-Body Problem](#n-body-problem)
* [Gravity](#gravity)
* [Pressure](#pressure)

## Jelly

Simulates soft-body matter using spring force.

A grid of orbs/particles are connected to its adjacent and diagonal neighbors. The diagonal spring creates a shear force that prevents the block from collapsing on itself.

This simulation, however, can be improved by adding self collision to prevent the orbs from going pass a certain length.

### Controls

* **Mouse Left Click**: When hovering over an orb, moves it to the mouse's position

***

## N-Body Problem

Simulates gravity and motion of celestial bodies.

Gravitational force is calculated using mass and distance between two points. The net force is then used to find the acceleration on a mass. Finally, the Euler's method can be used to find the velocity and position every frame.

However, when there are more than two masses, the position of the objects become extremely difficult to predict. There are numerical solutions to N-body systems like the Lagrange equilateral triangle, but many others devolve into a chaotic behavior.

While this simulation is not entirely precise, it models the general picture of what the motion of masses may look like. Imprecision is mostly due to floating point inaccuracy and the reliance on discrete points in time (limited by the frame rate) to calculate position and velocity.

### Controls

* **Up/down arrows**: Increases/decreases mass of object during setup mode
* **R**: Returns to setup mode
* **1,2,3,4,5**: Selects preset systems
* **Enter**: Starts simulation mode
* **Mouse Left Click**: When hovering over an object, creates an initial velocity

***

## Gravity

Simulates gravity and motion of celestial bodies.

Gravitational force is calculated using mass and distance between two points. The net force is then used to find the acceleration on a mass. Finally, the Euler's method can be used to find the velocity and position every frame.

Unlike the previous simulation, this one uses leapfrog integration to increase the precision of celestial mechanics.

### Controls

* **Up/down arrows**: Increases/decreases mass of object during setup mode
* **R**: Returns to setup mode
* **1,2,3,4,5**: Selects preset systems
* **Enter**: Starts simulation mode
* **Mouse Left Click**: When hovering over an object, creates an initial velocity

***

## Pressure

Simulates pressure using particles of different density.

Collision between particles are elastic. This creates a force on the box from all directions.  When gravity is on, the pressure at the bottom of the box is greater than the pressure at the top. This causes a buoyant force, and since the weight of the box + gas is less than the buoyant force, the box has a net upward force.

A bit of energy is loss when colliding with the borders, which can be changed. You can also tweak the mass of the box as well as the density of the gases to get different results. The internal gas is also colored based on their velocity. Red means high velocity and blue means low velocity.

### Controls

* **Space**: Pauses the simulation

***

## Installation

1. Install Processing
2. Run the corresponding driver file for each folder
