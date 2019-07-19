class game {
  ArrayList<ArrayList<pixel>> gPixels = new ArrayList<ArrayList<pixel>>();
  ArrayList<int[]> tail = new ArrayList<int[]>();
  int[] position;
  int[] direction = {0, 1}; //LR, UD
  int[] food = new int[2];
  int snakeLength = 0;
  int hungerMeter = 100;
  int lifetime = 0;
  float[] predictedNextMove;
  float fitness;
  boolean lost = false;
  float previousDistance = 100;
  double multiplier = 1;

  game(int x, int y) {
    food[0] = x;
    food[1] = y;
    for (int i = 0; i < height/20; i++) {
      gPixels.add(new ArrayList<pixel>());
      for (int j = 0; j < height/20; j++) {
        gPixels.get(i).add(new pixel(i, j));
      }
    }
    position = new int[2];
    position[0] = gPixels.size()/2;
    position[1] = gPixels.get(0).size()/2;
    gPixels.get(position[0]).get(position[1]).setHead(1);
    gPixels.get(food[0]).get(food[1]).setFood(1);
    snakeLength += baseLength;
  }

  //-----Game Updates-----

  void changeDirection(int x, int y) {
    direction[0] = x;
    direction[1] = y;
  }

  void updateGame(int x, float[] y) {
    if (x == 0) {
      changeDirection(0, -1);
    }
    if (x == 1) {
      changeDirection(1, 0);
    }
    if (x == 2) {
      changeDirection(0, 1);
    }
    if (x == 3) {
      changeDirection(-1, 0);
    }
    predictedNextMove = y;
    playGame();
  }

  void changePos() {
    tail(); 
    position[0] += direction[0]; 
    position[1] += direction[1]; 
    if (!pixelExists(position[0], position[1])) {
      position[0] -= direction[0]; 
      position[1] -= direction[1]; 
      lost = true;
      wallCollision++;
    } else if (gPixels.get(position[0]).get(position[1]).getStatus()[1] == 1) {
      selfCollision++;
      lost = true;
    }
  }

  void tail() {
    int[] temp = new int[2]; 
    temp[0] = position[0]; 
    temp[1] = position[1]; 
    tail.add(temp); 
    while (tail.size() > snakeLength) {
      gPixels.get(tail.get(0)[0]).get(tail.get(0)[1]).setBody(0); 
      tail.remove(0);
    }
    for (int i = 0; i < tail.size(); i++) {
      gPixels.get(tail.get(i)[0]).get(tail.get(i)[1]).setBody(1);
    }
  }

  void playGame() {
    if (lost == false) {
      changePos(); //Calls tail() to handle tail
      if (position[0] == food[0] && position[1] == food[1]) {
        snakeLength++;
        gPixels.get(food[0]).get(food[1]).setFood(0);
        food[0] = int(random(gPixels.size()));
        food[1] = int(random(gPixels.get(0).size()));
        hungerMeter += 100 * max(1, (snakeLength)/50);
      }
      gPixels.get(position[0] - direction[0]).get(position[1] - direction[1]).setHead(0);
      gPixels.get(position[0]).get(position[1]).setHead(1);
      gPixels.get(food[0]).get(food[1]).setFood(1);
    }
    hungerMeter--;
    lifetime++;
    fitness = calcFitness();
    if (hungerMeter == 0) {
      starved++;
      lost = true;
    }
    //float[] dab = vision();
  }

  void show() {
    if (lost == false) {
      String hungerValue = "Food remaining: " + hungerMeter;
      text(hungerValue, width - height + 10, 20);
      for (int i = 0; i < gPixels.size(); i++) {
        for (int j = 0; j < gPixels.get(i).size(); j++) {
          gPixels.get(i).get(j).show();
        }
      }
    }
  }

  //-----Utility-----

  float calcFitness() {
    //float dist = dist(position[0], position[1], food[0], food[1]);
    //if (dist > previousDistance) {
    //  multiplier /= 1.05;
    //} else {
    //  multiplier *= 1.02;
    //}
    //previousDistance = dist;
    //float fitness = (float)(pow(lifetime, 0.5) * pow(snakeLength-baseLength + 1, 2) * multiplier);
    float fitness = lifetime + 1000 * pow(snakeLength-baseLength,2);
    return fitness;
  }

  float[] exportData() {
    float[] radar = vision();
    float[] data;
    try {
      data = new float[radar.length + predictedNextMove.length];
      for (int i = 0; i < predictedNextMove.length; i++) {
        data[data.length-1-i] = predictedNextMove[i];
      }
    } 
    catch(Exception NullPointerException) {
      data = new float[radar.length + layerStructure[layerStructure.length-1]-3];
      for (int i = 0; i < layerStructure[layerStructure.length-1]-3; i++) {
        data[data.length-1-i] = 0;
      }
    }
    for (int i = 0; i < radar.length; i++) {
      data[i] = radar[i];
    }
    return data;
  }


  float[] vision() {
    float[] vision = new float[125];
    vision[0] = position[0]/(float)gPixels.size();
    vision[1] = position[1]/(float)gPixels.get(0).size();
    vision[2] = food[0]/(float)gPixels.size();
    vision[3] = food[1]/(float)gPixels.get(0).size();
    int count = 4;
    for (int i = -5; i <= 5; i++) {
      for (int j = -5; j <= 5; j++, count++) {
        if (i + position[0] >= height/20 || i + position[0] < 0 || j + position[1] >= height/20 || j + position[1] < 0) {
          vision[count] = 1;
        } else {
          vision[count] = gPixels.get(i + position[0]).get(j + position[1]).status[1] - gPixels.get(i + position[0]).get(j + position[1]).status[0];
        }
      }
    }
    return vision;
  }

  //float[] vision() {
  //  float[] vision = new float[gPixels.size() * gPixels.get(0).size() + 4];
  //  vision[0] = position[0]/(float)gPixels.size();
  //  vision[1] = position[1]/(float)gPixels.get(0).size();
  //  vision[2] = food[0]/(float)gPixels.size();
  //  vision[3] = food[1]/(float)gPixels.get(0).size();
  //  for(int i = 0; i < gPixels.size(); i++){
  //    for(int j = 0; j < gPixels.get(i).size(); j++){
  //      vision[gPixels.get(i).size() * i + j + 4] = gPixels.get(i).get(j).status[1] - gPixels.get(i).get(j).status[0];
  //    }
  //  }
  //  return vision;
  //}

  float[] lookInDirection(PVector direction) {
    float[] look = new float[4];
    boolean foodFound = false;
    boolean bodyFound = false;
    PVector pos = new PVector(position[0], position[1]);
    int distance = 0;
    pos.add(direction);
    distance++;
    while (pixelExists((int)pos.x, (int)pos.y)) {
      if (gPixels.get((int)pos.x).get((int)pos.y).getStatus()[2] == 1 && foodFound == false) {
        foodFound = true;
        look[3] = 1;
      }
      if (gPixels.get((int)pos.x).get((int)pos.y).getStatus()[1] == 1 && bodyFound == false) {
        bodyFound = true;
        look[2] = 1/(float)distance;
        look[1] = 1;
      }
      pos.add(direction);
      distance++;
    }
    look[0] = 1/(float)distance;
    if (showDebug) {
      String debug = ceil(look[0]*10000)/(float)10000 + "\n" + look[1] + "\n" + ceil(look[2]*10000)/(float)10000 + "\n" + look[3];
      PVector debugLoc = new PVector((width-height)/2-25, height/2-50);
      debugLoc.add(direction.mult(100));
      fill(255);
      textAlign(CENTER);
      text(debug, debugLoc.x, debugLoc.y, 50, 100);
    }
    return look;
  }

  int dirToInt(int[] d) {
    if (d[1] == -1) {
      return 0;
    } else if (d[0] == 1) {
      return 1;
    } else if (d[1] == 1) {
      return 2;
    } else if (d[0] == -1) {
      return 3;
    }
    return 0;
  }

  int[] intToDir(int d) {
    if (d == 0) {
      int[] out = {0, -1};
      return out;
    } else if (d == 1) {
      int[] out = {1, 0};
      return out;
    } else if (d == 2) {
      int[] out = {0, 1};
      return out;
    } else {
      int[] out = {-1, 0};
      return out;
    }
  }

  PVector floatToDir(float d) {
    if (d == 0 || d == 4) {
      PVector out = new PVector(0, -1);
      return out;
    } else if (d == 1) {
      PVector out = new PVector(1, 0);
      return out;
    } else if (d == 2) {
      PVector out = new PVector(0, 1);
      return out;
    } else if (d == 3) {
      PVector out = new PVector(-1, 0);
      return out;
    } else {
      return floatToDir(floor(d)).add(floatToDir(ceil(d)));
    }
  }

  ArrayList<PVector> allDirections(int d) {
    ArrayList<PVector> directions = new ArrayList<PVector>();
    float direction = d;
    do {
      directions.add(floatToDir(direction));
      direction += 0.5;
      if (direction == 4) {
        direction = 0;
      }
    } while (direction != d);
    return directions;
  }

  boolean pixelExists(int x, int y) {
    if (x < 0 || y < 0) {
      return false;
    }
    if (x >= gPixels.size() || y >= gPixels.get(0).size()) {
      return false;
    }
    return true;
  }
}

