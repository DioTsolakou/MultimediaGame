import ddf.minim.*;
Minim minim;

PImage[] characterIdle = new PImage[4];
PImage[] characterRun = new PImage[6];
PImage[] characterDeath = new PImage[6];
PImage[] characterJump = new PImage[6];
PImage characterHurt = new PImage();
PImage[][] characterAttack;
PImage[] dust = new PImage[6];
PImage[] enemyMove = new PImage[6];
PImage[] enemyDeath = new PImage[6];
PImage enemyHurt = new PImage();
PImage[][] enemyAttack = new PImage[3][6];
PImage[][] levels;
PImage [][] objects;
PImage winterTile;
PImage bg_image;
PShape custom_rect;
Boolean gameEnded = false;
static int level = 1;


AudioPlayer music;
AudioSample sndJump, sndAttack1, sndAttack2, sndAttack3, sndWalk, sndDeath;

float cameraOffsetX;

Player thePlayer = new Player();
World theWorld = new World();
Keyboard theKeyboard = new Keyboard();
Enemy[] theEnemy = new Enemy[5];
int enemyCounter = 0;

PFont font;

int gameStartTimeSec,gameCurrentTimeSec;

final float GRAVITY_POWER = 0.5;

void setup() {
  size(1280, 720, P2D);
  
  font = loadFont("SansSerif-20.vlw");

  loadAnimations("GraveRobber");
  initEnemies();

  loadLevels("level1"); 
  loadObjects("level1");
  
  cameraOffsetX = 0.0;
  
  minim = new Minim(this);

  int buffersize = 256;
  sndJump = minim.loadSample("Sounds\\jump.wav", buffersize);
  sndAttack1 = minim.loadSample("Sounds\\SwordSwing.wav", buffersize);
  sndAttack2 = minim.loadSample("Sounds\\SwordHit.wav", buffersize);
  sndAttack3 = minim.loadSample("Sounds\\MetalLightSliceMetal3.wav", buffersize);
  sndWalk = minim.loadSample("Sounds\\CharacterWalk.wav", buffersize);
  sndDeath = minim.loadSample("Sounds\\CharacterDeath.wav", buffersize);
  
  frameRate(60);
  
  resetGame(theWorld.start_Grid, 1); // sets up player, game level, and timer
}

void initEnemies()
{
  for (int i = 0; i < theEnemy.length; i++)
  {
    theEnemy[i] = new Enemy();
  }
}

void loadCharacterAnimations(String characterName)
{
  loadAnimation(characterIdle, characterName, "idle");
  loadAnimation(characterRun, characterName, "run");
  loadAnimation(characterDeath, characterName, "death");
  characterHurt = loadImage("Characters\\"+characterName+"\\"+characterName+"_hurt_"+Integer.toString(2)+".png");
  loadAnimation(characterJump, characterName, "jump");
  loadAttackAnimation(characterName);
  loadDustEffects();
  loadEnemyAnimations();
}

 void loadEnemyAnimations()
{
  for (int i = 0; i < enemyMove.length; i++)
  {
    enemyMove[i] = loadImage("Characters\\SteamMan\\SteamMan_walk_"+Integer.toString(i+1)+".png");
  }

  for (int i = 0; i < enemyDeath.length; i++)
  {
    enemyDeath[i] = loadImage("Characters\\SteamMan\\SteamMan_death_"+Integer.toString(i+1)+".png");
  }

  for (int i = 0; i < enemyAttack.length; i++)
  {
    for (int j = 0; j < enemyAttack[0].length; j++)
    {
      enemyAttack[i][j] = loadImage("Characters\\SteamMan\\SteamMan_attack"+Integer.toString(i+1)+"_"+Integer.toString(j+1)+".png");
    }
  }
  enemyHurt = loadImage("Characters\\SteamMan\\SteamMan_hurt_"+Integer.toString(2)+".png");
} 

void loadAnimations(String characterName)
{
  if (characterName.equals("GraveRobber") || characterName.equals("SteamMan") || characterName.equals("Woodcutter"))
  {
    loadCharacterAnimations(characterName);
  }
}

void loadAnimation(PImage[] animArray, String characterName, String animName) { 
  for (int i = 0; i < animArray.length; i++)
  {
    animArray[i] = loadImage("Characters\\"+characterName+"\\"+characterName+"_"+animName+"_"+Integer.toString(i+1)+".png");
  }
}

void loadAttackAnimation(String characterName)
{
  characterAttack = new PImage[3][6];

  for (int i = 0; i < characterAttack.length; i++)
  {
    for (int j = 0; j < characterAttack[0].length; j++)
    {
      characterAttack[i][j] = loadImage("Characters\\"+characterName+"\\"+characterName+"_attack"+Integer.toString(i+1)+"_"+Integer.toString(j+1)+".png");
    }
  }
}

