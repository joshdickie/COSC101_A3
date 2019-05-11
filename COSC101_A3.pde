/******************************************************************************
	COSC101 ASSIGNMENT 3
		Joshua Dickie	- 220195992
		James Batten	- 220191816
		Linda Blamey	- 220164366

	This sketch is our group's take on the classic Atari game, Asteroids.
	The aim of the player is to earn points by destroying asteroids, while
	avoiding being hit by them.

	In order to run this sketch, ensure that the sketch's folder contains the
	following files:
					- blah.png
					- blah_blah.mp3
					- whatever.ttf

	Changelog:
		wrote header text, cleaned up program commenting, format, etc. (Josh)
    made asteroids spawn on both sides of the screen (Josh)
    Added score in top left hand corner and added font to make it look 'oldschool' (Linda)
    font should be uploaded into data of sketch (Linda)
    Added lives but this needs to be worked on - would prefer 3 triangles than a number (Linda)
    Also currently allows number to go into negative as opposed to GameOver at 0 as has not yet been worked on (Linda)
    
		Last Updated: 11/05/2019
		Processing Version: 3.5.3
******************************************************************************/

//declare variables

//system
boolean gameOver, pause, newRound;
boolean inForward, inReverse, inLeft, inRight, inSpacebar; //inputs
int round, score, lives;
PFont font;

//ship
PVector shipPos, shipVel, shipDir;
float shipVelMax, shipAcc, shipDrag, shipScale, shipTurn;
PShape ship;
boolean shipHit, shipRespawn;
//shots
PVector[] shotPos, shotVel;
float[] shotTime;
float shotSpeed, shotLife;

//asteroids
PVector[] astroPos, astroVel;
float[] astroSize;
float astroSizeSmall, astroSizeMid, astroSizeLarge, astroVelMin, astroVelMax;
int astroSplitNum;


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

int total_time = 0;
int time_start = 0;
int time_lapsed = 0;


void setup() {
	fullScreen();
	noCursor();
  font = loadFont("OCRAExtended-30.vlw");

	//load images and set parameters based on image sizes

	//initialise variables

	//system
	round = 1;
  lives = 3;

	//ship
	shipPos = new PVector(width/2, height/2);
	shipVel = new PVector();
	shipDir = new PVector(0, -1); //starts facing upwards
	shipVelMax = 10;
	shipAcc = 0.5;
	shipDrag = 0.99;
	shipScale = 50;
	shipTurn = 0.1; //turning speed
	ship = createShape(TRIANGLE, shipScale, 0,
					-shipScale/2, shipScale/2,
					-shipScale/2, -shipScale/2);
	ship.rotate(shipDir.heading());
  shipHit = false;
  shipRespawn = false;
  
	//shots
	shotPos = new PVector[0];
	shotVel = new PVector[0];
	shotTime = new float[0];
	shotSpeed = 30;
	shotLife = 1000; //lifespan of a friendly shot

	//asteroids
	astroPos = new PVector[0];
	astroVel = new PVector [0];
	astroSize = new float[0];
	astroSizeSmall = shipScale;
	astroSizeMid = shipScale * 2;
	astroSizeLarge = shipScale * 4;
	astroVelMin = 1;
	astroVelMax = 5;
	astroSplitNum = 2; //number of asteroids that a hit asteroid splits into


	asteroidNum = 5;
	asteroidPoint = 12;
	radius=100;
	newGeneration = true;
	angleSeed = 60;

}


void draw() {
	background(0);
  textFont(font, 30);
  text (score, 100,100);
  text ("lives", 45, 150);
  text (lives, 150,150);


	if (astroPos.length < 1) {
		startRound();
	}

	if (pause) {
		pauseMenu();
	}

	if (!gameOver) {
		
		shots();
		ship();
    if (!shipRespawn) {
    collisionCheck();
    }
		asteroids();
    
	}
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
	begins a new round
	*/
	round += 1;
	setAsteroids();
}

void ship() {
	/*
	handles ship behaviour
	*/
  if (!shipRespawn) {
	moveShip();
  }
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
		shipDir.rotate(-shipTurn);
	}
		if (inRight) {// right turn
		shipDir.rotate(shipTurn);
	}

	shipVel.limit(shipVelMax);
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
		ship.rotate(-shipTurn);
	}
	if (inRight) {
		ship.rotate(shipTurn);
	}
}

