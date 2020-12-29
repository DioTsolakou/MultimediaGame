class Player {
  PVector position, velocity; // PVector contains two floats, x and y

  Boolean isOnGround; // used to keep track of whether the player is on the ground. useful for control and animation.
  Boolean facingRight; // used to keep track of which direction the player last moved in. used to flip player image.
  int animDelay; // countdown timer between animation updates
  int animFrame; // keeps track of which animation frame is currently shown for the player
  int coinsCollected; // a counter to keep a tally on how many coins the player has collected
  
  static final float JUMP_POWER = 11.0; // how hard the player jolts upward on jump
  static final float RUN_SPEED = 5.0; // force of player movement on ground, in pixels/cycle
  static final float AIR_RUN_SPEED = 2.0; // like run speed, but used for control while in the air
  static final float SLOWDOWN_PERC = 0.6; // friction from the ground. multiplied by the x speed each frame.
  static final float AIR_SLOWDOWN_PERC = 0.85; // resistance in the air, otherwise air control enables crazy speeds
  static final float TRIVIAL_SPEED = 1.0; // if under this speed, the player is drawn as standing still

  int drawCounter = 1;
  int idleCounter = 0;
  int runCounter = 0;
  int jumpCounter = 0;
  int attackCounter = 0;
  int deathCounter = 0;
  int jumpCounterGlobal = 0;
  float criticalChance = 0;
  Object[] ret = new Object[2];

  
  Player() { // constructor, gets called automatically when the Player instance is created
    isOnGround = false;
    facingRight = true;
    position = new PVector();
    velocity = new PVector();
    reset();
  }
  
  void reset() {
    coinsCollected = 0;
    animDelay = 0;
    animFrame = 0;
    velocity.x = 0;
    velocity.y = 0;
  }
  
  void inputCheck() {
    // keyboard flags are set by keyPressed/keyReleased in the main .pde
    
    float speedHere = (isOnGround ? RUN_SPEED : AIR_RUN_SPEED);
    float frictionHere = (isOnGround ? SLOWDOWN_PERC : AIR_SLOWDOWN_PERC);
    
    float factor = 0;
    if (theKeyboard.holdingLeft) factor = -1;
    else if (theKeyboard.holdingRight) factor = 1;
    if ((theKeyboard.holdingQuickAttack || theKeyboard.holdingStrongAttack) && isOnGround)
    {
      velocity.x *= 0.2;
    } 

    velocity.x += factor * speedHere;
    velocity.x *= frictionHere;
    
    if (isOnGround) { // player can only jump if currently on the ground
      if (theKeyboard.holdingSpace || theKeyboard.holdingUp) { // either up arrow or space bar cause the player to jump
        //sndJump.trigger(); // play sound
        velocity.y = -JUMP_POWER; // adjust vertical speed
        isOnGround = false; // mark that the player has left the ground, i.e. cannot jump again for now
      }
    }
  }
  
  void checkForWallBumping() {
    float guyWidth = characterIdle[0].width*0.7; // think of image size of player standing as the player's physical size
    float guyHeight = characterIdle[0].height*0.75;
    int wallProbeDistance = int(guyWidth*0.3);
    int ceilingProbeDistance = int(guyHeight*0.95);
    
    /* Because of how we draw the player, "position" is the center of the feet/bottom
     * To detect and handle wall/ceiling collisions, we create 5 additional positions:
     * leftSideHigh - left of center, at shoulder/head level
     * leftSideLow - left of center, at shin level
     * rightSideHigh - right of center, at shoulder/head level
     * rightSideLow - right of center, at shin level
     * topSide - horizontal center, at tip of head
     * These 6 points - 5 plus the original at the bottom/center - are all that we need
     * to check in order to make sure the player can't move through blocks in the world.
     * This works because the block sizes (World.GRID_UNIT_SIZE) aren't small enough to
     * fit between the cracks of those collision points checked.
     */
    
    // used as probes to detect running into walls, ceiling
    PVector leftSideHigh,rightSideHigh,leftSideLow,rightSideLow,topSide;
    leftSideHigh = new PVector();
    rightSideHigh = new PVector();
    leftSideLow = new PVector();
    rightSideLow = new PVector();
    topSide = new PVector();

    // update wall probes
    leftSideHigh.x = leftSideLow.x = position.x - wallProbeDistance; // left edge of player
    rightSideHigh.x = rightSideLow.x = position.x + wallProbeDistance; // right edge of player
    leftSideLow.y = rightSideLow.y = position.y-0.2*guyHeight; // shin high
    leftSideHigh.y = rightSideHigh.y = position.y-0.8*guyHeight; // shoulder high

    topSide.x = position.x; // center of player
    topSide.y = position.y-ceilingProbeDistance; // top of guy

    // if any edge of the player is inside a red killblock, reset the round
    if ( theWorld.worldSquareAt(topSide) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(leftSideHigh) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(leftSideLow) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(rightSideHigh) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(rightSideLow) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(position) == World.TILE_KILLBLOCK) {
      resetGame();
      return; // any other possible collisions would be irrelevant, exit function now
    }
    
    // the following conditionals just check for collisions with each bump probe
    // depending upon which probe has collided, we push the player back the opposite direction
    
    if (theWorld.worldSquareAt(topSide) == World.TILE_SOLID) {
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID) {
        position.sub(velocity);
        velocity.x = 0.0;
        velocity.y = 0.0;
      } else {
        position.y = theWorld.bottomOfSquare(topSide)+ceilingProbeDistance;
        if (velocity.y < 0) {
          velocity.y = 0.0;
        }
      }
    }
    
    if (theWorld.worldSquareAt(leftSideLow)==World.TILE_SOLID) {
      position.x = theWorld.rightOfSquare(leftSideLow)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(leftSideHigh)==World.TILE_SOLID) {
      position.x = theWorld.rightOfSquare(leftSideHigh)+wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(rightSideLow)==World.TILE_SOLID) {
      position.x = theWorld.leftOfSquare(rightSideLow)-wallProbeDistance;
      if (velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(rightSideHigh)==World.TILE_SOLID) {
      position.x = theWorld.leftOfSquare(rightSideHigh)-wallProbeDistance;
      if (velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
  }

  void checkForCoinGetting() {
    PVector centerOfPlayer;
    // we use this to check for coin overlap in center of player
    // (remember that "position" is keeping track of bottom center of feet)
    centerOfPlayer = new PVector(position.x,position.y-characterIdle[0].height/2);

    if (theWorld.worldSquareAt(centerOfPlayer)==World.TILE_COIN) {
      theWorld.setSquareAtToThis(centerOfPlayer, World.TILE_EMPTY);
      //sndCoin.trigger();
      coinsCollected++;
    }
  }

  void checkForFalling() {
    // If we're standing on an empty or coin tile, we're not standing on anything. Fall!
    if (theWorld.worldSquareAt(position)==World.TILE_EMPTY ||
       theWorld.worldSquareAt(position)==World.TILE_COIN) {
       isOnGround=false;
    }
    
    if (isOnGround==false) { // not on ground?    
      if (theWorld.worldSquareAt(position)==World.TILE_SOLID) { // landed on solid square?
        isOnGround = true;
        position.y = theWorld.topOfSquare(position);
        velocity.y = 0.0;
      } else { // fall
        velocity.y += GRAVITY_POWER;
      }
    }
  }

  void move() {
    position.add(velocity);
    
    checkForWallBumping();
    
    checkForCoinGetting();
    
    checkForFalling();
  }
  
  void draw() {
    int guyWidth = characterIdle[0].width;
    int guyHeight = characterIdle[0].height;
    
    if (velocity.x < -TRIVIAL_SPEED) {
      facingRight = false;
    } else if (velocity.x > TRIVIAL_SPEED) {
      facingRight = true;
    }
    
    pushMatrix(); // lets us compound/accumulate translate/scale/rotate calls, then undo them all at once
    translate(position.x, position.y);
    if (facingRight == false)
    {
      scale(-1, 1); // flip horizontally by scaling horizontally by -100%
    }
    translate(-guyWidth/2, -guyHeight); // drawing images centered on character's feet

    if (isOnGround == false)
    { // falling or jumping
      jumpCounterGlobal++;
      attackCounter = 5; // after attackCounter++ it becomes 6 so holdingQuickAttack becomes false

      image(characterJump[jumpCounter], 0, 0); // this running pose looks pretty good while in the air
      if (jumpCounterGlobal % 8 == 0)
      {
        jumpCounter++; 
      }
      if(jumpCounterGlobal > 42)
          jumpCounter = 5;
    }
    else if (theKeyboard.holdingQuickAttack) 
    {
      playAttackAnimation(0, 4, theKeyboard.holdingQuickAttack);
      attackCounter = (int) ret[0];
      theKeyboard.holdingQuickAttack = (Boolean) ret[1];
    }
    else if (theKeyboard.holdingStrongAttack) //strong attack has the possibility to critically hit
    {
      //something might be wrong, there are critical hit notifs inside normal strong attack notifs and vice versa
      //having a separate critical counter doesn't fix it
      if (criticalChance > 0.15f)
      {
        playAttackAnimation(1, 4, theKeyboard.holdingStrongAttack);
        attackCounter =  (int) ret[0];
        theKeyboard.holdingStrongAttack = (Boolean) ret[1];
      }
      else
      {
        playAttackAnimation(2, 8, theKeyboard.holdingStrongAttack);
        attackCounter = (int) ret[0];
        theKeyboard.holdingStrongAttack = (Boolean) ret[1];
      }
    }   
    else {
      jumpCounter = 0;
      jumpCounterGlobal = 0;

      if (abs(velocity.x) < TRIVIAL_SPEED) 
        idleCounter = playAnimation(characterIdle, idleCounter, 3, 10);
      else runCounter = playAnimation(characterRun, runCounter, 6, 4);
    }
    
    popMatrix(); // undoes all translate/scale/rotate calls since the pushMatrix earlier in this function
    drawCounter++;

    if (drawCounter == 60)
      drawCounter = 1;
  }

  int playAnimation (PImage[] animationArray, int counter, int max, int mod) {
    image(animationArray[counter], 0, 0);
    if (drawCounter % mod == 0)
    {
      counter++;
      if (counter == max) 
      {
        counter = 0;
      }      
    }

    return counter;
  }


  void playAttackAnimation (int row, int mod, Boolean state)
  {
    image(characterAttack[row][attackCounter], 0, 0);
    if(abs(velocity.x) > TRIVIAL_SPEED)
      image(dust[attackCounter], -20, characterIdle[0].height - 10);
    if (drawCounter % mod == 0)
    {
      attackCounter++;
      if (attackCounter == 6) 
      {
        attackCounter = 0;
        state = false;
      }      
    }
    ret[0] = attackCounter;
    ret[1] = state;
  }
}