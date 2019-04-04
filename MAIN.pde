/******************************************************************************

******************************************************************************/

//declare variables
boolean gameOver, pause;
boolean inForward, inReverse, inLeft, inRight; //movement inputs
PVector shipPos, shipVel, shipDir;
float maxVel, shipAcc, shipDrag, shipScale;
PShape ship;

void setup() {
    fullScreen();
    noCursor();

    //load images and set parameters based on image sizes

    //initialise variables
    shipPos = new PVector(width/2, height/2); //starts in center of screen
    shipVel = new PVector();
    shipDir = new PVector(0, -1); //starts facing upwards
    maxVel = 5;
    shipAcc = 0.1;
    shipDrag = 0.99;
    shipScale = 50;
    ship = createShape(TRIANGLE, shipScale, 0,
                                -shipScale/2, shipScale/2,
                                -shipScale/2, -shipScale/2);
    ship.rotate(shipDir.heading());
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
        shipDir.rotate(-0.1);
    }
    if (inRight) {// right turn
        shipDir.rotate(0.1);
    }
    shipVel.limit(maxVel);
    shipPos.add(shipVel);
    shipVel.mult(shipDrag);

    if (shipPos.x < 0 ||
        shipPos.x > width ||
        shipPos.y < 0 ||
        shipPos.y > height) {

        shipWrap();
    }
}

void shipWrap() {
    /*
    handles ship screen wrapping
    */
    if (shipPos.x < 0) {
        shipPos.x = width;
    } else if (shipPos.x > width) {
        shipPos.x = 0;
    } else if (shipPos.y < 0) {
        shipPos.y = height;
    } else {
        shipPos.y = 0;
    }
}

void drawShip() {
    /*
    draws the ship
    */
    shape(ship, shipPos.x, shipPos.y);
    if (inLeft) {
        ship.rotate(-0.1);
    }
    if (inRight) {
        ship.rotate(0.1);
    }
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