public void loadLevels(String levelName)
{
  levels = new PImage[3][8];
  for(int i = 0; i < levels.length; i++)
  {
    levels[i][0] = loadImage(levelName+"\\BG.png");
    bg_image =  levels[i][0];
    for (int j = 1; j < levels[0].length; j++)
    {
      levels[i][j] = loadImage(levelName+"\\Tiles\\"+j+".png");
    }
  }
}

void loadObjects(String levelName)
{
  objects = new PImage[3][9];
  for(int i = 0; i < objects.length; i++)
  {
    for (int j = 1; j < objects[0].length; j++)
    {
      objects[i][j] = loadImage(levelName+"\\Object\\"+ (j+1) +".png");
    }
  }
}

void nextLevel()
{
  if (level == 1)
  {
    resetGame(theWorld.level_2_Grid, 2);
  }
  else if (level == 2)
  {
    resetGame(theWorld.level_3_Grid, 3);
  }
  else return;
  loadLevels("level"+level);
  loadObjects("level"+level);
}

void loadDustEffects()
{
  dust = new PImage[6];

  for (int i = 0; i < dust.length; i++)
  {
    dust[i] = loadImage("Characters\\Effects\\Run_dust_"+Integer.toString(i+1)+".png");
  }
}

void resetGame(int [][] grid,int currentLevel)
{
  thePlayer.reset();
  level = currentLevel;

  for (int i = 0; i < theEnemy.length; i++)
    theEnemy[i].reset();
  
  theWorld.reload(grid); // reset world map

  // reset timer in corner
  gameCurrentTimeSec = gameStartTimeSec = millis()/1000;
}

Boolean gameWon() {
  if ((theWorld.worldSquareAt(thePlayer.position) == theWorld.TILE_FINISH) && level == 3)
  {
    gameEnded = true;
  }
  return gameEnded;
}

void outlinedText(String sayThis, float atX, float atY) {
  textFont(font);
  fill(0);
  text(sayThis, atX-1,atY);
  text(sayThis, atX+1,atY);
  text(sayThis, atX,atY-1);
  text(sayThis, atX,atY+1);
  fill(255);
  text(sayThis, atX,atY);
}

void updateCameraPosition() {
  int rightEdge = World.GRID_UNITS_WIDE*World.GRID_UNIT_SIZE-width;

  cameraOffsetX = thePlayer.position.x-width/2;
  if (cameraOffsetX < 0) {
    cameraOffsetX = 0;
  }
  
  if (cameraOffsetX > rightEdge) {
    cameraOffsetX = rightEdge;
  }
}

void draw() {
  pushMatrix();
  translate(-cameraOffsetX, 0.0);

  updateCameraPosition();

  background(bg_image);

  theWorld.render();
    
  thePlayer.inputCheck();
  thePlayer.move();
  thePlayer.draw();

  for (int i = 0; i < theEnemy.length; i++) {
    theEnemy[i].move();
    theEnemy[i].draw();
  }
  
  popMatrix();
  
  if (focused == false) {
    textAlign(CENTER);
    outlinedText("Click this area to play\n\nUse arrows to move\nSpacebar to jump.\n\nA for quick attack\nD for strong attack",width/2, 50);
  } 
  else {
    textAlign(LEFT);
    outlinedText("Health", 20, 20);
    outlinedText("Stamina", 20, 75);

    textAlign(RIGHT);
    outlinedText("FPS", width - 40, 20);
    outlinedText(String.valueOf((int) frameRate), width - 10, 20);
    
    textAlign(RIGHT);
    //gameWon();
    if (gameWon() == false) {
      gameCurrentTimeSec = millis()/1000;
    }
    int minutes = (gameCurrentTimeSec-gameStartTimeSec)/60;
    int seconds = (gameCurrentTimeSec-gameStartTimeSec)%60;
    if (seconds < 10) {
      outlinedText(minutes +":0"+seconds,width-8, height-10);
    } else {
      outlinedText(minutes +":"+seconds,width-8, height-10);
    }
    
    textAlign(CENTER);
    if (gameWon()) {
      outlinedText("You finished the game!\nPress R to Reset.",width/2, height/2-12);
    }
  }
}

void keyPressed() {
  theKeyboard.pressKey(key, keyCode);
}

void keyReleased() {
  theKeyboard.releaseKey(key, keyCode);
}

void stop() {
  sndJump.close();
  sndAttack1.close();
  sndAttack2.close();
  sndAttack3.close();
  sndWalk.close();
  sndDeath.close();
 
  minim.stop();

  super.stop();
}
