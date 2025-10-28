import java.util.ArrayList;


// Constants

float GROUND_HEIGHT = 300;
color GROUND_COLOR = color(40,0,61);
color BACKGROUND_COLOR = color(71,121,196);
color OBSTACLE_COLOR = color(0,0,0,230);
color OBSTACLE_OUTLINE_COLOR = color(255,255,255,230);

float CUBE_SIZE = 100;
float CUBE_OFFSET = 400;
color CUBE_COLOR = color(255,255,0);
          
float MOVE_SPEED = 20;
float GRAVITY = 3.2;
float JUMP_STRENGTH = 36;
float JUMP_MIDPOINT_FRAMES = JUMP_STRENGTH / GRAVITY; // frames from takeoff to jump midpoint, for a jump to the same elevation
float JUMP_TOTAL_FRAMES = JUMP_MIDPOINT_FRAMES * 2; // frames from takeoff to landing, for a jump to the same elevation
float ROTATE_PER_FRAME = PI / JUMP_TOTAL_FRAMES; // rotation per frame while jumping 
float JUMP_DIST = JUMP_MIDPOINT_FRAMES * 2 * MOVE_SPEED; // represents distance of jump to same elevation
float JUMP_REACH = JUMP_DIST + CUBE_SIZE; // the cube can jump on its rear end and land on its front end, so it can reach a body width further than jump distance
float JUMP_MIDPOINT_DIST = JUMP_DIST * 0.5; // represents the x pos of the middle of the jump (where the cube is at its highest)
float JUMP_MIDPOINT_HEIGHT = JUMP_STRENGTH * JUMP_MIDPOINT_FRAMES - 0.5 * GRAVITY * JUMP_MIDPOINT_FRAMES * JUMP_MIDPOINT_FRAMES; // maximum height gained from jump 
float JUMP_LEEWAY = 20;
float SAFE_RANGE_W = 1000; // empty stretch at the start of every run
float OBSTACLE_UPDATE_OFFSET = 200; // how far the new obstacle spawns from the current camera position,
                                    // and how far left the obstacle can be before it is considered offscreen and removed.
float MIN_PLATFORM_H = CUBE_SIZE/2;

float CAMERA_SMOOTH = 0.1; // 0..1 smoothing (higher = faster follow)
float CAMERA_MARGIN_TOP = 600; // px from bottom of view to top dead zone
float CAMERA_MARGIN_BOTTOM = 180; // px from bottom of view to bottom dead zone

int MIN_REST_TIME = int(CUBE_SIZE / MOVE_SPEED);
int MAX_REST_TIME = 50; // max number of frames the player has before elevation changes again 
float MIN_REST_LENGTH = 300;
float MAX_REST_LENGTH = 700; // (px) max distance that the player can do nothing (between jumps)
float MIN_INVERT_Y_DIFF = CUBE_SIZE;
float MAX_INVERT_Y_DIFF; // = height - GROUND_HEIGHT
int AIR_TIME_BEFORE_CRASH = 50; 



// Variables

boolean pressedSpace = false;
int score = 0;
int normalHighscore = 0; 
int invertHighscore = 0; 

float cubeX = CUBE_OFFSET + CUBE_SIZE/2;
float cubeY = CUBE_SIZE/2;
float vx = MOVE_SPEED;
float vy = 0;
float prevY = 0;
boolean onSurface = true;
float cubeAngle = 0;

float cameraX = 0;
float cameraY = CUBE_SIZE/2;
float cameraSpeed = MOVE_SPEED;   
float groundX = 0;

ArrayList<Obstacle> obstacles = new ArrayList<>(); // list of all obstacles generated this run
float difficulty = 0; // ramping difficulty as the run goes on (to be added)
float lastPlatformRight = 100;
float lastPlatformLeft = 0;
float lastPlatformGravDir = 1;  // {-1,1}: 1 for normal gravity, -1 for inverted

float gravDir = 1;  // {-1,1}: 1 for normal gravity, -1 for inverted

// these coords are of the cube's center
// used to generate trajectory for cube and spawn platforms from trajectory
float nextJumpX = cubeX + SAFE_RANGE_W;
float nextJumpY = CUBE_SIZE/2;
float nextLandX = 0;
float nextLandY = CUBE_SIZE/2;
float thisJumpX = 0;
float thisJumpY = 0; 
float thisLandX = cubeX;
float thisLandY = CUBE_SIZE/2; 