//class game {
//  ArrayList<ArrayList<pixel>> gPixels = new ArrayList<ArrayList<pixel>>();
//  ArrayList<int[]> tail = new ArrayList<int[]>();
//  int[] position;
//  int[] direction = {0, 1}; //LR, UD
//  int[] food = new int[2];
//  int snakeLength = 0;
//  int hungerMeter = 300;
//  int lifetime = 0;
//  float[] predictedNextMove;
//  float fitness;
//  boolean lost = false;
//  float previousDistance = 100;
//  double multiplier = 1;

//  game(int x, int y) {
//    food[0] = x;
//    food[1] = y;
//    for (int i = 0; i < height/20; i++) {
//      gPixels.add(new ArrayList<pixel>());
//      for (int j = 0; j < height/20; j++) {
//        gPixels.get(i).add(new pixel(i, j));
//      }
//    }
//    position = new int[2];
//    position[0] = gPixels.size()/2;
//    position[1] = gPixels.get(0).size()/2;
//    gPixels.get(position[0]).get(position[1]).setHead(1);
//    gPixels.get(food[0]).get(food[1]).setFood(1);
//    snakeLength += baseLength;
//  }

//  //-----Game Updates-----

//  void changeDirection(int x, int y) {
//    direction[0] = x;
//    direction[1] = y;
//  }

