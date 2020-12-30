class Enemy
{
  PVector position, velocity;
  Boolean facingRight;
  static final float TRIVIAL_SPEED = 1.0;
  //int health = 100;

  int drawCounter = 1;
  int walkCounter = 0;
  int walkAnimationsCounter = 0;
  float movingFactor = 0;

  Enemy()
  {
    position = new PVector();
    velocity = new PVector();
    facingRight = true;
    reset();
  }

  void reset() {
    velocity.x = 0;
    velocity.y = 0;
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
    leftSideHigh.x = leftSideLow.x = position.x - wallProbeDistance; // left edge of player
    rightSideHigh.x = rightSideLow.x = position.x + wallProbeDistance; // right edge of player
    leftSideLow.y = rightSideLow.y = position.y - 0.2*enemyHeight; // shin high
    leftSideHigh.y = rightSideHigh.y = position.y - 0.8*enemyHeight; // shoulder high

    topSide.x = position.x; // center of player
    topSide.y = position.y - ceilingProbeDistance; // top of guy
    
    // the following conditionals just check for collisions with each bump probe
    // depending upon which probe has collided, we push the player back the opposite direction
    
    if (theWorld.worldSquareAt(topSide) == World.TILE_SOLID) {
      if (theWorld.worldSquareAt(position) == World.TILE_SOLID) {
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
    
    if (theWorld.worldSquareAt(leftSideLow) == World.TILE_SOLID) {
      position.x = theWorld.rightOfSquare(leftSideLow) + wallProbeDistance;
      if (velocity.x < 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(leftSideHigh) == World.TILE_SOLID) {
      position.x = theWorld.rightOfSquare(leftSideHigh) + wallProbeDistance;
      if (velocity.x < 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(rightSideLow) == World.TILE_SOLID) {
      position.x = theWorld.leftOfSquare(rightSideLow) - wallProbeDistance;
      if (velocity.x > 0) {
        patrol();
      }
    }
   
    if (theWorld.worldSquareAt(rightSideHigh) == World.TILE_SOLID) {
      position.x = theWorld.leftOfSquare(rightSideHigh) - wallProbeDistance;
      if (velocity.x > 0) {
        patrol();
      }
    }
  }

  void move()
  {
    position.add(velocity);
    collisionCheck();

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

    pushMatrix();
    translate(position.x, position.y + 20);
    if (facingRight == false)
    {
      scale(-1, 1); // flip horizontally by scaling horizontally by -100%
    }
    translate(-enemyWidth/2, -enemyHeight);

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
    popMatrix();

    drawCounter++;

    if (drawCounter == 60)
    {
      drawCounter = 1;
    }
  }
}