enum Screen {Menu, Normal, Invert, Crash};
Screen screen = Screen.Menu;
enum Game {Normal, Invert};
Game lastGame;

void setup() {
  size(1920,1080);
  layers.add(layer1);
  layers.add(layer2);
  layers.add(layer3);
  layers.add(layer4);
  layers.add(layer5);
  layers.add(layer6);
  background(255);
  
  MAX_INVERT_Y_DIFF = height - GROUND_HEIGHT;
  
}

void draw() {

  // Clear onscreen visuals
  background(255);
  
  if (screen == Screen.Menu) {
    drawMenu();
  }
  else if (screen == Screen.Normal) {
    drawNormalGame();
  }
  else if (screen == Screen.Invert) {
    drawInvertGame();
  }
  else if (screen == Screen.Crash) {
    drawCrash();
  }
  
}

void updateScore() {
  score = round(cubeX/500)*10;
  if (screen == Screen.Normal && score > normalHighscore) normalHighscore = score; // real time highscore update
  else if (screen == Screen.Invert && score > invertHighscore) invertHighscore = score;
}

void drawUI() {
  pushMatrix();
  pushStyle();
  
  translate(0, height);
  scale(1,-1);
  
  fill(255);
  textSize(50);
  textAlign(LEFT,BOTTOM);
  text("SCORE " + score, 40, 100);
  text("HIGHSCORE " + ((screen == Screen.Normal) ? normalHighscore : invertHighscore), 40, 170);
  
  // Draw tutorial if the player hasn't pressed space yet
  if (!pressedSpace) {
    fill(255);
    textSize(100);
    textAlign(LEFT,BOTTOM);
    text("press SPACE to jump", 540, 400);
  }
  popMatrix();
  popStyle();
}

void updateCamera() {
  cameraX += cameraSpeed; // horizontal camera follows cube instantly
  
  // vertical camera follows cube smoothly
  // only follows when cube leaves vertical deadzone
  float minYDiff = 50;
  float targetY = cameraY;
  float cubeTop = cubeY + CUBE_SIZE/2;
  float cubeBottom = cubeY - CUBE_SIZE/2;
  
  if (cubeTop > cameraY + CAMERA_MARGIN_TOP) {
    targetY = cubeTop - CAMERA_MARGIN_TOP;
  }

  else if (cubeBottom < cameraY + CAMERA_MARGIN_BOTTOM) {
    targetY = cubeY - CAMERA_MARGIN_BOTTOM;  
  }

  if (Math.abs(targetY-cameraY) > minYDiff) cameraY += (targetY - cameraY) * CAMERA_SMOOTH; // simple exponential lerp
  
  if (lastGame == Game.Normal && cameraY < 0) cameraY = 0; // don't show world below y=0 in Normal gamemode
}

