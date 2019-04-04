/******************************************************************************

******************************************************************************/

//declare variables
boolean gameOver, pause;
boolean forward, reverse, left, right;
PVector shipPos, shipVel, shipDir;
float maxVel, shipAcc, shipScale;
PShape ship;

void setup() {
    fullScreen();
    noCursor();

    //load images and set parameters based on image sizes

    //initialise variables
    shipPos = new PVector(width/2, height/2);
    shipVel = new PVector();
    shipDir = new PVector(0, -1);
    maxVel = 5;
    shipAcc = 0.1;
    shipScale = 50;
    ship = createShape(TRIANGLE, shipScale, 0, -shipScale/2, shipScale/2, -shipScale/2, -shipScale/2);
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
    getKey(keyCode);
}

void keyReleased() {
    dropKey(key);
}

//functions

void getKey(int k) {
    if (k == 'w' || k == 'W') {
        forward = true;
    }
    if (k == 's' || k == 'S') {
        reverse = true;
    }
    if (k == 'a' || k == 'A') {
        left = true;
    }
    if (k == 'd' || k == 'D') {
        right = true;
    }
}

void dropKey(int k) {
    if (k == 'w' || k == 'W') {
        forward = false;
    }
    if (k == 's' || k == 'S') {
        reverse = false;
    }
    if (k == 'a' || k == 'A') {
        left = false;
    }
    if (k == 'd' || k == 'D') {
        right = false;
    }
}

void ship() {
    /*
    handles ship behaviour, including:
        - movement
        - rotation/orientation
        - collision
        - screen wrapping
        - firing projectiles
    */
    moveShip();
    drawShip();
}

void moveShip() {
    if (forward) {
        shipDir.normalize();
        shipDir.mult(shipAcc);
        shipVel.add(shipDir);
    } else if (reverse) {
        shipDir.normalize();
        shipDir.mult(-1 * shipAcc);
        shipVel.add(shipDir);
        shipDir.mult(-1); //reset ship's direction after reversing
    }
    if (left) {
        shipDir.rotate(-0.1);
        ship.rotate(-0.1);
    }
    if (right) {
        shipDir.rotate(0.1);
        ship.rotate(0.1);
    }
    shipVel.limit(maxVel);
    shipPos.add(shipVel);
    if (shipPos.x < 0 ||
        shipPos.x > width ||
        shipPos.y < 0 ||
        shipPos.y > height) {

        shipWrap();
    }
}

void shipWrap() {
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
    shape(ship, shipPos.x, shipPos.y);
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