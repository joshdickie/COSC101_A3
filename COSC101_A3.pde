/******************************************************************************
	COSC101 ASSIGNMENT 3
		Joshua Dickie	- 220195992
		James Batten	- 220191816
		Linda Blamey	- 220164366

	This sketch is our group's take on the classic Atari game, Asteroids.
	The aim of the player is to earn points by destroying asteroids, while
	avoiding being hit by them.

	In order to run this sketch, ensure that the sketch's 'data' folder
	contains the following files:
					- OCRAExtended-30.vlw
					- startScreen.png
					- pew.wav
					- hit.wav
	Additionally, ensure that the following processing libraries have been
	installed:
					- Sound (The Processing Foundation)

		Last Updated: 22/05/2019
		Processing Version: 3.5.3
******************************************************************************/

import processing.sound.*;

/********************declare variables********************/

//system
PImage startScreen;
PFont font;
SoundFile sfx;
boolean gameStart, paused, gameOver, newRound;
	//hud
	int livesInitial, lives, round, score;
	//inputs
	boolean inForward, inReverse, inRight, inLeft, inSpacebar, inY, inN;

//ship
PVector shipPos, shipVel, shipDir;
PShape ship, shield;
boolean shipRespawn;
float shipScale, shipVelMax, shipAcc, shipDrag, shipTurn, iFrames, iCounter;

//shots
PVector[] shotPos, shotVel;
float[] shotTime;
float shotSpeed, shotLife;

//asteroids
PVector[] astroPos, astroVel;
float[] astroSize;
float astroSizeSmall, astroSizeMid, astroSizeLarge, astroVelMin, astroVelMax;
int astroNumInitial, astroSplitNum;

//ufo
int ufoScale, ufoStartPos, eventChance, ufoRadius;
int ufoSpawnRand, ufoSpawnLimit, ufoShotRand, ufoShotLimit;
float ufoShotSize, ufoShotSpeed;
PShape ufoShape;
PVector ufoPos, ufoVel, ufoShotPos, ufoShotVel;
boolean ufoEvent, ufoShotEvent;


/*********************************************************/


void setup() {
	fullScreen();
	noCursor();

	/**********************load assets**********************/

	startScreen = loadImage("startScreen.png");
	startScreen.resize(width, height);
	font = loadFont("OCRAExtended-30.vlw");

	/*******************************************************/


	/******************initialise variables*****************/

	//system
	gameStart= true;
	livesInitial = 3;
	lives = livesInitial;

	//ship
	shipPos = new PVector(width/2, height/2);
	shipVel = new PVector();
	shipDir = new PVector(0, -1); //starts facing upwards
	shipVelMax = 10;
	shipAcc = 0.5;
	shipDrag = 0.99;
	shipScale = height/20;
	shipTurn = 0.1; //turning speed
	iFrames = 100; // invincibility frames after respawn
	ship = createShape(TRIANGLE, shipScale, 0,
										-shipScale/2, shipScale/2,
										-shipScale/2, -shipScale/2);
	ship.rotate(shipDir.heading());
	shield = createShape(ELLIPSE, 0, 0, shipScale*2.5, shipScale*2);
	shield.rotate(shipDir.heading());
	shield.setStroke(color(0, 100, 255));
	shield.setFill(color(0, 50, 150));

	//shots
	shotPos = new PVector[0];
	shotVel = new PVector[0];
	shotTime = new float[0];
	shotSpeed = 30;
	shotLife = 1000; //lifespan of a shot

	//asteroids
	astroPos = new PVector[0];
	astroVel = new PVector[0];
	astroSize = new float[0];
	astroSizeSmall = shipScale;
	astroSizeMid = shipScale * 2;
	astroSizeLarge = shipScale * 3;
	astroVelMin = 5;
	astroVelMax = 10;
	astroNumInitial = 5; //starting number of asteroids
	astroSplitNum = 2; //number of asteroids a hit asteroid splits into

	//ufo
	ufoStartPos = int(random(100, height-100));
	ufoScale = 7;
	ufoPos = new PVector(0, ufoStartPos);
	ufoVel = new PVector(2.5, 2.5);
	ufoEvent = false; 
	ufoSpawnRand = 500; // random number added to num of frames to spawn ufo
	ufoSpawnLimit = 1000; // number of frames until ufo spawns
	ufoRadius = 50;
	eventChance = 0; // counter for frames. used to determine if events occur
	ufoShotPos = new PVector();
	ufoShotVel = new PVector();
	ufoShotRand = 1000;
	ufoShotLimit = 950;
	ufoShotSpeed = 5;
	ufoShotSize = shipScale/2;

	/*******************************************************/
}