void generateObstacles() {

  if (cameraX+width+OBSTACLE_UPDATE_OFFSET < nextJumpX-CUBE_SIZE/2) {
    return;
  }
  if (obstacles.isEmpty()) {
    lastPlatformRight = cubeX + SAFE_RANGE_W + CUBE_SIZE/2;
    lastPlatformLeft = 0;
  }
  thisJumpX = nextJumpX;
  thisJumpY = nextJumpY;
  thisLandX = nextLandX;
  thisLandY = nextLandY;
    
  // randomize x of next jump, y of next jump is equal to current y pos
  nextJumpX = thisLandX + random(MIN_REST_LENGTH, MAX_REST_LENGTH);
  nextJumpY = thisLandY;

  float lowerBound = 0;
  float upperBound = 0;
  if (screen == Screen.Normal) {

    // randomize an y for nextLandY, ranging from 0 (ground level) to the max of a jump from the current position
    // based on the trajectory of a jump from thisJumpX, and the provided y, calculate nextLandX
    // only consider the second half of the jump (when the cube falls back down) when computing x,
    // since any land on the first half is not possible without collision.
    // this algorithm is made to ensure there is a possible for every situation, and no irrational jumps are generated. 
    float thisJumpMidpointX = thisJumpX + JUMP_MIDPOINT_DIST;
    float nextJumpMidpointX = nextJumpX + JUMP_MIDPOINT_DIST;
    float thisJumpMaxY = thisJumpY + JUMP_MIDPOINT_HEIGHT;
    float nextJumpMaxY = nextJumpY + JUMP_MIDPOINT_HEIGHT;
    
    nextLandY = random(0, nextJumpMaxY) - JUMP_LEEWAY;
    if (nextLandY < MIN_PLATFORM_H + CUBE_SIZE/2) nextLandY = CUBE_SIZE/2;
    nextLandX = landingXForTargetY(nextJumpX, nextJumpY, nextLandY);

    // generate platform that can support this land and next jump 
    // compared to an adjacent platform (the previous or the next):
      // if the current platform is at a lower elevation: it can extend to reach the boundary of the adjacent platform
      // if the current platform is at a higher elevation: it can only extend to the x pos of the middle of the corresponding jump trajectory
    if (thisLandY < thisJumpY) {
      lowerBound = lastPlatformRight;
    }
    else {
      lowerBound = max(thisJumpMidpointX, lastPlatformRight);
    }
    if (nextJumpY < nextLandY) {
      upperBound = nextLandX - CUBE_SIZE/2;
    } 
    else {
      upperBound = nextJumpMidpointX;
    } 
  }
  else if (screen == Screen.Invert) {

    float nextJumpYDiff = random(MIN_INVERT_Y_DIFF, MAX_INVERT_Y_DIFF); 
    nextLandY = (lastPlatformGravDir == 1) ? nextJumpY-nextJumpYDiff : nextJumpY+nextJumpYDiff;  // Same gravity direction as 2 platforms ago 
    nextLandX = landingXForTargetYInvert(nextJumpX, nextJumpY, nextLandY);

    lowerBound = lastPlatformRight;
    upperBound = nextJumpX + CUBE_SIZE/2;
  }

  float lowerMin = lowerBound; 
  float lowerMax = thisLandX;
  float upperMin = nextJumpX; 
  float upperMax = upperBound;

  float lowerX = random(lowerMin,lowerMax);
  float upperX = random(upperMin,upperMax);
  float obX = lowerX;
  float obW = upperX - lowerX;
  float obY = 0;
  float obH = 0;
  if (screen == Screen.Normal) {
    obY = 0;
    obH = thisLandY - CUBE_SIZE/2;
  }
  else if (screen == Screen.Invert) {
    obY = (lastPlatformGravDir == 1) ? thisLandY + CUBE_SIZE/2 : thisLandY - CUBE_SIZE/2;
    obH = height*5; // simulating infinity
  }
  
  // add to list of generations
  Obstacle o = null;
  if (screen == Screen.Normal) {
    o = new Obstacle(obX, obY, obW, obH, 1, Type.Platform);
    obstacles.add(o);
  }
  else if (screen == Screen.Invert) {
    if (lastPlatformGravDir == 1) o = new Obstacle(obX, obY, obW, obH, -1, Type.Platform);  // If last platform had gravity direction 1, draw inverse this time
    else                          o = new Obstacle(obX, obY-obH, obW, obH, 1, Type.Platform);  // If last platform had gravity direction -1, draw normal this time
    obstacles.add(o);
  }
  
  lastPlatformLeft = obX;
  lastPlatformRight = obX + obW;
  if (screen == Screen.Invert) lastPlatformGravDir *= -1;
  strokeWeight(20);
}

void updateObstacles() {
  java.util.Iterator<Obstacle> it = obstacles.iterator();
  while (it.hasNext()) {
    Obstacle o = it.next();
    if (o.offscreen()) it.remove( );
  }
}

void drawObstacles() {
  for (Obstacle o : obstacles) o.draw();
}

void updateCube() {
  
  cubeX += vx;
  
  prevY = cubeY;
  vy += -GRAVITY * gravDir;
  cubeY += vy;
  
  checkCollisions();
  
  if (screen == Screen.Normal && cubeY-CUBE_SIZE/2 <= 0) {
    land();
  }

  if (!onSurface) {
    // spin forward with normal gravity, spin backward with inverted 
    cubeAngle += ROTATE_PER_FRAME * gravDir;
  }
  else {
    cubeAngle = 0;
  }
  cubeAngle = cubeAngle % TWO_PI;  // keep cubeAngle in the range [0, TWO_PI)
  if (cubeAngle < 0) cubeAngle += TWO_PI;
  
}

