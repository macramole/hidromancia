class WavesDrawer{

  final float SPEED = 300; //menor velocidad va mas rápido ........

  int n;
  WaveDrawer[] waves;//= new WaveDrawer[n];
  float[] radios = {0.1,0.2,0.4};
  float[] speeds = {SPEED,SPEED,SPEED};

  // PGraphics canvas;

  WavesDrawer(){
    n = 3;
    waves = new WaveDrawer[n];

    // canvas = createGraphics(width, height);

    for(int i = 0;i<n;i++){
      waves[i] = new WaveDrawer(radios[i],speeds[i]);
    }
  }

  public void draw(ArrayList<ArrayList<PVector>> points){
    for(int i = 0;i<n;i++){
      waves[i].draw(points.get(i));
    }
  }
  public void update(ArrayList<ArrayList<PVector>> points){
    for(int i = 0;i<n;i++){
      waves[i].update(points.get(i));
    }
  }

}
