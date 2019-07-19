class matrix {
  float[][] matrix;
  
  matrix(int dim1, int dim2){
    matrix = new float[dim1][dim2];
  }
  
  void randomize(){
    for(int i = 0; i < matrix.length; i++){
      for(int j = 0; j < matrix[i].length; j++){
        matrix[i][j] = (float)random(-1,1);
      }
    }
  }
  
  float get(int param1, int param2){
    return matrix[param1][param2];
  }
  
  float[] outputs(float[] inputs){
    float[] out = new float[matrix[0].length];
    for(int i = 0; i < out.length; i++){
      float sum = 0;
      for(int j = 0; j < inputs.length; j++){
        sum += inputs[j] * matrix[j][i];
      }
      sum += matrix[matrix.length-1][i];
      out[i] = relu((float)sum);
    }
    return out;
  }
  
  float relu(float input){
    float out = max(0, input);
    return sqrt(out)/sqrt(1+out);
  }
  
  void crossover(matrix m){
    int randColumn = (int)random(matrix.length);
    int randRow = (int)random(matrix[0].length);
    
    for(int i = 0; i < randColumn; i++){
      for(int j = 0; j < randRow; j++){
        matrix[i][j] = m.get(i,j);
      }
    }
  }
  
  void mutate(float rate){
    for(int i = 0; i < matrix.length; i++){
      for(int j = 0; j < matrix[0].length; j++){
        float rand = random(1);
        if(rand < rate){
          matrix[i][j] += randomGaussian()/5;
          matrix[i][j] = min(matrix[i][j],1);
          matrix[i][j] = max(matrix[i][j],-1);
        }
      }
    }
  }
  
  matrix clone(){
    matrix m = new matrix(matrix.length, matrix[0].length);
    for(int i = 0; i < matrix.length; i++){
      for(int j = 0; j < matrix[i].length; j++){
        m.matrix[i][j] = matrix[i][j];
      }
    }
    return m;
  }
}
