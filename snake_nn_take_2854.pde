import java.util.*;

int[] layerStructure = {0, 128, 64, 16};
boolean showDebug = false;
int population = 1000;
float randomizationRate = 0.5;
int baseLength = 25;
int genomesPerBatch = 20;

generation g;
int tempBaseLength = baseLength;
boolean warpSpeed = false;
ArrayList<Float> pastMaxFitnesses = new ArrayList<Float>();
ArrayList<Float> pastAvgFitnesses = new ArrayList<Float>();
ArrayList<Integer> pastMaxScores = new ArrayList<Integer>();
ArrayList<ArrayList<Integer>> pastOutcomes = new ArrayList<ArrayList<Integer>>();
int leftTurns = 0;
int rightTurns = 0;
int starved = 0;
int selfCollision = 0;
int wallCollision = 0;
PVector foodQuadrant = new PVector(1,1);

void setup() {
  layerStructure[0] = 125 + layerStructure[layerStructure.length-1];
  g = new generation(population);
  size(1280, 720);
  frameRate(60);
  pastMaxScores.add(0);
  pastMaxFitnesses.add(0.0);
  pastAvgFitnesses.add(0.0);
  pastOutcomes.add(new ArrayList<Integer>());
  pastOutcomes.add(new ArrayList<Integer>());
  pastOutcomes.add(new ArrayList<Integer>());
}

void draw() {
  background(51);
  stroke(255);
  strokeWeight(2);
  line(width - height - 2, 0, width - height - 2, height);
  textSize(14);
  fill(255);
  String bLength = "Base Length: " + tempBaseLength;
  String wSpeed = "Warp Speed: " + warpSpeed;
  String gen = "Generation: " + g.generation;
  String batch = "Batch: " + g.iteration;
  String rms = "Recent Max Score: " + pastMaxScores.get(pastMaxScores.size()-1);
  String starve = "Starved: " + starved;
  String self = "Self Collision: " + selfCollision;
  String wall = "Wall Collision: " + wallCollision;
  text(bLength, 10, 24);
  text(wSpeed, 10, 40);
  text(gen, 10, 56);
  text(batch, 10, 72);
  text(rms, 10, 88);
  text(starve, 10, 104);
  text(self, 10, 120);
  text(wall, 10, 136);
  strokeWeight(1);
  for (int i = 0; i < pastMaxFitnesses.size()-1; i++) {
    line(i + 10, 200-log(pastMaxFitnesses.get(i)) * 2, i+11, 200-log(pastMaxFitnesses.get(i+1)) * 2);
  }
  for (int i = 0; i < pastAvgFitnesses.size()-1; i++) {
    line(i + 10, 300-log(pastAvgFitnesses.get(i)) * 2, i+11, 300-log(pastAvgFitnesses.get(i+1)) * 2);
  }
  for (int i = 0; i < pastMaxScores.size()-1; i++) {
    line(i + 10, 400-pastMaxScores.get(i), i+11, 400-pastMaxScores.get(i+1));
  }
  for (int i = 0; i < pastOutcomes.get(0).size()-1; i++) {
    line(i + 10, 500-pastOutcomes.get(0).get(i) / 50, i+11, 500-pastOutcomes.get(0).get(i+1) / 50);
  }
  for (int i = 0; i < pastOutcomes.get(1).size()-1; i++) {
    line(i + 10, 600-pastOutcomes.get(1).get(i) / 50, i+11, 600-pastOutcomes.get(1).get(i+1) / 50);
  }
  for (int i = 0; i < pastOutcomes.get(2).size()-1; i++) {
    line(i + 10, 700-pastOutcomes.get(2).get(i) / 50, i+11, 700-pastOutcomes.get(2).get(i+1) / 50);
  }
  if (!warpSpeed) {
    g.updateAll();
    g.showOne();
  } else {
    g.updateToCompletion();
  }

  if (g.isEveryoneDead() == true) {
    println(g.avgFitness());
    if(g.iteration != population/genomesPerBatch) {
    g.iteration++;
    g.selectSuccessful();
    g.populate();
    } else {
      foodQuadrant.rotate(HALF_PI);
      pastMaxFitnesses.add(g.maxFitness());
      pastAvgFitnesses.add(g.avgFitness());
      pastMaxScores.add(g.maxScore());
      pastOutcomes.get(0).add(starved);
      pastOutcomes.get(1).add(selfCollision);
      pastOutcomes.get(2).add(wallCollision);
      if (pastMaxFitnesses.size() > 300)
        pastMaxFitnesses.remove(0);
      if (pastAvgFitnesses.size() > 300)
        pastAvgFitnesses.remove(0);  
      if (pastMaxScores.size() > 300)
        pastMaxScores.remove(0);
      if (pastOutcomes.get(0).size() > 300)
        pastOutcomes.get(0).remove(0);
      if (pastOutcomes.get(1).size() > 300)
        pastOutcomes.get(1).remove(0);
      if (pastOutcomes.get(2).size() > 300)
        pastOutcomes.get(2).remove(0);
      println("Creating next generation...");
      baseLength = tempBaseLength;
      g = g.nextGeneration();
      leftTurns = 0;
      rightTurns = 0;
      starved = 0;
      selfCollision = 0;
      wallCollision = 0;
    }
  }
}

void keyPressed() {
  if (keyCode == UP) {
    tempBaseLength++;
  }
  if (keyCode == DOWN) {
    tempBaseLength = max(0, tempBaseLength-1);
  }
  if (keyCode == LEFT) {
    warpSpeed = false;
  }
  if (keyCode == RIGHT) {
    warpSpeed = true;
  }
  redraw();
}
