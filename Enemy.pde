class Enemy
{
  PVector position, velocity;
  Boolean facingRight;
  static final float TRIVIAL_SPEED = 1.0;
  int health = 100;
  int stamina = 100;

  int drawCounter = 1;
  int walkCounter = 0;
  int deathCounter = 0;
  int attackCounter = 0;
  int walkAnimationsCounter = 0;
  float movingFactor = 0;
  boolean isHurt = false;
  int hurtCounter = 0;
  boolean normalAttack = false;
  boolean strongAttack1 = false;
  boolean strongAttack2 = false;
  float randomAttack = 0;
  boolean playerInRange = false;
  Boolean isOnGround;

  Enemy()
  {
    position = new PVector();
    velocity = new PVector();
    facingRight = true;
    isOnGround = false;
    reset();
  }

  void reset() {
    velocity.x = 0;
    velocity.y = 0;
    health = 100;
    stamina = 100;
  }

  void collisionCheck()
  {
    float enemyHeight = enemyMove[0].height*0.7;
    float enemyWidth = enemyMove[0].width*0.8;

    int wallProbeDistance = int(enemyWidth*0.3);
    int ceilingProbeDistance = int(enemyHeight*0.95);
    
    // used as probes to detect running into walls, ceiling
    PVector leftSideHigh, rightSideHigh, leftSideLow, rightSideLow,topSide;
    leftSideHigh = new PVector();
    rightSideHigh = new PVector();
    leftSideLow = new PVector();
    rightSideLow = new PVector();
    topSide = new PVector();

    // update wall probes
    leftSideHigh.x = leftSideLow.x = position.x - wallProbeDistance; // left edge of enemy
    rightSideHigh.x = rightSideLow.x = position.x + wallProbeDistance; // right edge of enemy
    leftSideLow.y = rightSideLow.y = position.y - 0.2*enemyHeight; // shin high
    leftSideHigh.y = rightSideHigh.y = position.y - 0.8*enemyHeight; // shoulder high

    topSide.x = position.x; // center of enemy
    topSide.y = position.y - ceilingProbeDistance; // top of enemy
    
    if (theWorld.worldSquareAt(topSide) == World.TILE_SOLID || theWorld.worldSquareAt(topSide) == World.TILE_SOLID_2 || theWorld.worldSquareAt(topSide) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(topSide) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(topSide) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(topSide) == World.TILE_SOLID_OBJECT) {
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID || theWorld.worldSquareAt(position) == World.TILE_SOLID_2 || theWorld.worldSquareAt(position) == World.TILE_LEFT_EDGE ||
          theWorld.worldSquareAt(position) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(position) == World.TILE_RIGHT_EDGE ||
          theWorld.worldSquareAt(position) == World.TILE_SOLID_OBJECT) {
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
    
    if (theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(leftSideLow) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID_OBJECT) {
      position.x = theWorld.rightOfSquare(leftSideLow) + wallProbeDistance;
      if (velocity.x < 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID_2 || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_LEFT_EDGE || 
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_PLATFORM_CENTER ||
        theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID_OBJECT) {
      position.x = theWorld.rightOfSquare(leftSideHigh) + wallProbeDistance;
      if (velocity.x < 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID || 
        theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID_2 ||  
        theWorld.worldSquareAt(rightSideLow) == World.TILE_PLATFORM_CENTER || 
        theWorld.worldSquareAt(rightSideLow) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID_OBJECT) {
      position.x = theWorld.leftOfSquare(rightSideLow) - wallProbeDistance;
      if (velocity.x > 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID || 
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID_2 ||  
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_PLATFORM_CENTER || 
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_RIGHT_EDGE ||
        theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID_OBJECT) {
      position.x = theWorld.leftOfSquare(rightSideHigh) - wallProbeDistance;
      if (velocity.x > 0) {
        patrol();
      }
    }
  }

  void checkForFalling() {
    if (theWorld.worldSquareAt(position) == World.TILE_EMPTY) {
      isOnGround = false;
    }
      
    if (isOnGround == false) {    
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID || theWorld.worldSquareAt(position) == World.TILE_SOLID_2 || theWorld.worldSquareAt(position) == World.TILE_LEFT_EDGE ||
          theWorld.worldSquareAt(position) == World.TILE_PLATFORM_CENTER || theWorld.worldSquareAt(position) == World.TILE_RIGHT_EDGE) {
        isOnGround = true;
        position.y = theWorld.topOfSquare(position);
        velocity.y = 0.0;
      } else {
        velocity.y += GRAVITY_POWER;
      }
    }
  }

  void move()
  {
    position.add(velocity);
    collisionCheck();

    checkForFalling();

    if (facingRight)
    {
      movingFactor = 1;
    }
    else
    {
      movingFactor = -1;
    }

    velocity.x += movingFactor*0.5;
    velocity.x *= 0.6;
  }

  void patrol()
  {
    velocity.x = 0;
    facingRight = !facingRight;
    walkAnimationsCounter = 0;
  }

  void draw()
  {
    int enemyHeight = enemyMove[0].height;
    int enemyWidth = enemyMove[0].width;

    if (velocity.x < -TRIVIAL_SPEED) {
      facingRight = false;
    }
    else if (velocity.x > TRIVIAL_SPEED) {
      facingRight = true;
    }

    if (health > 0)
    {
      drawHealthBar();
      drawStaminaBar();
    }

    pushMatrix();
    translate(position.x, position.y);
    if (facingRight == false)
    {
      scale(-1, 1); // flip horizontally
    }
    translate(-enemyWidth/2, -enemyHeight);

    if (health > 0) {
      playerInRange = inRange(100);
      stamina = Math.max(stamina, 0);
      stamina = Math.min(stamina, 100);
      if (playerInRange && stamina >= 30)
      {
        playAttackAnimation();
      }
      else if (isHurt)
      {
        hurtCounter++;
        image(enemyHurt, 0, 0);
        if (hurtCounter == 15) {
          isHurt = false;
          hurtCounter = 0;
        }
      }
      else
      {
        image(enemyMove[walkCounter], 0, 0);
        if (drawCounter % 10 == 0)
        {
          walkCounter++;
          if (walkCounter == 5) 
          {
            walkCounter = 0;
            walkAnimationsCounter++;
          }      
        }

        if (walkAnimationsCounter == 6)
        {
          patrol();      
        }
      }
    }
    else
    {
      if (deathCounter != 6) {
        image(enemyDeath[deathCounter], 0, 0);
        if (drawCounter % 7 == 0) {
          deathCounter++;     
        }
      }
    }

    popMatrix();
    drawCounter++;

    if (drawCounter == 60)
    {
      drawCounter = 1;
      //playerInRange = inRange(100);
      regenerateStamina();
      randomAttack = random(1.0f);
    }
  }

  void playAttackAnimation()
  {
    byte attackType = 0;
    int mod = 1;
    if (randomAttack < 0.33) {
      attackType = 0; 
      mod = 4;
    }
    if (randomAttack >= 0.33 && randomAttack < 0.66) {
      attackType = 1;
      mod = 4;
    }
    if (randomAttack >= 0.66)
    {
      attackType = 2;
      mod = 8;
    }

    image(enemyAttack[attackType][attackCounter], 0, 0);
    
    if (drawCounter % mod == 0)
    {
      attackCounter++;

      if (attackCounter == 6) 
      {
        // substract stamina
        attackCounter = 0;

        int dmg = 0;
        if (attackType == 0) {
          dmg = 20;
          stamina = Math.max(0, stamina - 30);
        }
        else if (attackType == 1) {
          dmg = 35;
          stamina = Math.max(0, stamina - 30);
        }
        else if (attackType == 2)
        {
          dmg = 25;
          stamina = Math.max(0, stamina - 30);
        }
          
        // enemy dmg
        boolean b1 = Math.sqrt(Math.pow(thePlayer.position.x - position.x, 2) + Math.pow(thePlayer.position.y - position.y, 2)) < 70;
        boolean b2 = (thePlayer.position.x < position.x && facingRight) || (thePlayer.position.x > position.x && !facingRight);
        boolean b3 = Math.abs(thePlayer.position.y - position.y) < 40;
        if (b1 && b2 && b3) {
          thePlayer.health -= dmg;
          sndAttack3.trigger();
          thePlayer.isHurt = true;          
        }     
      }      
    }
  }
  
  boolean inRange (int distance) {
    if (Math.sqrt(Math.pow(thePlayer.position.x - position.x, 2) + Math.pow(thePlayer.position.y - position.y, 2)) < distance)
      return true;
    return false;
  }

  void drawHealthBar()
  {
    int dist = 0;
    if (facingRight) dist = 40;
    else dist = 15;
    fill(244, 3, 3);
    noStroke();
    rect(position.x - dist, position.y - 80, map(health, 0, 100, 0, 50), 5);
  }

  void drawStaminaBar()
  {
    int dist = 0;
    if (facingRight) dist = 40;
    else dist = 15;
    fill(0, 255, 0);
    noStroke();
    rect(position.x - dist, position.y - 75, map(stamina, 0, 100, 0, 50), 5);
  }

  void regenerateStamina()
  {
    stamina += 10;
    stamina = Math.max(stamina, 0);
    stamina = Math.min(stamina, 100);
  }
}