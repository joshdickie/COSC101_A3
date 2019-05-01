/******************************************************************************

******************************************************************************/

//declare variables
boolean gameOver, pause, newRound;
boolean inForward, inReverse, inLeft, inRight, inSpacebar; //inputs
PVector shipPos, shipVel, shipDir;
PVector[] shotPos, shotVel;
PVector[] astroPos, astroVel;
float maxShipVel, shipAcc, shipDrag, shipScale, shotSpeed, shotLife, turn;
float sizeSmall, sizeMid, sizeLarge, minAstroVel, maxAstroVel; //asteroid stuff
int round;
float[] shotTime, astroSize;
PShape ship, asteroid;
// Note to self: if the screen keeps greying out and you don't know why it probably becuase you didn't
// define asteroidNum before making xArray, yArray and randArray
int asteroidNum = 20;
int asteroidPoint = 12;
float[][] xArray = new float[asteroidNum][asteroidPoint];
float[][] yArray = new float[asteroidNum][asteroidPoint];
float[][] randArray = new float[asteroidNum][asteroidPoint];
int randangle;
int radius;
boolean newGeneration;
int angleSeed;

void setup() {
    fullScreen();
    noCursor();

    //load images and set parameters based on image sizes

    //initialise variables
    asteroidNum = 20;
    round = 20;
    shipPos = new PVector(width/2, height/2); //starts in center of screen
    shipVel = new PVector();
    shipDir = new PVector(0, -1); //starts facing upwards
    shotPos = new PVector[0];
    shotVel = new PVector[0];
    astroPos = new PVector[0];
    astroVel = new PVector[0];
    astroSize = new float[0];
    shotTime = new float[0];
    shotSpeed = 30;
    shotLife = 1000; //lifespan of a friendly shot
    minAstroVel = 1;
    maxAstroVel = 10;
    maxShipVel = 20;
    shipAcc = 0.5;
    shipDrag = 0.99;
    shipScale = 50;
    turn = 0.1; //ship turning speed
    sizeSmall = shipScale/2;
    sizeMid = shipScale;
    sizeLarge = shipScale * 2;
    ship = createShape(TRIANGLE, shipScale, 0,
                                -shipScale/2, shipScale/2,
                                -shipScale/2, -shipScale/2);
    ship.rotate(shipDir.heading());
    asteroid = createShape(ELLIPSE, 0, 0, 1, 1); //unit circle, scaled later
    
    asteroidPoint = 12;
    radius=100;
    newGeneration = true;
    angleSeed = 60;
    
}


void draw() {
	if (astroPos.length < 1) {
		startRound();
	}
	if (newRound) {
    setAsteroids();
	}
    background(0);
    if (pause) {
        pauseMenu();
    }
    if (!gameOver) {
        shots();
        ship();
        asteroids();
        pickups();
    }
    hud();
    
}

void keyPressed() {
    getKey(key);
}

void keyReleased() {
    dropKey(key);
}

//functions

void getKey(int k) {
    /*
    handles and sorts key input
    */
    if (k == 'w' || k == 'W') {
        inForward = true;
    }
    if (k == 's' || k == 'S') {
        inReverse = true;
    }
    if (k == 'a' || k == 'A') {
        inLeft = true;
    }
    if (k == 'd' || k == 'D') {
        inRight = true;
    }
    if (k == ' ') {
        fire();
        inSpacebar = true;
    }
}

void dropKey(int k) {
    /*
    switches off key inputs
    */
    if (k == 'w' || k == 'W') {
        inForward = false;
    }
    if (k == 's' || k == 'S') {
        inReverse = false;
    }
    if (k == 'a' || k == 'A') {
        inLeft = false;
    }
    if (k == 'd' || k == 'D') {
        inRight = false;
    }
    if (k == ' ') {
        inSpacebar = false;
    }
}

void startRound() {
	/*
	counts down to the start of a new round. Maybe plays music?
	TODO
	*/
	newRound = true;
}

void ship() {
    /*
    handles ship behaviour, including:
        - movement
        - rotation/orientation
        - collision
        - screen wrapping
    */
    moveShip();
    drawShip();
}