//  void updateGame(int x, float[] y) {
//    turn(x);
//    predictedNextMove = y;
//    playGame();
//  }

//  void turn(int x) {
//    if (x == -1) { //Left
//      if (direction[1] == -1) {
//        changeDirection(1, 0);
//      } else if (direction[0] == 1) {
//        changeDirection(0, 1);
//      } else if (direction[1] == 1) {
//        changeDirection(-1, 0);
//      } else if (direction[0] == -1) {
//        changeDirection(0, -1);
//      }
//    } else if (x == 1) { //Right
//      if (direction[1] == -1) {
//        changeDirection(-1, 0);
//      } else if (direction[0] == 1) {
//        changeDirection(0, -1);
//      } else if (direction[1] == 1) {
//        changeDirection(1, 0);
//      } else if (direction[0] == -1) {
//        changeDirection(0, 1);
//      }
//    }
//  }

//  void changePos() {
//    tail(); 
//    position[0] += direction[0]; 
//    position[1] += direction[1]; 
//    if (!pixelExists(position[0], position[1])) {
//      position[0] -= direction[0]; 
//      position[1] -= direction[1]; 
//      lost = true;
//      wallCollision++;
//    } else if (gPixels.get(position[0]).get(position[1]).getStatus()[1] == 1) {
//      selfCollision++;
//      lost = true;
//    }
//  }

//  void tail() {
//    int[] temp = new int[2]; 
//    temp[0] = position[0]; 
//    temp[1] = position[1]; 
//    tail.add(temp); 
//    while (tail.size() > snakeLength) {
//      gPixels.get(tail.get(0)[0]).get(tail.get(0)[1]).setBody(0); 
//      tail.remove(0);
//    }
//    for (int i = 0; i < tail.size(); i++) {
//      gPixels.get(tail.get(i)[0]).get(tail.get(i)[1]).setBody(1);
//    }
//  }

//  void playGame() {
//    if (lost == false) {
//      changePos(); //Calls tail() to handle tail
//      if (position[0] == food[0] && position[1] == food[1]) {
//        snakeLength++;
//        gPixels.get(food[0]).get(food[1]).setFood(0);
//        food[0] = int(random(gPixels.size()));
//        food[1] = int(random(gPixels.get(0).size()));
//        hungerMeter += 100 * max(1, (snakeLength)/50);
//      }
//      gPixels.get(position[0] - direction[0]).get(position[1] - direction[1]).setHead(0);
//      gPixels.get(position[0]).get(position[1]).setHead(1);
//      gPixels.get(food[0]).get(food[1]).setFood(1);
//    }
//    hungerMeter--;
//    lifetime++;
//    fitness = calcFitness();
//    if (hungerMeter == 0) {
//      starved++;
//      lost = true;
//    }
//    //float[] dab = vision();
//  }

//  void show() {
//    if (lost == false) {
//      String hungerValue = "Food remaining: " + hungerMeter;
//      text(hungerValue, width - height + 10, 20);
//      for (int i = 0; i < gPixels.size(); i++) {
//        for (int j = 0; j < gPixels.get(i).size(); j++) {
//          gPixels.get(i).get(j).show();
//        }
//      }
//    }
//  }

//  //-----Utility-----

