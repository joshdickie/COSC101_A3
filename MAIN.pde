/******************************************************************************

******************************************************************************/

//declare variables
boolean gameOver, pause;

void setup() {
	fullscreen();
	noCursor();

	//load images and set parameters based on image sizes

	//initialise variables
}


void draw() {
	background(0);
	if (pause) {
		pauseMenu();
	}
	if (!gameOver) {
		ship();
		asteroids();
		pickups();
	}
	hud();
}

//functions
void ship() {
	/*
	handles ship behaviour, including:
		- movement
		- rotation/orientation
		- collision
		- screen wrapping
		- firing projectiles
	*/
}

void shots() {
	/*
	handles friendly projectile behaviour, including:
		- movement
		- collision
	*/
}

void asteroids() {
	/*
	handles asteroid behaviour, including:
		- movement
		- collision
		- screen wrapping
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