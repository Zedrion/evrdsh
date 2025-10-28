enum Type {Platform}

class Obstacle {
  float x, y, w, h, grav;
  Type type;
  
  Obstacle(float x, float y, float w, float h, float grav, Type type) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.grav = grav;
    this.type = type;
  }

  void draw() {
    fill(OBSTACLE_COLOR);
    strokeWeight(1);
    stroke(OBSTACLE_OUTLINE_COLOR);
    rect(x, y, w, h);
  }

  boolean offscreen() {
    return x + w < cameraX - OBSTACLE_UPDATE_OFFSET;
  }
  
  String toString() {
    return "x: " + this.x + ", y: " + this.y + ", w: " + this.w + ", h: " + this.h + ", yLand: " + ((this.grav == 1) ? this.y+this.h+CUBE_SIZE/2 : this.y-CUBE_SIZE/2) + ", grav: " + this.grav;
  }
}
