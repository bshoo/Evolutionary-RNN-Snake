class pixel {
  private int[] status = {0, 0, 0}; //Head, Body, Food
  private int[] loc = new int[2];
  
  pixel(int x, int y){
    loc[0] = x;
    loc[1] = y;
  }
  
  int[] getStatus(){
    return status;
  }
  
  void setHead(int x){
    status[0] = x;
  }
  
  void setBody(int x){
    status[1] = x;
  }
  
  void setFood(int x){
    status[2] = x;
  }
  
  void show() {
    noStroke();
    if(status[2] == 1){
      fill(244, 92, 66);
    }
    if(status[1] == 1){
      fill(255);
    }
    if(status[0] == 1){
      fill(120);
    }
    if(status[0] != 0 || status[1] != 0 || status[2] != 0){
      rect(loc[0] * 20 + 1 + (width-height), loc[1] * 20 + 1, 18, 18, 1);
    }
  }
}