void draw() {
	background(0);

	if (gameStart) {
		startScreen();

	} else if (gameOver) {
		gameOverScreen();

	} else if (paused) {
		pauseScreen();
		hud();

	} else if (shipRespawn) {
		shipRespawn();
		shots();
		astros();
		if (ufoEvent) {
			ufo();
		}
		events();
		hud();

	} else { //main game loop
		if (astroPos.length < 1) {
			newRound();
		}
		if (ufoEvent) {
			ufo();
		}
		ship();
		shots();
		astros();
		if (ufoEvent) {
			ufo();
		}
		if (ufoShotEvent) {
			ufoShot();
		}
		events();
		hud();
	}
}

void keyPressed() {
	getKey(key);
}

void keyReleased() {
	dropKey(key);
}

/************************functions************************/

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
		fire(); //using the fire function here prevents rapidfire behaviour
		inSpacebar = true;
	}
	if (k == 'p' || k == 'K') {
		paused = !paused;
	}
	if (k == 'y' || k == 'Y') {
		inY = true;
	}
	if (k == 'n' || k == 'N') {
		inN = true;
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
	if (k == 'y' || k == 'Y') {
		inY = false;
	}
	if (k == 'n' || k == 'N') {
		inN = false;
	}
}

void startScreen() {
	/*
	displays a simple welcome screen upon starting the game
	*/
	image(startScreen, 0, 0);
	fill(255);
	int unit = height/12;
	if (inSpacebar) {
		gameStart = false;
	}
}

void gameOverScreen() {
	/*
	draws a heads-up display to the screen
	*/
	fill(255);
	textFont(font, height/12);
	textAlign(CENTER, CENTER);
	text("GAME OVER", width/2, height * 1/3);
	text("SCORE: " + score, width/2, height/2);
	text("play again? Y/N", width/2, height * 2/3);

	if (inY) {
		gameReset();
	} else if (inN) {
		exit();
	}
}

void pauseScreen() {
	/*
	displays a simple pause screen and pauses the game
	*/
	shotDraw();
	astroDraw();
	shipDraw();

	rectMode(CENTER);
	stroke(0);
	fill(0);
	rect(width/2, height/2, width/4, height/6);
	fill(255);
	textFont(font, height/12);
	textAlign(CENTER, CENTER);
	text("PAUSED", width/2, height/2);
}

void hud() {
	/*
	displays a game over screen, showing the player their score
	and prompting them to play again
	*/
	fill(255);
	textFont(font, height/12);
	textAlign(LEFT, TOP);
	text("score:" + score, 100, 100);
	text("lives:" + lives, 100, height/12 + 100);
}

void gameReset() {
	/*
	sets all relevant variables to their start-of-game values
	used for starting new game
	*/
	gameStart = true;
	paused = false;
	gameOver = false;
	newRound = false;
	shipRespawn = false;
	lives = livesInitial;
	round = 1;
	score = 0;
	shipPos.set(width/2, height/2);
	shipVel.set(0, 0);
	shipDir.set(0, -1);
	ship = createShape(TRIANGLE, shipScale, 0,
										-shipScale/2, shipScale/2,
										-shipScale/2, -shipScale/2);
	ship.rotate(shipDir.heading());
	shield = createShape(ELLIPSE, 0, 0, shipScale*2.5, shipScale*2);
	shield.rotate(shipDir.heading());
	shield.setStroke(color(0, 100, 255));
	shield.setFill(color(0, 50, 150));
	ufoPos.x = width;
	ufoShotEvent = false;

	while (shotPos.length > 0) {
		shotErase(0);
	}
	while (astroPos.length > 0) {
		astroErase(0);
	}
}

