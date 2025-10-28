float BUTTON_W = 350;
float BUTTON_H = 100;
float BUTTON_TEXT_SIZE = 75;

float TITLE_TEXT_Y = 370;
float HIGHSCORE_TEXT_Y = 550;
float NORMAL_BUTTON_Y = 660;
float INVERT_BUTTON_Y = 790;

float TITLE_TEXT_SIZE = 400;
float HIGHSCORE_TEXT_SIZE = 50;

float MENU_BACKGROUND_SPEED_MULTIPLIER = 0.5;

float menuFrame = 0;
String[] titleSeq = {
  "evrdsh"//,
  //"Evrdsh",
  //"eVrdsh",
  //"evRdsh",
  //"evrDsh",
  //"evrdSh",
  //"evrdsH"
};

void drawMenu() {
  pushMatrix();
  pushStyle();

  // Draw parallax background moving slower than in-game
  cameraX += MOVE_SPEED * MENU_BACKGROUND_SPEED_MULTIPLIER;
  pushMatrix(); pushStyle();
  translate(0,GROUND_HEIGHT);
  drawBackground();
  popMatrix(); popStyle();
  
  // Draw translucent foreground to dim background
  fill(0, 0, 0, 120); 
  rectMode(CORNER);
  rect(0,0, width, height);

  // Draw title and buttons
  // Title
  //textSize(TITLE_TEXT_SIZE);
  //textAlign(CENTER, CENTER);
  //fill(207, 255, 4);
  //text("evrdsh", width/2, TITLE_TEXT_Y);
  drawTitle();
  
  // "HIGHSCORE"
  textSize(HIGHSCORE_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(255,255,255);
  text("HIGHSCORE          " + normalHighscore + "          " + invertHighscore, width/2, HIGHSCORE_TEXT_Y);

  // "normal" button
  fill(0,0,0,120);
  rectMode(CENTER);
  rect(width/2, NORMAL_BUTTON_Y, BUTTON_W, BUTTON_H);
  
  // "normal" text
  textSize(BUTTON_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(255,255,255);
  text("normal", width/2, NORMAL_BUTTON_Y);

  // "invert" button
  fill(0,0,0,120);
  rectMode(CENTER);
  rect(width/2, INVERT_BUTTON_Y, BUTTON_W, BUTTON_H);

  // "invert" text
  textSize(BUTTON_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(255,255,255);
  text("invert", width/2, INVERT_BUTTON_Y);

  highlightMenuButtons(); 

  popMatrix();
  popStyle();
}

void drawTitle() {
  // Calculate which title to show based on menuFrame
  int titleIndex = (int)(menuFrame / 20  ) % titleSeq.length;
  String currentTitle = titleSeq[titleIndex];
  
  // Draw the animated title
  textSize(TITLE_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(207, 255, 4);
  text(currentTitle, width/2, TITLE_TEXT_Y);
  
  // Increment frame counter
  menuFrame++;
}

// Called by mousePressed, handles mouse presses in the menu
void mousePressedMenu() {
  
  // Check if mouse is on Normal button
  if (mouseX > width/2 - BUTTON_W/2 && mouseX < width/2 + BUTTON_W/2 && 
      mouseY > NORMAL_BUTTON_Y - BUTTON_H/2 && mouseY < NORMAL_BUTTON_Y + BUTTON_H/2) {
    
    // Start Normal game
    resetVariables(Screen.Normal);
    lastGame = Game.Normal;
    screen = Screen.Normal;
  }
  
  // Check if mouse is on Invert button  
  if (mouseX > width/2 - BUTTON_W/2 && mouseX < width/2 + BUTTON_W/2 && 
      mouseY > INVERT_BUTTON_Y - BUTTON_H/2 && mouseY < INVERT_BUTTON_Y + BUTTON_H/2) {
    
    // Start Invert game
    resetVariables(Screen.Invert);
    lastGame = Game.Invert;
    screen = Screen.Invert;
  }
}

void highlightMenuButtons() {
  // Check if mouse is on Normal button
  if (mouseX > width/2 - BUTTON_W/2 && mouseX < width/2 + BUTTON_W/2 && 
      mouseY > NORMAL_BUTTON_Y - BUTTON_H/2 && mouseY < NORMAL_BUTTON_Y + BUTTON_H/2) {
    
    // Darker "invert" button
    fill(0,0,0);
    rectMode(CENTER);
    rect(width/2, NORMAL_BUTTON_Y, BUTTON_W, BUTTON_H);
  
    // "normal" text
    textSize(BUTTON_TEXT_SIZE);
    textAlign(CENTER, CENTER);
    fill(255,255,255);
    text("NORMAL", width/2, NORMAL_BUTTON_Y);
  }
  
  // Check if mouse is on Invert button  
  if (mouseX > width/2 - BUTTON_W/2 && mouseX < width/2 + BUTTON_W/2 && 
      mouseY > INVERT_BUTTON_Y - BUTTON_H/2 && mouseY < INVERT_BUTTON_Y + BUTTON_H/2) {
    
    // Darker "invert" button
    fill(0,0,0);
    rectMode(CENTER);
    rect(width/2, INVERT_BUTTON_Y, BUTTON_W, BUTTON_H);
  
    // "invert" text
    textSize(BUTTON_TEXT_SIZE);
    textAlign(CENTER, CENTER);
    fill(255,255,255);
    text("INVERT", width/2, INVERT_BUTTON_Y);
  }
}
