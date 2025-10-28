void drawInvertGame() {
  pushMatrix();
  
  // update camera 
  updateCamera();
  
  pushMatrix();
  // draw background
  translate(0, GROUND_HEIGHT/2); // make the ground y=0
  drawBackground();
  popMatrix();
  
  // Make Processing treat (0,0) as bottom left, and make ground level 0
  translate(0, height);
  scale(1,-1);
  pushMatrix();
  
  // move camera (before drawing the foreground)
  translate(-cameraX, -cameraY);
  translate(0, GROUND_HEIGHT/2); // make the ground y=0

  // procedural generation: spawn, update, draw obstacles
  generateObstacles();
  updateObstacles();
  drawObstacles();
  
  updateCube();
  drawCube();

  // reset transformation matrix 
  popMatrix();
  
  // update score 
  updateScore();
  
  // draw UI
  drawUI();
  
  popMatrix();
}

void keyPressedInvert() {
  if (key == ' ' && onSurface && !inJump()) {
    gravDir *= -1;
    jump();
  } 
}