//  float calcFitness() {
//    float dist = dist(position[0], position[1], food[0], food[1]);
//    if (dist > previousDistance) {
//      multiplier /= 1.1;
//    } else {
//      multiplier *= 1.02;
//    }
//    previousDistance = dist;
//    float fitness = (float)(pow(lifetime, 2) * pow(snakeLength-baseLength, 2) * multiplier);
//    return fitness;
//  }

//  float[] exportData() {
//    float[] radar = vision();
//    float[] data;
//    try {
//      data = new float[radar.length + predictedNextMove.length];
//      for (int i = 0; i < predictedNextMove.length; i++) {
//        data[data.length-1-i] = predictedNextMove[i];
//      }
//    } 
//    catch(Exception NullPointerException) {
//      data = new float[radar.length + layerStructure[layerStructure.length-1]-3];
//      for (int i = 0; i < layerStructure[layerStructure.length-1]-3; i++) {
//        data[data.length-1-i] = 0;
//      }
//    }
//    for (int i = 0; i < radar.length; i++) {
//      data[i] = radar[i];
//    }
//    return data;
//  }

//  float[] vision() {
//    float[] vision = new float[32];
//    ArrayList<PVector> directions = allDirections(dirToInt(direction));
//    for (int i = 0; i < directions.size(); i++) {
//      float[] temp = lookInDirection(directions.get(i));
//      for (int j = 0; j < temp.length; j++) {
//        vision[i * 4 + j] = temp[j];
//      }
//    }
//    if (showDebug) {
//      fill(255);
//      textAlign(CENTER);
//      text("wall\nbody 1\nbody 2\nfood", (width-height)/2-25, height/2-50, 50, 100);
//    }
//    return vision;
//  }

//  float[] lookInDirection(PVector direction) {
//    float[] look = new float[4];
//    boolean foodFound = false;
//    boolean bodyFound = false;
//    PVector pos = new PVector(position[0], position[1]);
//    int distance = 0;
//    pos.add(direction);
//    distance++;
//    while (pixelExists((int)pos.x, (int)pos.y)) {
//      if (gPixels.get((int)pos.x).get((int)pos.y).getStatus()[2] == 1 && foodFound == false) {
//        foodFound = true;
//        look[3] = 1;
//      }
//      if (gPixels.get((int)pos.x).get((int)pos.y).getStatus()[1] == 1 && bodyFound == false) {
//        bodyFound = true;
//        look[2] = 1/(float)distance;
//        look[1] = 1;
//      }
//      pos.add(direction);
//      distance++;
//    }
//    look[0] = 1/(float)distance;
//    if (showDebug) {
//      String debug = ceil(look[0]*10000)/(float)10000 + "\n" + look[1] + "\n" + ceil(look[2]*10000)/(float)10000 + "\n" + look[3];
//      PVector debugLoc = new PVector((width-height)/2-25, height/2-50);
//      debugLoc.add(direction.mult(100));
//      fill(255);
//      textAlign(CENTER);
//      text(debug, debugLoc.x, debugLoc.y, 50, 100);
//    }
//    return look;
//  }

//  int dirToInt(int[] d) {
//    if (d[1] == -1) {
//      return 0;
//    } else if (d[0] == 1) {
//      return 1;
//    } else if (d[1] == 1) {
//      return 2;
//    } else if (d[0] == -1) {
//      return 3;
//    }
//    return 0;
//  }

//  int[] intToDir(int d) {
//    if (d == 0) {
//      int[] out = {0, -1};
//      return out;
//    } else if (d == 1) {
//      int[] out = {1, 0};
//      return out;
//    } else if (d == 2) {
//      int[] out = {0, 1};
//      return out;
//    } else {
//      int[] out = {-1, 0};
//      return out;
//    }
//  }

//  PVector floatToDir(float d) {
//    if (d == 0 || d == 4) {
//      PVector out = new PVector(0, -1);
//      return out;
//    } else if (d == 1) {
//      PVector out = new PVector(1, 0);
//      return out;
//    } else if (d == 2) {
//      PVector out = new PVector(0, 1);
//      return out;
//    } else if (d == 3) {
//      PVector out = new PVector(-1, 0);
//      return out;
//    } else {
//      return floatToDir(floor(d)).add(floatToDir(ceil(d)));
//    }
//  }

//  ArrayList<PVector> allDirections(int d) {
//    ArrayList<PVector> directions = new ArrayList<PVector>();
//    float direction = d;
//    do {
//      directions.add(floatToDir(direction));
//      direction += 0.5;
//      if (direction == 4) {
//        direction = 0;
//      }
//    } while (direction != d);
//    return directions;
//  }

//  boolean pixelExists(int x, int y) {
//    if (x < 0 || y < 0) {
//      return false;
//    }
//    if (x >= gPixels.size() || y >= gPixels.get(0).size()) {
//      return false;
//    }
//    return true;
//  }
//}