void shots() {
	/*
	handles friendly projectile behaviour.
	*/
	stroke(255);
	strokeWeight(4);
	for (int i = 0; i < shotPos.length; i++) {
		shotPos[i].add(shotVel[i]);
		point(shotPos[i].x, shotPos[i].y);
	}

	//wrap shots
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
		PVector newPos = shipPos.copy();
		shotPos = (PVector[])append(shotPos, newPos);
		shipDir.normalize();
		PVector newVel = new PVector();
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
	*/
	for (int i = 0; i < round; i++) {
    //asteroids are set at a random height, on either the right or left side
		PVector newPos = new PVector((random(1)>0.5 ? 0:width), random(height));
		astroPos = (PVector[])append(astroPos, newPos);
		PVector newVel = new PVector(random(-1, 1), random(-1, 1));
		newVel.normalize();
		newVel.mult(random(astroVelMin, astroVelMax));
		astroVel = (PVector[])append(astroVel, newVel);
		astroSize = append(astroSize, astroSizeLarge);

		newRound = false;
	}


//James: used to generate a set of random numbers unique to each asteroid.
//     uses boolean newGeneration so it only occurs once a round.
     
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
/*

	stroke(255);
	fill(255);
	strokeWeight(4);
	for (int i = 0; i < astroPos.length; i++) {
		ellipse(astroPos[i].x, astroPos[i].y, astroSize[i], astroSize[i]);
	}
}

*/
void generateAsteroids() {
   
   //Generates the points for the randomly generated asteroids.

    for (int i = 0; i < astroPos.length; i++) {
        for (int j = 0; j < asteroidPoint; j++) {

            xArray[i][j] = astroPos[i].x + int(cos(radians(randArray[i][j])) * astroSize[i]);
            yArray[i][j] = astroPos[i].y + int(sin(radians(randArray[i][j])) * astroSize[i]);
        }
    }
}


void astroWrap(int i) {
	/*
	handles asteroid wrapping
	args: i - the index of the astroid being wrapped
	*/

	if (astroPos[i].x + astroSize[i] < 0) {
		astroPos[i].x = width + astroSize[i];
	} else if (astroPos[i].x - astroSize[i] > width) {
		astroPos[i].x = 0 - astroSize[i];
	} else if (astroPos[i].y + astroSize[i] < 0) {
		astroPos[i].y = height + astroSize[i];
	} else {
		astroPos[i].y = 0 - astroSize[i];
	}
}

void collisionCheck() {
	/*
	checks for and handles collision of all kinds
	calls the appropriate function when collision is detected
	*/
  //TODO: FORMATTING, loop containing more than it should
  for (int k = 0; k < astroPos.length; k++) {
    PVector ship = shipPos.copy();
    PVector astro = astroPos[k].copy();
    if ((ship.sub(astro)).mag() < astroSize[k]) {
         //println("Over" + k);
         shipReset();
    } else {
      shipHit = false;
      //println("NOT OVER");
    }
    
	int[] hits = new int[0];
	for (int i = 0; i < shotPos.length; i++) {
		for (int j = 0; j < astroPos.length; j++) {
			PVector shot = shotPos[i].copy();
			astro = astroPos[j].copy();
      
     
			if ((shot.sub(astro)).mag() < astroSize[j]) {
				shotErase(i);
				astroHit(j);
      	break; //only one collision per frame, or loop goes out of bounds
      }
		}
	}
	}
}

void astroHit(int i) {
	/*
	handles behaviour of an asteroid which has been hit by a shot
	args: i - the index of the asteroid which has been hit
	*/
	if (astroSize[i] != astroSizeSmall) {
		for (int j = 0; j < astroSplitNum; j++) {
			astroSplit(i);
		}
	}
	astroErase(i);
	score += 1;
}

void astroSplit(int i) {
	/*
	spawns two asteroids of a smaller size at the location of a given asteroid
	args: i - the index of the asteroid which has been hit
	*/
	PVector pos = astroPos[i].copy();
	astroPos = (PVector[])append(astroPos, pos);

	PVector vel = astroVel[i].copy();
  //random child velocity is added to parent velocity
	PVector newVel = PVector.random2D();
	newVel.mult(random(astroVelMin, astroVelMax));
	vel.add(newVel);
	astroVel = (PVector[])append(astroVel, vel);
  /********* TODO ********
  Add radmonly generated angles for child asteroids
  They are currently being recycled right now.
  *************************/

	if (astroSize[i] == astroSizeLarge) {
		astroSize = append(astroSize, astroSizeMid);
	} else {
		astroSize = append(astroSize, astroSizeSmall);
	}
}

void astroErase(int i) {
	/*
	erases an asteroid that has been hit.
	TODO: add like a sound or animation or something
	*/
	astroPos[i] = astroPos[astroPos.length - 1];
	astroPos = (PVector[])shorten(astroPos);
	astroVel[i] = astroVel[astroVel.length - 1];
	astroVel = (PVector[])shorten(astroVel);
	astroSize[i] = astroSize[astroSize.length - 1];
	astroSize = shorten(astroSize);
}

void shipReset() {
    
      shipRespawn = true; 
      /**************** TO DO *******************
      add timer so ship doesn't move or detects collisions for 
      2 secs. color effects would also be good.
      ********************/
      shipPos.x = width/2;
      shipPos.y = height/2;
      shipRespawn = false;
      lives--;
}

void pickups() {
	/*
	handles pickup behaviour.
	*/
}

void hud() {
	/*
	handles hud elements.
	*/
 text ("lives", 45, 150);
 text (lives, 150,150);
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
