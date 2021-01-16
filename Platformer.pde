// these next 2 lines are used for sound
import ddf.minim.*;
Minim minim;

// for storing and referencing animation frames for the player character
//PImage[] characterIdle, characterRun, characterDeath, characterHurt, characterJump, dust, enemyMove;
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
PImage winterTile;
PImage bg_image;
PShape custom_rect;
Boolean gameEnded = false;

// music and sound effects
AudioPlayer music; // AudioPlayer uses less memory. Better for music.
AudioSample sndJump, sndAttack1, sndAttack2, sndAttack3, sndWalk, sndDeath; // AudioSample plays more respnosively. Better for sound effects.

// we use this to track how far the camera has scrolled left or right
float cameraOffsetX;

Player thePlayer = new Player();
World theWorld = new World();
Keyboard theKeyboard = new Keyboard();
Enemy[] theEnemy = new Enemy[5];
int enemyCounter = 0;

PFont font;

// we use these for keeping track of how long player has played
int gameStartTimeSec,gameCurrentTimeSec;

// by adding this to the player's y velocity every frame, we get gravity
final float GRAVITY_POWER = 0.5; // try making it higher or lower!

void setup() { // called automatically when the program starts
  size(1280, 720, P2D);
  
  font = loadFont("SansSerif-20.vlw");
  bg_image = loadImage("level1/BG.png");

  loadAnimations("GraveRobber");
  initEnemies();

  winterTile = loadImage("winterTile.png");
  
  cameraOffsetX = 0.0;
  
  minim = new Minim(this);
  //music = minim.loadFile("PinballSpring.mp3", 1024);
  //music.loop();
  int buffersize = 256;
  sndJump = minim.loadSample("Sounds\\jump.wav", buffersize);
  sndAttack1 = minim.loadSample("Sounds\\SwordSwing.wav", buffersize);
  sndAttack2 = minim.loadSample("Sounds\\SwordHit.wav", buffersize);
  sndAttack3 = minim.loadSample("Sounds\\MetalLightSliceMetal3.wav", buffersize);
  sndWalk = minim.loadSample("Sounds\\CharacterWalk.wav", buffersize);
  sndDeath = minim.loadSample("Sounds\\CharacterDeath.wav", buffersize);
  
  frameRate(60);
  
  resetGame(); // sets up player, game level, and timer
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

void loadDustEffects()
{
  dust = new PImage[6];

  for (int i = 0; i < dust.length; i++)
  {
    dust[i] = loadImage("Characters\\Effects\\Run_dust_"+Integer.toString(i+1)+".png");
  }
}

void resetGame() {
  // This function copies start_Grid into worldGrid, putting coins back
  // multiple levels could be supported by copying in a different start grid
  
  thePlayer.reset(); // reset the coins collected number, etc.

  for (int i = 0; i < theEnemy.length; i++)
    theEnemy[i].reset();
  
  theWorld.reload(); // reset world map

  // reset timer in corner
  gameCurrentTimeSec = gameStartTimeSec = millis()/1000; // dividing by 1000 to turn milliseconds into seconds
}

Boolean gameWon() { // checks whether all coins in the level have been collected
  if (theWorld.worldSquareAt(thePlayer.position) == theWorld.TILE_FINISH)
  {
    gameEnded = true;
  }
  return gameEnded;
}

void outlinedText(String sayThis, float atX, float atY) {
  textFont(font); // use the font we loaded
  fill(0); // white for the upcoming text, drawn in each direction to make outline
  text(sayThis, atX-1,atY);
  text(sayThis, atX+1,atY);
  text(sayThis, atX,atY-1);
  text(sayThis, atX,atY+1);
  fill(255); // white for this next text, in the middle
  text(sayThis, atX,atY);
}

void updateCameraPosition() {
  int rightEdge = World.GRID_UNITS_WIDE*World.GRID_UNIT_SIZE-width;
  // the left side of the camera view should never go right of the above number
  // think of it as "total width of the game world" (World.GRID_UNITS_WIDE*World.GRID_UNIT_SIZE)
  // minus "width of the screen/window" (width)
  
  cameraOffsetX = thePlayer.position.x-width/2;
  if (cameraOffsetX < 0) {
    cameraOffsetX = 0;
  }
  
  if (cameraOffsetX > rightEdge) {
    cameraOffsetX = rightEdge;
  }
}

void draw() { // called automatically, 24 times per second because of setup()'s call to frameRate(24)
  pushMatrix(); // lets us easily undo the upcoming translate call
  translate(-cameraOffsetX, 0.0); // affects all upcoming graphics calls, until popMatrix

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
  
  popMatrix(); // undoes the translate function from earlier in draw()
  
  if (focused == false) { // does the window currently not have keyboard focus?
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
    if (gameWon() == false) { // stop updating timer after player finishes
      gameCurrentTimeSec = millis()/1000; // dividing by 1000 to turn milliseconds into seconds
    }
    int minutes = (gameCurrentTimeSec-gameStartTimeSec)/60;
    int seconds = (gameCurrentTimeSec-gameStartTimeSec)%60;
    if (seconds < 10) { // pad the "0" into the tens position
      outlinedText(minutes +":0"+seconds,width-8, height-10);
    } else {
      outlinedText(minutes +":"+seconds,width-8, height-10);
    }
    
    textAlign(CENTER); // center align the text
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

void stop() { // automatically called when program exits. here we'll stop and unload sounds.
  //music.close();
  sndJump.close();
  sndAttack1.close();
  sndAttack2.close();
  sndAttack3.close();
  sndWalk.close();
  sndDeath.close();
 
  minim.stop();

  super.stop(); // tells program to continue doing its normal ending activity
}