void checkCollisions() {

  float cubeLeft = cubeX - CUBE_SIZE/2;
  float cubeRight = cubeX + CUBE_SIZE/2;
  float cubeBottom = cubeY - CUBE_SIZE/2;
  float cubeTop = cubeY + CUBE_SIZE/2;

  for (Obstacle o : obstacles) {

    float oLeft = o.x;
    float oRight = o.x + o.w;
    float oBottom = o.y;
    float oTop = o.y + o.h;
    
    float overlapX = min(cubeRight, oRight) - max(cubeLeft, oLeft);
    float overlapY = min(cubeTop, oTop) - max(cubeBottom, oBottom);
      
    if (overlapX>0 && overlapY>0) {
      
      if (overlapX < overlapY) { // horizontal collision, fatal crash
      
        float overlapRight = cubeRight - oLeft;
        float overlapLeft = oRight - cubeLeft;
        
        if (overlapRight < overlapLeft) { // right collision, fatal crash. left collision is ignorable
          screen = Screen.Crash;
        }
      } 
      
      else { // vertical collision
      
        float overlapTop = cubeTop - oBottom;
        float overlapBottom = oTop - cubeBottom;
        
        // Collision with top of cube
        if (overlapTop < overlapBottom) { 
          if (screen == Screen.Invert && gravDir == -1) land(oBottom);          // Invert, gravDir = -1: land "upwards" on platform 
          else                                          screen = Screen.Crash;  // Normal || Invert, gravDir = 1: fatal crash                              
        }
        
        // Collision with bottom of cube
        else { // safely landed on surface of platform
          if (screen == Screen.Invert && gravDir == -1) screen = Screen.Crash;  // Invert, gravDir = -1: fatal crash
          else                                          land(oTop);             // Normal || Invert, gravDir = 1: land on platform
        }
      }
    }
  }
}

void resetVariables(Screen s) {
  
  lastPlatformRight = 0;
  lastPlatformLeft = 0;
  lastPlatformGravDir = 1;

  groundX = 0;
  difficulty = 0;
  obstacles.clear();
  
  cubeX = CUBE_OFFSET + CUBE_SIZE/2;
  cubeY = CUBE_SIZE/2;
  vx = MOVE_SPEED;
  vy = 0;
  onSurface = true;
  gravDir = 1;
  
  cameraX = 0;
  cameraY = CUBE_SIZE/2;
  cameraSpeed = MOVE_SPEED;
  
  thisJumpX = 0;
  thisJumpY = 0; 
  thisLandX = cubeX;
  thisLandY = CUBE_SIZE/2; 

  nextJumpX = cubeX + SAFE_RANGE_W;
  nextJumpY = CUBE_SIZE/2;
  if (s == Screen.Normal) {

    float nextJumpMaxY = nextJumpY + JUMP_MIDPOINT_HEIGHT;
    
    nextLandY = random(0, nextJumpMaxY) - JUMP_LEEWAY;
    if (nextLandY < MIN_PLATFORM_H + CUBE_SIZE/2) nextLandY = CUBE_SIZE/2;
    nextLandX = landingXForTargetY(nextJumpX, nextJumpY, nextLandY);
  }
  else if (s == Screen.Invert) {
    float nextJumpYDiff = random(CUBE_SIZE*3, height-GROUND_HEIGHT);
    nextLandY = (lastPlatformGravDir == 1) ? nextJumpY+nextJumpYDiff : nextJumpY-nextJumpYDiff;
    nextLandX = landingXForTargetYInvert(nextJumpX, nextJumpY, nextLandY);

    // Add initial platform in place of ground permanent ground
    Obstacle o = new Obstacle(0, -height*5, SAFE_RANGE_W + CUBE_OFFSET + CUBE_SIZE/2, height*5, 1, Type.Platform);
    obstacles.add(o);
    
    lastPlatformRight = SAFE_RANGE_W + CUBE_OFFSET + CUBE_SIZE/2;
    lastPlatformLeft = 0;
  }
  
}

