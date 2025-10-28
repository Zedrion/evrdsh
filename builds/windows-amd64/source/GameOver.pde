float CRASHED_TEXT_SIZE = 800;

float AGAIN_BUTTON_X = 770;
float MENU_BUTTON_X = 1150;

void drawCrash() {
  pushMatrix();
  // Freeze cube
  vx = 0;
  vy = 0;

  // Slow camera to stop
  cameraSpeed *= 0.95;  
  if (cameraSpeed < 0.1) cameraSpeed = 0; 
  updateCamera();
  
  if (lastGame == Game.Invert) {
    pushMatrix();
    // draw background
    translate(0, GROUND_HEIGHT/2); // make the ground y=0
    drawBackground();
    popMatrix();
  }  
  else drawBackground();
  
  translate(0, height);
  scale(1,-1);
  pushMatrix();
  translate(-cameraX, -cameraY);
  if (lastGame == Game.Normal) translate(0, GROUND_HEIGHT);
  else if (lastGame == Game.Invert) translate(0, GROUND_HEIGHT/2);
  generateObstacles();
  updateObstacles();
  drawObstacles();
  //updateCube(); // stops all cube updates
  drawCube();
  if (lastGame == Game.Normal) {
    updateGround(); 
    drawGround();
  }
  popMatrix();
  
  // Draw red translucent foreground to dim background
  noStroke();
  fill(75, 0, 0, 200); 
  rectMode(CORNER);
  rect(0,0, width, height);
  
  updateScore();
  drawUI();
  
  pushMatrix(); pushStyle();
  translate(0, height);
  scale(1,-1);

  // "CRASHED" text
  textSize(TITLE_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(100,0,0);
  text("C R A S H E D", width/2, height/2);
  
  // "again" button
  fill(0,0,0,120);
  rectMode(CENTER);
  rect(AGAIN_BUTTON_X, height/2, BUTTON_W, BUTTON_H);

  textSize(BUTTON_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(255,255,255);
  text("again", AGAIN_BUTTON_X, height/2);
  
  // "menu" button
  fill(0,0,0,120);
  rectMode(CENTER);
  rect(MENU_BUTTON_X, height/2, BUTTON_W, BUTTON_H);

  textSize(BUTTON_TEXT_SIZE);
  textAlign(CENTER, CENTER);
  fill(255,255,255);
  text("menu", MENU_BUTTON_X, height/2);
  
  highlightCrashButtons();
  
  popMatrix(); popStyle();
  popMatrix();
}

// Called by mousePressed, handles mouse presses in the menu
void mousePressedCrash() {
  
  // Check if mouse is on AGAIN button
  if (mouseX > AGAIN_BUTTON_X - BUTTON_W/2 && mouseX < AGAIN_BUTTON_X + BUTTON_W/2 && 
      mouseY > height/2 - BUTTON_H/2 && mouseY < height/2 + BUTTON_H/2) {
    
    // Start Normal game or Invert game
    if (lastGame == Game.Normal) {
      resetVariables(Screen.Normal);
      screen = Screen.Normal;
    }
    else if (lastGame == Game.Invert) {
      resetVariables(Screen.Invert);
      screen = Screen.Invert;
    }
  }
  
  // Check if mouse is on MENU button  
  if (mouseX > MENU_BUTTON_X - BUTTON_W/2 && mouseX < MENU_BUTTON_X + BUTTON_W/2 && 
      mouseY > height/2 - BUTTON_H/2 && mouseY < height/2 + BUTTON_H/2) {

    screen = Screen.Menu;
  }
}

void highlightCrashButtons() {
  // Check if mouse is on AGAIN button
  if (mouseX > AGAIN_BUTTON_X - BUTTON_W/2 && mouseX < AGAIN_BUTTON_X + BUTTON_W/2 && 
      mouseY > height/2 - BUTTON_H/2 && mouseY < height/2 + BUTTON_H/2) {
    
    // Darker "AGAIN" button
    fill(0,0,0);
    rectMode(CENTER);
    rect(AGAIN_BUTTON_X, height/2, BUTTON_W, BUTTON_H);
  
    textSize(BUTTON_TEXT_SIZE);
    textAlign(CENTER, CENTER);
    fill(255,255,255);
    text("AGAIN", AGAIN_BUTTON_X, height/2);
  }
  
  // Check if mouse is on MENU button  
  if (mouseX > MENU_BUTTON_X - BUTTON_W/2 && mouseX < MENU_BUTTON_X + BUTTON_W/2 && 
      mouseY > height/2 - BUTTON_H/2 && mouseY < height/2 + BUTTON_H/2) {
    
    // Darker "MENU" button
    fill(0,0,0);
    rectMode(CENTER);
    rect(MENU_BUTTON_X, height/2, BUTTON_W, BUTTON_H);
  
    textSize(BUTTON_TEXT_SIZE);
    textAlign(CENTER, CENTER);
    fill(255,255,255);
    text("MENU", MENU_BUTTON_X, height/2);
  }
}
