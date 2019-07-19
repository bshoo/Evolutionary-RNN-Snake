class genome {
  game g;
  matrix[] weights;
  int[] structure;
  PVector food;

  genome(int[] structure, PVector foodLoc) {
    g = new game((int)foodLoc.x, (int)foodLoc.y);
    food = foodLoc;
    weights = new matrix[structure.length-1];
    for (int i = 0; i < structure.length - 1; i++) {
      weights[i] = new matrix(structure[i] + 1, structure[i+1]); //added 1 to the inputs so we have a thicc bias node
      weights[i].randomize();
    }
    this.structure = Arrays.copyOf(structure, structure.length);
  }

  void update() {
    if (g.lost == false) {
      float[] outputs = output(structure.length-1);
      g.updateGame(indexOfMaxValue(outputs,0,3),Arrays.copyOfRange(outputs, 0, outputs.length-1));
    }
  }
  
  int indexOfMaxValue(float[] x, int start, int end){
    float max = x[start];
    int maxIndex = start;
    for(int i = start; i <= end; i++){
      if(x[i] > max){
        max = x[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  float[] getData() {
    return g.exportData();
  }

  float[] output(int layer) {
    if (layer == 0) {
      return getData();
    }
    float[] prevLayer = output(layer - 1);
    float[] out = weights[layer - 1].outputs(prevLayer);
    return out;
  }

  void crossover(genome g) {
    for (int i = 0; i < weights.length; i++) {
      weights[i].crossover(g.weights[i]);
      weights[i].mutate(0.05);
    }
  }
  
  genome clone(PVector food){
    genome newGen = new genome(structure, food);
    for(int i = 0; i < weights.length; i++){
      newGen.weights[i] = weights[i].clone();
    }
    return newGen;
  }
}

//class genome {
//  game g;
//  matrix[] weights;
//  int[] structure;
//  PVector food;

//  genome(int[] structure, PVector foodLoc) {
//    g = new game((int)foodLoc.x, (int)foodLoc.y);
//    food = foodLoc;
//    weights = new matrix[structure.length-1];
//    for (int i = 0; i < structure.length - 1; i++) {
//      weights[i] = new matrix(structure[i] + 1, structure[i+1]); //added 1 to the inputs so we have a thicc bias node
//      weights[i].randomize();
//    }
//    this.structure = Arrays.copyOf(structure, structure.length);
//  }

//  void update() {
//    if (g.lost == false) {
//      float[] outputs = output(structure.length-1);
//      if (outputs[0] > outputs[1] && outputs[0] > outputs[2]) {
//        leftTurns++;
//        g.updateGame(-1, Arrays.copyOfRange(outputs, 3, outputs.length-1));
//      } else if (outputs[2] > outputs[0] && outputs[2] > outputs[1]) {
//        rightTurns++;
//        g.updateGame(1, Arrays.copyOfRange(outputs, 3, outputs.length-1));
//      } else {
//        g.updateGame(0, Arrays.copyOfRange(outputs, 3, outputs.length-1));
//      }
//      //g.show();
//    }
//  }
  
//  int indexOfMaxValue(float[] x){
//    float max = x[0];
//    int maxIndex = 0;
//    for(int i = 0; i < x.length; i++){
//      if(x[i] > max){
//        max = x[i];
//        maxIndex = i;
//      }
//    }
//    return maxIndex;
//  }

//  float[] getData() {
//    return g.exportData();
//  }

//  float[] output(int layer) {
//    if (layer == 0) {
//      return getData();
//    }
//    float[] prevLayer = output(layer - 1);
//    float[] out = weights[layer - 1].outputs(prevLayer);
//    return out;
//  }

//  void crossover(genome g) {
//    for (int i = 0; i < weights.length; i++) {
//      weights[i].crossover(g.weights[i]);
//      weights[i].mutate(0.05);
//    }
//  }
  
//  genome clone(){
//    genome newGen = new genome(structure, food);
//    for(int i = 0; i < weights.length; i++){
//      newGen.weights[i] = weights[i].clone();
//    }
//    return newGen;
//  }
//}