void newRound() {
	/*
	begins a new round, incrementing the round count and setting new asteroids
	*/
	astroSet();
	round +=1;
}

void astroSet() {
	/*
	sets a new round's worth of asteroids.
	Asteroids are set at a random height, on either the left or right side
	Number of asteroids is partly determined by the round number
	*/
	int astroNum = astroNumInitial + round*2;
	for (int i = 0; i < astroNum; i++) {
		PVector newPos = new PVector((random(1)>0.5 ? 0:width),random(height));
		astroPos = (PVector[])append(astroPos, newPos);
		PVector newVel = new PVector(random(-1, 1), random(-1, 1));
		newVel.normalize();
		astroVel = (PVector[])append(astroVel, newVel);
		astroSize = append(astroSize, astroSizeLarge);

		newRound = false;
	}
}

void ship() {
	/*
	handles ship behaviour
	*/
	shipMove();
	shipDraw();
	shipCollision();
}

void shipMove() {
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
	if (inRight) { //right turn
		shipDir.rotate(shipTurn);
	}

	shipVel.limit(shipVelMax);
	shipVel.mult(shipDrag);
	shipPos.add(shipVel);

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

void shipDraw() {
	/*
	draws the ship to the screen
	*/
	if (shipRespawn) { //i-frame indicator (shield)
		shape(shield, shipPos.x, shipPos.y);
	}
	shape(ship, shipPos.x, shipPos.y);
	if (inLeft && !paused) {
		ship.rotate(-shipTurn);
		shield.rotate(-shipTurn);
	}
	if (inRight && !paused) {
		ship.rotate(shipTurn);
		shield.rotate(shipTurn);
	}
}

void shipCollision() {
	/*
	checks for and handles collision of the ship with ateroids, ufo and ufo shot
	*/
	PVector ship;
	PVector astro;
	PVector ufo;
	PVector ufoShot;

	//asteroids
	for (int i = 0; i < astroPos.length; i++) {
		ship = shipPos.copy();
		astro = astroPos[i].copy();
		if ((ship.sub(astro)).mag() <= astroSize[i]) {
			shipHit();
		}
	}

	//ufo
	ship = shipPos.copy();
	ufo = ufoPos.copy();
	if ((ship.sub(ufo)).mag() <= ufoRadius) {
		shipHit();
	}

	//ufo shot
	ship = shipPos.copy();
	ufoShot = ufoShotPos.copy();
	if ((ship.sub(ufoShot)).mag() <= ufoShotSize) {
		ufoShotEvent = false;
		shipHit();
	}
}

void shipHit() {
	/*
	handles game behaviour when the ship has collided with an asteroid
	*/
	sfx = new SoundFile(this, "hit.wav");
	sfx.play();

	while (shotPos.length > 0) {
		shotErase(0); //erase all shots
	}

	shipRespawn = true;
	lives--;
	if (lives < 1) {
		gameOver = true;
	}

	shipPos.x = width/2;
	shipPos.y = height/2;

	ufoShotEvent = false;
}

void shipRespawn() {
	/*
	handles ship behaviour shortly after respawn
	*/
	shipMove();
	shipDraw();
	iCounter++;
	if (iCounter >= iFrames) {
		shipRespawn = false;
		iCounter = 0;
	}
}

void fire() {
	/*
	fires a new shot
	*/
	if (!inSpacebar) { //only one shot per keypress
		sfx = new SoundFile(this, "pew.wav");
		sfx.play();

		PVector ship = shipPos.copy();
		shotPos = (PVector[])append(shotPos, ship);
		shipDir.normalize();
		PVector newVel = new PVector();
		newVel = shipDir.copy();
		newVel.mult(shotSpeed);
		newVel.add(shipVel); //adding ship's velocity looks natural
		shotVel = (PVector[])append(shotVel, newVel);

		//note the shot's time of birth
		shotTime = append(shotTime, millis());
	}
}

void shots() {
	/*
	handles friendly projectilve behaviour
	*/
	shotMove();
	shotDraw();
}

void shotMove() {
	/*
	handles shot movement
	*/
	for (int i = 0; i < shotPos.length; i++) {
		shotPos[i].add(shotVel[i]);
	}

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
	erases a shot, removing all data pertaining to it
	args: i - the index of the shot to be erased
	*/
	shotPos[i] = shotPos[shotPos.length - 1];
	shotPos = (PVector[])shorten(shotPos);
	shotVel[i] = shotVel[shotVel.length - 1];
	shotVel = (PVector[])shorten(shotVel);
	shotTime[i] = shotTime[shotTime.length - 1];
	shotTime = shorten(shotTime);
}

void shotDraw() {
	/*
	draws shots to the screen
	*/
	stroke(255);
	strokeWeight(4);
	for (int i = 0; i < shotPos.length; i++) {
		point(shotPos[i].x, shotPos[i].y);
	}
}

void astros() {
	/*
	handles asteroid behaviour
	*/
	astroMove();
	astroDraw();
	astroCollision();
}

void astroMove() {
	/*
	handles asteroid movement
	*/
	for (int i = 0; i < astroPos.length; i++) {
		astroPos[i].add(astroVel[i]);
	}

	for (int i = 0; i < astroPos.length; i++) {
		if (astroPos[i].x + astroSize[i] < 0 ||
			astroPos[i].x - astroSize[i] > width ||
			astroPos[i].y + astroSize[i] < 0 ||
			astroPos[i].y - astroSize[i] > height) {
				astroWrap(i);
		}
	}
}

void astroWrap(int i) {
	/*
	handles asteroid wrapping
	args: i - the index of the asteroid being wrapped
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

void astroDraw() {
	/*
	draws asteroids to the screen
	*/
	stroke(255);
	fill(0);
	strokeWeight(4);
	for (int i = 0; i < astroPos.length; i++) {
		ellipse(astroPos[i].x, astroPos[i].y, astroSize[i], astroSize[i]);
	}
}

void astroCollision() {
	/*
	checks for and handles collision between shots and asteroids
	*/
	for (int i = 0; i < shotPos.length; i++) {
		for (int j = 0; j < astroPos.length; j++) {
			PVector shot = shotPos[i].copy();
			PVector astro = astroPos[j].copy();

			if ((shot.sub(astro)).mag() <= astroSize[j]) {
				shotErase(i);
				astroHit(j);
				break; //only one collision per frame, or loop out of bounds
			}
		}
	}
}

void astroHit(int i) {
	/*
	handles game behaviour when an asteroid is hit by a shot
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
	spawns an asteroid of a smaller size at the location of a given asteroid
	args: i - the index of the asteroid which has been hit
	*/
	PVector pos = astroPos[i].copy();
	astroPos = (PVector[])append(astroPos, pos);

	PVector vel = astroVel[i].copy();
	PVector newVel = PVector.random2D();
	newVel.mult(random(astroVelMin, astroVelMax));
	vel.add(newVel); //random child vel added to parent vel
	astroVel = (PVector[])append(astroVel, vel);

	if (astroSize[i] == astroSizeLarge) {
		astroSize = append(astroSize, astroSizeMid);
	} else {
		astroSize = append(astroSize, astroSizeSmall);
	}
}

void astroErase(int i) {
	/*
	erases an asteroid
	args: i - the index of the asteroid to be erased
	*/
	astroPos[i] = astroPos[astroPos.length - 1];
	astroPos = (PVector[])shorten(astroPos);
	astroVel[i] = astroVel[astroVel.length - 1];
	astroVel = (PVector[])shorten(astroVel);
	astroSize[i] = astroSize[astroSize.length - 1];
	astroSize = shorten(astroSize);
}

void ufo() {
	/*
	handles ufo behaviour once it's spawned
	*/
	if (ufoPos.x < width) {
		stroke(255);
		noFill();
		beginShape();
			vertex(ufoPos.x-10*ufoScale, ufoPos.y);
			vertex(ufoPos.x-5*ufoScale, ufoPos.y+2*ufoScale);
			vertex(ufoPos.x+5*ufoScale, ufoPos.y+2*ufoScale);
			vertex(ufoPos.x+10*ufoScale, ufoPos.y);
			vertex(ufoPos.x-10*ufoScale, ufoPos.y);
			vertex(ufoPos.x-5*ufoScale, ufoPos.y-2*ufoScale);
			vertex(ufoPos.x+5*ufoScale, ufoPos.y-2*ufoScale);
			vertex(ufoPos.x+10*ufoScale, ufoPos.y);
			vertex(ufoPos.x+5*ufoScale, ufoPos.y-2*ufoScale);
			vertex(ufoPos.x+2*ufoScale, ufoPos.y-4*ufoScale);
			vertex(ufoPos.x-2*ufoScale, ufoPos.y-4*ufoScale);
			vertex(ufoPos.x-5*ufoScale, ufoPos.y-2*ufoScale);
		endShape();

		if (ufoPos.y > ufoStartPos + width/10 || ufoPos.y<ufoStartPos - width/10 ){
			ufoVel.y *= -1;
		}
		
		ufoPos.add(ufoVel);
		
	} else {		
		ufoEvent = false;
		eventChance = 0;
		ufoPos.x = 0;
		ufoPos.y = random(width/10, height - width/10);
	}
	ufoCollision();
}

void ufoCollision() {
	/*
	checks for and handles ufo collision with friendly shots
	*/
	for (int i = 0; i < shotPos.length; i++) {
		PVector shot = shotPos[i].copy();
		PVector ufo = ufoPos.copy();
		if ((shot.sub(ufo)).mag() <= ufoRadius) {
			shotErase(i);
			ufoHit();
		}
	}
}

void ufoHit() {
	/*
	handles game behaviour when the ufo is hit by a friendly shot
	*/
	ufoPos.x = width;
	score += 5;
} 

void ufoShot() {
	/*
	handles ufo shot behaviour
	*/
	ufoShotMove();
	ufoShotDraw();
	ufoShotCollision();
}

void ufoShotMove() {
	/*
	handles ufo shot movement
	*/
	PVector shot = ufoShotPos.copy();
	PVector ship = shipPos.copy();
	ufoShotVel.set(ship.sub(shot));
	ufoShotVel.setMag(ufoShotSpeed);

	ufoShotPos.add(ufoShotVel);
}

void ufoShotDraw() {
	/*
	draws the ufo shot to the screen
	*/
	stroke(255);
	fill(0);
	strokeWeight(4);
	ellipse(ufoShotPos.x, ufoShotPos.y, ufoShotSize, ufoShotSize);
}

void ufoShotCollision() {
	/*
	checks for and handles collision between ufo shot and friendly shots
	*/
	for (int i = 0; i < shotPos.length; i++) {
		PVector shot = shotPos[i].copy();
		PVector ufoShot = ufoShotPos.copy();
		if ((shot.sub(ufoShot)).mag() <= ufoShotSize) {
			shotErase(i);
			ufoShotHit();
		}
	}
}

void ufoShotHit() {
	/*
	handles game behaviour when the ufo shot is hit
	*/
	ufoShotEvent = false;
}

void events() {
	/*
	handles random event chances for:
		- ufo
		- ufo shot
	*/
	eventChance++;

	//ufo
	if (eventChance+random(ufoSpawnRand) > ufoSpawnLimit && !ufoEvent) {
		ufoEvent = true;
		ufoStartPos = int(random(width/10, height - width/10));
		ufoPos.y = ufoStartPos;
	}

	//ufo shot
	if (ufoEvent && !ufoShotEvent && !shipRespawn &&
			random(ufoShotRand) > ufoShotLimit) {
				ufoShotEvent = true;
				ufoShotPos.set(ufoPos);
	}
}

/*********************************************************/