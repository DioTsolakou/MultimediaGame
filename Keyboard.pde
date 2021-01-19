class Keyboard {
  Boolean holdingUp, holdingRight, holdingLeft, holdingSpace, holdingQuickAttack, holdingStrongAttack;
  
  Keyboard() {
    holdingUp = holdingRight = holdingLeft = holdingSpace = holdingQuickAttack = holdingStrongAttack = false;
  }

  void pressKey(int key, int keyCode) {
    if (key == 'r' || key == 'R' || key == 'ρ' || key == 'Ρ') {
      if (gameEnded) { // if the game has been won...
        resetGame(theWorld.start_Grid, 1); // then R key resets it
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
