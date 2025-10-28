color[] layerColors = {
  color(75,0,119),
  color(127,19,189),
  color(173,83,225),
  color(177,111,219),
  color(179,131,204),
  color(199,149,230)
};

// {x, y, w, h} of all member rectangles in layer 
float[][] layer1 = {
  {0, 0, 349, 524},
  {349, 0, 262, 349},
  {611, 0, 314, 611},
  {925, 0, 349, 698},
  {1274, 0, 436, 489},
  {1710, 0, 210, 558}
};
float[][] layer2 = {
  {0, 0, 560, 810},
  {560, 0, 650, 516},
  {1210, 0, 710, 675}
};
float[][] layer3 = {
  {1348, 0, 180, 907}
};
float[][] layer4 = {
  {840, 690, 285, 246},
  {1018, 841, 221, 153}
};
float[][] layer5 = {
  {246, 858, 100, 100},
  {304, 821, 167, 92},
  {603, 535, 205, 76},
  {705, 440, 126, 221}
};
float[][] layer6 = {
  {0,0,1921,1080+GROUND_HEIGHT}
};
ArrayList<float[][]> layers = new ArrayList<>();  // Layers are added in ascending order of depth in setup()  



void drawBackground() {
  
  pushMatrix(); pushStyle();

  // Make Processing treat (0,0) as bottom left, and make ground level 0
  translate(0, height);
  scale(1,-1);

  // Draw parallax layers 
  for (int layer=layers.size()-1; layer>=0; layer--) {

    int depth = layer+1;
    noStroke();
    fill(layerColors[layer]);

    for (float[] r : layers.get(layer)) {
      float x = r[0];
      float y = r[1];  
      float w = r[2];
      float h = r[3];
      drawParallaxObject(x, y, w, h, depth);
    }  
  }  
  
  popMatrix(); popStyle();
}

// Can only draw rectangular objects
// Draws two copies of the same object at camera step and step+1
void drawParallaxObject(float x, float y, float w, float h, int depth) {
  int step = (int)cameraX / int(width*depth);
  int world_x = step*width*depth;
  int world_x2 = (step+1)*width*depth;
  float drawX1 = (world_x - cameraX) / depth;
  float drawX2 = (world_x2 - cameraX) / depth;
  rect(drawX1+x, y, w, h);
  rect(drawX2+x, y, w, h);
}