void drawCube() {
  pushMatrix();
  pushStyle();

  translate(cubeX, cubeY);
  rotate(-cubeAngle);  // for clockwise rotation (note that this rotation doesn't affect the hitbox of the cube)
  rectMode(CENTER);
  
  stroke(0);
  strokeWeight(4);
  fill(255,255,0);
  rect(0, 0, CUBE_SIZE, CUBE_SIZE);

  popMatrix();
  popStyle();
}

void updateGround() {
  groundX += cameraSpeed;
}

void drawGround() {
  drawGround(0, GROUND_COLOR, width, GROUND_HEIGHT, 1);
}

void drawGround(int stroke, color c, float w, float h, float dir) {
  pushMatrix(); pushStyle();
  scale(1,dir); // To draw upside down ground in invert gamemode
  strokeWeight(stroke);
  fill(c);
  rect(groundX,-h,w,h);
  
  // White separator line 
  strokeWeight(2);
  line(groundX,0,groundX+width,0);
  popMatrix(); popStyle();
}

void jump() {
  onSurface = false;
  if (screen == Screen.Normal) vy = JUMP_STRENGTH * gravDir;
}

void land() {
  land(0);
}

// Checks for gravity direction as well to determine whether to land "down" or "up"
void land(float h) {
  onSurface = true;
  cubeY = (gravDir == 1) ? h + CUBE_SIZE/2 : h - CUBE_SIZE/2;
  vy = 0;

  // Snap rotation to nearest 90 degrees
  float snap = HALF_PI;
  cubeAngle = round(cubeAngle / snap) * snap;
}

boolean inJump() {
  return prevY != cubeY;
}

// returns landX
// inputs: takeoff x, takeoff y, landing y
float landingXForTargetY(float jumpX, float jumpY, float landY) {

  float v0 = JUMP_STRENGTH;
  float y0 = jumpY;
  float yT = landY;

  // discriminant to solve quadratic equation
  float d = v0 * v0 - 2 * GRAVITY * (yT - y0);
  if (d < 0) {
    // discriminant < 0 => no solution => unreachable target above apex 
    // clamp y to apex
    float apexY = y0 + (v0*v0) / (2*GRAVITY);
    yT = apexY;
    d = 0;
  }

  // solve for the greater root (at later half of jump)
  float landT = (v0 + sqrt(d)) / GRAVITY;
  float landX = jumpX + vx * landT;

  return landX;
}

// returns landX for invert mode
// inputs: gravity direction, takeoff x, takeoff y, landing y
float landingXForTargetYInvert(float jumpX, float jumpY, float landY) {
  
  // In invert mode, initial vy = 0 (unlike normal mode where vy = JUMP_STRENGTH)
  float v0 = 0;
  float y0 = jumpY;
  float yT = landY;
  float g = GRAVITY * gravDir; // gravity with direction
  
  // Using kinematic equation: y = y0 + v0*t + 0.5*g*t^2
  // Solving for t: t^2 = 2*(yT - y0)/g
  
  float deltaY = yT - y0;
  
  // Check if the target is reachable
  if ((g > 0 && deltaY < 0) || (g < 0 && deltaY > 0)) {
    // Unreachable target - gravity pulls in wrong direction
    return jumpX; // Return starting position as fallback
  }
  
  // Calculate time to reach target
  float t_squared = 2 * deltaY / g;
  if (t_squared < 0) {
    return jumpX; // Fallback for invalid cases
  }
  
  float landT = sqrt(t_squared);
  float landX = jumpX + vx * landT;
  
  return landX;
}

void keyPressed() {
  if (!pressedSpace) pressedSpace = true;
  if (screen == Screen.Normal) {
    keyPressedGame();
  }
  else if (screen == Screen.Invert) {
    keyPressedInvert();
  }
} 

void mousePressed() {
  if (screen == Screen.Menu) {
    mousePressedMenu();
  } 
  else if (screen == Screen.Normal || screen == Screen.Invert) {
    mousePressedGame();
  }
  else if (screen == Screen.Crash) {
    mousePressedCrash();
  }
}
