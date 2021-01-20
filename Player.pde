class Player {
  PVector position, velocity;

  Boolean isOnGround;
  Boolean facingRight;
  Boolean flag;
  
  static final float JUMP_POWER = 11.0; // how hard the player jumps
  static final float RUN_SPEED = 5.0; // force of player movement on ground, in pixels/cycle
  static final float AIR_RUN_SPEED = 2.0; // like run speed, but used for control while in the air
  static final float SLOWDOWN_PERC = 0.6; // friction from the ground. multiplied by the x speed each frame.
  static final float AIR_SLOWDOWN_PERC = 0.85; // resistance in the air, otherwise air control enables crazy speeds
  static final float TRIVIAL_SPEED = 1.0; // if under this speed, the player is idle

  int drawCounter = 1;
  int idleCounter = 0;
  int runCounter = 0;
  int jumpCounter = 0;
  int attackCounter = 0;
  int deathCounter = 0;
  int jumpCounterGlobal = 0;
  float criticalChance = 0;
  public int health = 100;
  public int stamina = 100;
  boolean isHurt = false;
  int hurtCounter = 0;
  Object[] ret = new Object[2];

  
  Player() {
    isOnGround = false;
    facingRight = true;
    position = new PVector();
    velocity = new PVector();
    reset();
  }
  
  void reset() {
    velocity.x = 0;
    velocity.y = 0;
    health = 100;
    stamina = 100;
    drawCounter = 1;
    idleCounter = 0;
    runCounter = 0;
    jumpCounter = 0;
    attackCounter = 0;
    deathCounter = 0;
    jumpCounterGlobal = 0;
  }
  
  void inputCheck() {
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
    
    if (isOnGround) {
      if (theKeyboard.holdingSpace || theKeyboard.holdingUp) {
        sndJump.trigger();
        velocity.y = -JUMP_POWER;
        isOnGround = false;
      }
    }
  }
  
  void checkForWallBumping() {
    float guyWidth = characterIdle[0].width*0.7;
    float guyHeight = characterIdle[0].height*0.75;
    int wallProbeDistance = int(guyWidth*0.3);
    int ceilingProbeDistance = int(guyHeight*0.95);
    
    // used as probes to detect running into walls, ceiling
    PVector leftSideHigh, rightSideHigh, leftSideLow, rightSideLow, topSide;
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
    topSide.y = position.y - ceilingProbeDistance; // top of player

    // if any edge of the player is inside a red killblock, reset the round
    if ( theWorld.worldSquareAt(topSide) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(leftSideHigh) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(leftSideLow) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(rightSideHigh) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(rightSideLow) == World.TILE_KILLBLOCK ||
         theWorld.worldSquareAt(position) == World.TILE_KILLBLOCK || 
         theWorld.worldSquareAt(topSide) == World.TILE_KILLBLOCK_2 ||
         theWorld.worldSquareAt(leftSideHigh) == World.TILE_KILLBLOCK_2 ||
         theWorld.worldSquareAt(leftSideLow) == World.TILE_KILLBLOCK_2 ||
         theWorld.worldSquareAt(rightSideHigh) == World.TILE_KILLBLOCK_2 ||
         theWorld.worldSquareAt(rightSideLow) == World.TILE_KILLBLOCK_2 ||
         theWorld.worldSquareAt(position) == World.TILE_KILLBLOCK_2) {
      resetGame(theWorld.start_Grid, 1);
      loadLevels("level1");
      loadObjects("level1");
      return;
    }

    if (theWorld.worldSquareAt(topSide) == World.TILE_FINISH || theWorld.worldSquareAt(leftSideHigh) == World.TILE_FINISH ||
        theWorld.worldSquareAt(leftSideLow) == World.TILE_FINISH || theWorld.worldSquareAt(rightSideHigh) == World.TILE_FINISH ||
        theWorld.worldSquareAt(rightSideLow) == World.TILE_FINISH || theWorld.worldSquareAt(position) == World.TILE_FINISH)
    {
      flag = true;
      for (int i = 0; i < theEnemy.length; i++) {
        if (theEnemy[i].health != 0) flag = false;
      }
      if (flag) {
        if (level != 3)
          nextLevel();
        else gameEnded = true;
      }
        
    }
    
    if (theWorld.worldSquareAt(topSide) == World.TILE_SOLID || theWorld.worldSquareAt(topSide) == World.TILE_SOLID_2 || theWorld.worldSquareAt(topSide) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(topSide) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(topSide) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(topSide) == World.TILE_CLIFF_FACE_LEFT || theWorld.worldSquareAt(topSide)== World.TILE_CLIFF_FACE_RIGHT || 
          theWorld.worldSquareAt(topSide) == World.TILE_CLIFF_LEFT_DOWN || theWorld.worldSquareAt(topSide)== World.TILE_SOLID_OBJECT) {
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID  || theWorld.worldSquareAt(position) == World.TILE_SOLID_2 || theWorld.worldSquareAt(topSide) == World.TILE_LEFT_EDGE || 
          theWorld.worldSquareAt(position) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(position) == World.TILE_RIGHT_EDGE ||
          theWorld.worldSquareAt(position)== World.TILE_CLIFF_FACE_LEFT || theWorld.worldSquareAt(position)== World.TILE_CLIFF_FACE_RIGHT || 
          theWorld.worldSquareAt(position)== World.TILE_CLIFF_LEFT_DOWN || theWorld.worldSquareAt(position)== World.TILE_SOLID_OBJECT) {
        position.sub(velocity);
        velocity.x = 0.0;
        velocity.y = 0.0;
      } else {
        position.y = theWorld.bottomOfSquare(topSide) + ceilingProbeDistance;
        if (velocity.y < 0) {
          velocity.y = 0.0;
        }
      }
    }
    
    if (theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID  || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(leftSideLow) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(leftSideLow)== World.TILE_SOLID_OBJECT) {
      position.x = theWorld.rightOfSquare(leftSideLow) + wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_RIGHT_EDGE || 
        theWorld.worldSquareAt(leftSideHigh)== World.TILE_CLIFF_FACE_RIGHT ||
        theWorld.worldSquareAt(leftSideHigh)== World.TILE_SOLID_OBJECT) {
      position.x = theWorld.rightOfSquare(leftSideHigh) + wallProbeDistance;
      if(velocity.x < 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID || 
        theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(rightSideLow) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(rightSideLow) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(rightSideLow) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(rightSideLow)== World.TILE_CLIFF_FACE_LEFT || 
        theWorld.worldSquareAt(rightSideLow)== World.TILE_SOLID_OBJECT) {
      position.x = theWorld.leftOfSquare(rightSideLow) - wallProbeDistance;
      if (velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
   
    if (theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID || 
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(rightSideLow)== World.TILE_CLIFF_FACE_LEFT ||
        theWorld.worldSquareAt(rightSideHigh)== World.TILE_SOLID_OBJECT) {
      position.x = theWorld.leftOfSquare(rightSideHigh) - wallProbeDistance;
      if (velocity.x > 0) {
        velocity.x = 0.0;
      }
    }
  }

  void checkForFalling() {
    if (theWorld.worldSquareAt(position) == World.TILE_EMPTY) {
       isOnGround = false;
    }
    
    if (isOnGround == false) {   
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID  || theWorld.worldSquareAt(position) == World.TILE_SOLID_2 || theWorld.worldSquareAt(position) == World.TILE_LEFT_EDGE || 
          theWorld.worldSquareAt(position) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(position) == World.TILE_RIGHT_EDGE ||
          theWorld.worldSquareAt(position) == World.TILE_SOLID_OBJECT) {
        isOnGround = true;
        position.y = theWorld.topOfSquare(position);
        velocity.y = 0.0;
      } else {
        velocity.y += GRAVITY_POWER;
      }
    }
  }

  void move() {
    position.add(velocity);
    
    checkForWallBumping();
    
    checkForFalling();
  }
  
  void draw() {
    int guyWidth = characterIdle[0].width;
    int guyHeight = characterIdle[0].height;
    
    if (velocity.x < -TRIVIAL_SPEED) {
      facingRight = false;
    }
    else if (velocity.x > TRIVIAL_SPEED) {
      facingRight = true;
    }

    if ((velocity.x > TRIVIAL_SPEED || velocity.x < -TRIVIAL_SPEED) && isOnGround && drawCounter % 15 == 0) 
      sndWalk.trigger();

    if (health <= 0)
    {
      if (deathCounter != 6) {
        image(characterDeath[deathCounter], 0, 0); // animation doesn't work, does it on the air instead of actual death position
        if (drawCounter % 7 == 0) {
          deathCounter++;       
        }
        if (drawCounter % 25 == 0) sndDeath.trigger(); // doesn't get triggered after first death
      }

      if (deathCounter == 6)
      {
        resetGame(theWorld.start_Grid, 1);
      }
    }
    
    drawHealthBar();
    drawStaminaBar();
    
    pushMatrix();

    translate(position.x, position.y);
    if (facingRight == false)
    {
      scale(-1, 1); // flip horizontally
    }
    translate(-guyWidth/2, -guyHeight); // drawing images centered on character's feet

    if (!isHurt)
    {
      if (isOnGround == false)
      {
        jumpCounterGlobal++;
        //attackCounter = 5; // after attackCounter++ it becomes 6 so holdingQuickAttack becomes false

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
        theKeyboard.holdingQuickAttack = playAttackAnimation(0, 4, theKeyboard.holdingQuickAttack, 1);
      }
      else if (theKeyboard.holdingStrongAttack) //strong attack has the possibility to critically hit
      {
        if (criticalChance > 0.15f)
        {
          theKeyboard.holdingStrongAttack = playAttackAnimation(1, 4, theKeyboard.holdingStrongAttack, 1);
        }
        else
        {
          theKeyboard.holdingStrongAttack = playAttackAnimation(2, 8, theKeyboard.holdingStrongAttack, 1.5);
        }
      }   
      else {
        jumpCounter = 0;
        jumpCounterGlobal = 0;

        if (abs(velocity.x) < TRIVIAL_SPEED) 
          idleCounter = playAnimation(characterIdle, idleCounter, 3, 10);
        else runCounter = playAnimation(characterRun, runCounter, 6, 4);
      }
    }
    else
    {
      hurtCounter++;
      image(characterHurt, 0, 0);
      if (hurtCounter == 15) {
        isHurt = false;
        hurtCounter = 0;
      }
    }

    popMatrix();
    drawCounter++;

    if (drawCounter == 60)
    {
      drawCounter = 1;
      regenerateHealth();
      regenerateStamina();
    }
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

  Boolean playAttackAnimation (int row, int mod, Boolean state, float criticalFactor)
  {
    image(characterAttack[row][attackCounter], 0, 0);
    if(abs(velocity.x) > TRIVIAL_SPEED)
      image(dust[attackCounter], -20, characterIdle[0].height - 10);
    if (drawCounter % mod == 0)
    {
      attackCounter++;
      if (attackCounter == 6) 
      {
        // substract stamina
        attackCounter = 0;
        state = false;

        float dmg = 0;
        if (theKeyboard.holdingQuickAttack) {
          stamina -= 20;
          dmg = 15;
        }
        if (theKeyboard.holdingStrongAttack) {
          stamina -= 40;
          dmg = 30*criticalFactor;
        }
          
        // do damage
        for (int i = 0; i < theEnemy.length; i++) {
          boolean b1 = Math.sqrt(Math.pow(position.x - theEnemy[i].position.x, 2) + Math.pow(position.y - theEnemy[i].position.y, 2)) < 80;
          boolean b2 = (position.x < theEnemy[i].position.x && facingRight) || (position.x > theEnemy[i].position.x && !facingRight);
          boolean b3 = Math.abs(position.y - theEnemy[i].position.y) < 40;
          if (b1 && b2 && b3) {
            System.out.println(i + " took " + dmg + " damage");
            theEnemy[i].health -= dmg;
            sndAttack2.trigger();
            System.out.println(i + "'s current health is " + theEnemy[i].health);
            theEnemy[i].isHurt = true;
          }
          else
            sndAttack1.trigger();
        }     
      }      
    }
    return state;
  }

  void regenerateHealth()
  {
    health += 7;
    health = Math.max(health, 0);  
    health = Math.min(health, 100);
  }

  void regenerateStamina()
  {
    stamina += 10;
    stamina = Math.max(stamina, 0);
    stamina = Math.min(stamina, 100);
  }

  void drawHealthBar()
  { 
    fill(244, 3, 3);
    stroke(0);

    float drawPos = 0;
    if (position.x < (theWorld.GRID_UNIT_SIZE * theWorld.GRID_UNITS_WIDE) / 2)  
      drawPos = Math.max(20, position.x - width/2);
    else 
      drawPos = Math.min(3200 - width + 20, Math.abs(position.x - width/2));
    
    rect(drawPos, 30, map(health, 0, 100, 0, 150), 20);
    fill(0, 0, 0);
    textSize(18);
    text(health, drawPos + 75, 47);
  }

  void drawStaminaBar()
  {
    fill(0, 255, 0);
    stroke(0);

    float drawPos = 0;
    if (position.x < (theWorld.GRID_UNIT_SIZE * theWorld.GRID_UNITS_WIDE) / 2)
      drawPos = Math.max(20, position.x - width/2);
    else
      drawPos = Math.min(3200 - width + 20, Math.abs(position.x - width/2));

    rect(drawPos, 85, map(stamina, 0, 100, 0, 150), 20);
    fill(0, 0, 0);
    textSize(18);
    text(stamina, drawPos + 75, 102);
  }
}