void moveShip() {
    /*
    handles ship movement, rotation/orientation and screen wrapping
    */
    if (inForward) { //forward movement
        shipDir.normalize();
        shipDir.mult(shipAcc);
        shipVel.add(shipDir);
    } else if (inReverse) { //reverse movement
        shipDir.normalize();
        shipDir.mult(-1 * shipAcc);
        shipVel.add(shipDir);
        shipDir.mult(-1); //reset ship's direction after reversing
    }
    if (inLeft) { //left turn
        shipDir.rotate(-turn);
    }
    if (inRight) {// right turn
        shipDir.rotate(turn);
    }
    shipVel.limit(maxShipVel);
    shipPos.add(shipVel);
    shipVel.mult(shipDrag);

    if (shipPos.x + shipScale < 0 ||
        shipPos.x - shipScale > width ||
        shipPos.y + shipScale < 0 ||
        shipPos.y - shipScale > height) {
            shipWrap();
    }
}

void shipWrap() {
    /*
    handles ship screen wrapping
    //TODO: leaving screen, not coming back
    */
    if (shipPos.x + shipScale < 0) {
        shipPos.x = width + shipScale;
    } else if (shipPos.x - shipScale > width) {
        shipPos.x = 0 - shipScale;
    } else if (shipPos.y + shipScale < 0) {
        shipPos.y = height + shipScale;
    } else {
        shipPos.y = 0 - shipScale;
    }
}

void drawShip() {
    /*
    draws the ship
    */
    shape(ship, shipPos.x, shipPos.y);
    if (inLeft) {
        ship.rotate(-turn);
    }
    if (inRight) {
        ship.rotate(turn);
    }
}

void shots() {
    /*
    handles friendly projectile behaviour, including:
        - movement
        - collision
    */
    stroke(255);
    strokeWeight(4);
    for (int i = 0; i < shotPos.length; i++) {
        shotPos[i].add(shotVel[i]);
        point(shotPos[i].x, shotPos[i].y);
    }

    //wrap shots around screen
    for (int i = 0; i < shotPos.length; i++) {
      if (shotPos[i].x < 0 ||
        shotPos[i].x > width ||
        shotPos[i].y < 0 ||
        shotPos[i].y > height) {
          shotWrap(i);
      }
    }

    //erase shots once they reach their lifespan.
    //Loop is a bit superfluous, but it's good to be rock solid
    for (int i = 0; i < shotPos.length; i++) {
        if (millis() - shotTime[i] > shotLife) {
          shotErase(i);
        }
    }
}

void fire() {
    /*
    fires a new shot
    copies need to be used here - append() affects original vector
    */
    if (!inSpacebar) { //only one shot per keypress
        PVector newPos = new PVector();
        newPos = shipPos.copy();
        shotPos = (PVector[])append(shotPos, newPos);
        PVector newVel = new PVector();
        shipDir.normalize();
        newVel = shipDir.copy();
        newVel.mult(shotSpeed);
        newVel.add(shipVel); //adding ship's velocity appears more natural
        shotVel = (PVector[])append(shotVel, newVel);

        //note the shot's time of birth
        shotTime = append(shotTime, millis());
    }
}

void shotWrap(int i) {
  /*
  handles shot wrapping

  args: i - the index of the shot to be wrapped
  */
    if (shotPos[i].x < 0) {
        shotPos[i].x = width;
    } else if (shotPos[i].x > width) {
        shotPos[i].x = 0;
    } else if (shotPos[i].y < 0) {
        shotPos[i].y = height;
    } else {
        shotPos[i].y = 0;
    }

}

void shotErase(int i) {
  /*
  erases shots that have surpassed their lifespan

  args: i - the index of the shot to be erased
  */
  shotPos[i] = shotPos[shotPos.length - 1];
  shotPos = (PVector[])shorten(shotPos);
  shotVel[i] = shotVel[shotVel.length - 1];
  shotVel = (PVector[])shorten(shotVel);
  shotTime[i] = shotTime[shotTime.length - 1];
  shotTime = shorten(shotTime);
}

