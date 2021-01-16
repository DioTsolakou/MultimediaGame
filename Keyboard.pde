class Keyboard {
  // used to track keyboard input
  Boolean holdingUp, holdingRight, holdingLeft, holdingSpace, holdingQuickAttack, holdingStrongAttack;
  
  Keyboard() {
    holdingUp = holdingRight = holdingLeft = holdingSpace = holdingQuickAttack = holdingStrongAttack = false;
  }
  
  /* The way that Processing, and many programming languages/environments, deals with keys is
   * treating them like events (something can happen the moment it goes down, or when it goes up).
   * Because we want to treat them like buttons - checking "is it held down right now?" - we need to
   * use those pressed and released events to update some true/false values that we can check elsewhere.
   */

  void pressKey(int key, int keyCode) {
    if (key == 'r' || key == 'R' || key == 'ρ' || key == 'Ρ') { // never will be held down, so no Boolean needed to track it
      if (gameEnded) { // if the game has been won...
        resetGame(); // then R key resets it
      }
    }

    if ((key == 'a' || key == 'A' || key == 'α' || key == 'Α') && thePlayer.stamina >= 20)
    {
      holdingQuickAttack = true;
    }
    if ((key == 'd' || key == 'D' || key == 'δ' || key == 'Δ') && thePlayer.stamina >=40)
    {
      if (!holdingStrongAttack) thePlayer.criticalChance = random(1.0f);
      holdingStrongAttack = true;
    }
    if (keyCode == UP) {
      holdingUp = true;
    }
    if (keyCode == LEFT) {
      holdingLeft = true;
    }
    if (keyCode == RIGHT) {
      holdingRight = true;
    }
    if (key == ' ') {
      holdingSpace = true;
    }
  }
  void releaseKey(int key, int keyCode) {
    if (keyCode == UP) {
      holdingUp = false;
    }
    if (keyCode == LEFT) {
      holdingLeft = false;
    }
    if (keyCode == RIGHT) {
      holdingRight = false;
    }
    if (keyCode == ' ') {
      holdingSpace = false;
    }
  }
}