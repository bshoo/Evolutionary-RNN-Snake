class generation {
  genome[] genomes;
  ArrayList<genome> successfulGenomes = new ArrayList<genome>();
  genome[] pastSuccessfulGenomes;
  int pop;
  int currentlyShowing = 0;
  int generation = 0;
  int iteration = 0;
  PVector randomFood = new PVector(floor(random(height/40)) * foodQuadrant.x + height/40, floor(random(height/40)) * foodQuadrant.y + height/40);

  generation(int population) {;
    genomes = new genome[genomesPerBatch];
    println(randomFood.x + " " + foodQuadrant.x);
    println(randomFood.y + " " + foodQuadrant.y);
    for (int i = 0; i < genomes.length; i++) {
      genomes[i] = new genome(layerStructure, randomFood);
    }
    pop = population;
  }

  void updateAll() {
    for (genome g : genomes) {
      g.update();
    }
  }

  boolean isEveryoneDead() {
    for (genome g : genomes) {
      if (g.g.lost == false)
        return false;
    }
    return true;
  }

  float[] getFitnesses(genome[] in) {
    float[] fitnesses = new float[in.length];
    for (int i = 0; i < in.length; i++) {
      fitnesses[i] = in[i].g.fitness;
    }
    return fitnesses;
  }

  generation nextGeneration() {
    generation g = new generation(pop);
    g.pastSuccessfulGenomes = Arrays.copyOf(toGenomeArray(successfulGenomes), successfulGenomes.size());
    g.populate();
    g.generation = generation + 1;
    return g;
  }

  void populate() {
    if (generation == 0) {
      for (int i = 0; i < genomes.length; i++) {
        genomes[i] = new genome(layerStructure, randomFood);
      }
      return;
    }
    float[] fitnesses = getFitnesses(pastSuccessfulGenomes);
    float maxFitness = max(fitnesses);
    for (int i = 0; i < genomes.length; i++) {      
      genomes[i] = new genome(layerStructure, randomFood);
      int genome1 = (int)random(pastSuccessfulGenomes.length);
      int genome2 = (int)random(pastSuccessfulGenomes.length);
      float random1 = random(maxFitness);
      float random2 = random(maxFitness);
      while (fitnesses[genome1] < random1) {
        genome1 = (int)random(pastSuccessfulGenomes.length);
        random1 = random(maxFitness);
      }
      while (fitnesses[genome2] < random2) {
        genome2 = (int)random(pastSuccessfulGenomes.length);
        random2 = random(maxFitness);
      }
      genomes[i] = pastSuccessfulGenomes[genome1].clone(randomFood);
      genomes[i].crossover(pastSuccessfulGenomes[genome2]);
    }
  }

  void selectSuccessful() {
    float[] fitnesses = getFitnesses(genomes);
    successfulGenomes.add(genomes[indexOf(fitnesses, max(fitnesses))]);
  }

  genome[] toGenomeArray(ArrayList<genome> in) {
    genome[] out = new genome[in.size()];
    for (int i = 0; i < in.size(); i++) {
      out[i] = in.get(i);
    }
    return out;
  }

  int indexOf(float[] array, float a) {
    for (int i = 0; i < array.length; i++) {
      if (array[i] == a) {
        return i;
      }
    }
    return -1;
  }

  void showOne() { //it's waiting until there's a longer snake than the one at index 0
    if (genomes[currentlyShowing].g.lost == true) {
      int maxIndex = 0;
      for (int i = 0; i < genomes.length; i++) {
        if (genomes[i].g.snakeLength > genomes[maxIndex].g.snakeLength && genomes[i].g.lost == false || maxIndex == 0 && genomes[i].g.lost == false) {
          maxIndex = i;
        }
      }
      currentlyShowing = maxIndex;
    }
    String id = "ID: " + currentlyShowing;
    genomes[currentlyShowing].g.show();
    fill(255);
    text(id, width - height + 10, 40);
  }
  
  float[] getFitnessesAL(ArrayList<genome> in){
    float[] out = new float[in.size()];
    for(int i = 0; i < in.size(); i++){
      out[i] = in.get(i).g.fitness;
    }
    return out;
  }
  
  float avgFitness() {
    float sum = 0;
    float[] fitnesses = getFitnessesAL(successfulGenomes);
    for (float f : fitnesses) {
      sum += f;
    }
    return sum/(float)fitnesses.length;
  }

  float maxFitness() {
    float[] fitnesses = getFitnessesAL(successfulGenomes);
    return max(fitnesses);
  }

  int maxScore() {
    int max = 0;
    for (genome g : successfulGenomes) {
      max = max(max, g.g.snakeLength - baseLength);
    }
    return max;
  }

  void updateToCompletion() {
    while (!isEveryoneDead()) {
      updateAll();
    }
  }
}


//generation nextGeneration(){
//  int randomx = (int)random(0,height/20);
//  int randomy = (int)random(0,height/20);
//  randomFood = new PVector(randomx,randomy);
//  genome[] newGenomes = new genome[pop];
//  float[] fitnesses = getFitnesses();
//  float maxFitness = max(fitnesses);
//  newGenomes[0] = genomes[indexOf(fitnesses, max(fitnesses))].clone(randomFood); //chance this will break things bc cloning
//  for(int i = 1; i < ceil(pop * randomizationRate) + 1; i++){
//    newGenomes[i] = new genome(layerStructure, randomFood);
//  }
//  for(int i = 1 + ceil(pop * randomizationRate); i < pop; i++){
//    int genome1 = (int)random(genomes.length);
//    int genome2 = (int)random(genomes.length);
//    float random1 = random(maxFitness);
//    float random2 = random(maxFitness);
//    while(fitnesses[genome1] < random1){
//      genome1 = (int)random(genomes.length);
//      random1 = random(maxFitness);
//    }
//    while(fitnesses[genome2] < random2){
//      genome2 = (int)random(genomes.length);
//      random2 = random(maxFitness);
//    }
//    newGenomes[i] = genomes[genome1].clone(randomFood);
//    newGenomes[i].crossover(genomes[genome2]);
//  }
//  generation g = new generation(pop);
//  g.genomes = newGenomes;
//  g.generation = generation + 1;
//  return g;
//}
