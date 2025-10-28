void drawNormalGame() {
  pushMatrix();
  // update camera 
  updateCamera();
  
  // draw background
  drawBackground();
  
  // Make Processing treat (0,0) as bottom left, and make ground level 0
  translate(0, height);
  scale(1,-1);
  pushMatrix();
  
  // move camera (before drawing the foreground)
  translate(-cameraX, -cameraY);
  translate(0, GROUND_HEIGHT); // make the ground y=0

  // procedural generation: spawn, update, draw obstacles
  generateObstacles();
  updateObstacles();
  drawObstacles();
  
  updateCube();
  drawCube();
  
  updateGround();
  drawGround();


  // reset transformation matrix 
  popMatrix();
  
  // update score 
  updateScore();
  
  // draw UI
  drawUI();
  popMatrix();
}

void mousePressedGame() {
  
}

void keyPressedGame() {
  if (key == ' ' && onSurface && !inJump()) {
    jump();
  } 
}
