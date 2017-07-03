class WavesDrawer{

  final float SPEED = 300; //menor velocidad va mas rápido ........

  int n;
  WaveDrawer[] waveDrawers;//= new WaveDrawer[n];
  float[] radios = {0.25,0.2,0.1};
  float[] speeds = {SPEED,SPEED,SPEED};
  boolean[] doColor = {false, false, false};
  color[] colors = { color(85, 173, 71), color(50, 129, 186), color(255) };

  ArrayList<ArrayList<PVector>> waves;
  // PGraphics canvas;

  WavesDrawer(ArrayList<ArrayList<PVector>> waves){
    this.waves = waves;
    n = waves.size();
    // n = 1;
    waveDrawers = new WaveDrawer[n];

    // canvas = createGraphics(width, height);

    for(int i = 0;i<n;i++){
      waveDrawers[i] = new WaveDrawer(waves.get(i), radios[i],speeds[i], colors[i]);
      if ( doColor[i] ) {
         waveDrawers[i].doColor = true;
      }
    }
  }

  public PImage getMask( int waveIndex ) {
      return waveDrawers[waveIndex].getMask();
  }

  public void draw() {
    for(int i = 0;i<n;i++){
      waveDrawers[i].draw();
    }
  }
  public void update() {
    for(int i = 0;i<n;i++){
      waveDrawers[i].update();
    }
  }

}