void setAsteroids () {
	/*
	sets a new round's worth of asteroids in place at the edges of the screen
	TODO
	*/
	for (int i = 0; i < asteroidNum; i++) {
		PVector newPos = new PVector(/*TODO: coin flip for left or right of screen*/ 0, random(height));
		astroPos = (PVector[])append(astroPos, newPos);
		PVector newVel = new PVector(random(-1, 1), random(-1, 1));
		newVel.normalize();
		newVel.mult(random(minAstroVel, maxAstroVel));
		astroVel = (PVector[])append(astroVel, newVel);
		astroSize = append(astroSize, sizeLarge);

		newRound = false;
}

/*
James: used to generate a set of random numbers unique to each asteroid.
uses boolean newGeneration so it only occurs once a round.
*/
  if (newGeneration) {
    for (int i = 0; i < asteroidNum; i++) {
      for (int j = 0; j < asteroidPoint; j++) {
        randangle = (int) random(angleSeed*j-angleSeed, j*angleSeed);
        randArray[i][j] = randangle; 
      }
    }
    newGeneration = false;
  }
}

void asteroids() {
    /*
    handles asteroid behaviour, including:
        - movement
        - collision
        - screen wrapping
    */
    moveAsteroids();
    drawAsteroids();
}

void moveAsteroids() {
  /*
  handles asteroid movement
  */
    for (int i = 0; i < astroPos.length; i++) {
        astroPos[i].add(astroVel[i]);
    }

    //wrap astroids around screen
    for (int i = 0; i < astroPos.length; i++) {
      if (astroPos[i].x + astroSize[i] < 0 ||
        astroPos[i].x - astroSize[i] > width ||
        astroPos[i].y + astroSize[i] < 0 ||
        astroPos[i].y - astroSize[i] > height) {
          astroWrap(i);
      }
    }
}

void drawAsteroids() {
  /*
  draws asteroids to the screen
  */

  generateAsteroids();
  for (int i = 0; i < astroPos.length; i++) {
      beginShape();
      vertex(xArray[i][0], yArray[i][0]);
      vertex(xArray[i][1], yArray[i][1]);
      vertex(xArray[i][2], yArray[i][2]);
      vertex(xArray[i][3], yArray[i][3]);
      vertex(xArray[i][4], yArray[i][4]);
      vertex(xArray[i][5], yArray[i][5]);
      vertex(xArray[i][6], yArray[i][6]);
      vertex(xArray[i][7], yArray[i][7]);
      vertex(xArray[i][8], yArray[i][8]);
      vertex(xArray[i][9], yArray[i][9]);
      vertex(xArray[i][10], yArray[i][10]);
      vertex(xArray[i][11], yArray[i][11]);
      endShape(CLOSE);
      }
}

void generateAsteroids() {
   /*
   Generates the points for the randomly generated asteroids.
   
   */
   for (int i = 0; i < astroPos.length; i++) {
      for (int j = 0; j < asteroidPoint; j++) {
        
    xArray[i][j] = astroPos[i].x + int(cos(radians(randArray[i][j])) * radius);
    yArray[i][j] = astroPos[i].y + int(sin(radians(randArray[i][j])) * radius);
      }
  }
  
}

void astroWrap(int i) {
	/*
	handles asteroid wrapping
	args: i - the index of the astroid being wrapped
	*/

// James: changes the astrosize to radius for testing. we will need 
// a radius array when we start adding multple asteroids
    if (astroPos[i].x < 0) {
        astroPos[i].x = width + radius; 
    } else if (astroPos[i].x > width) {
        astroPos[i].x = 0 - radius;
    } else if (astroPos[i].y < 0) {
        astroPos[i].y = height + radius;
    } else {
        astroPos[i].y = 0 - radius;
    }
}

void collisionCheck() {
  /*
  checks for and handles collision of all kinds
  calls the appropriate function when collision is detected
  */

}

void pickups() {
    /*
    handles pickup behaviour, including:
        - movement
        - collision
    */
}

void hud() {
    /*
    handles hud elements, including:
        - score
        - hitpoints
    */
}

void pauseMenu() {
    /*
    handles pausing, displaying a menu when the game is paused.
    */
}

void startMenu() {
    /*
    displays a start screen upon running the sketch.
    */
}
