import processing.video.*; //<>// //<>//
import gab.opencv.*;

Movie agua;
PImage aguaEdges;
PImage aguaSobel;

final int VIDEO_WIDTH = 800;
final int VIDEO_HEIGHT = 450;
// final int VIDEO_WIDTH = 1920;
// final int VIDEO_HEIGHT = 1080;

OpenCV opencv;
int cannyLowThreshold = 211;
// int cannyLowThreshold = 1;
int cannyHighThreshold = 300;

boolean needFrame = true;
boolean saveFrame = true;
int atFrame = 0;
String saveRoute = "/run/media/tomas/dataB/capture/screen-####.tif";
//String saveSoute = "data/capture/screen-####.tif";

WavesDrawer wavesDrawer;
final int WAVES_DRAWER_INTERPOLATION_FRAMECOUNT = 10;
ArrayList<ArrayList<PVector>> waves;
final int WAVES_QTY = 3;

PGraphics canvas;

color backgroundColor = color(25);
color averageColor = backgroundColor;

ColorReduction colorReduction;

void setup() {
  size(1920, 1080);

  frameRate(15);

  //agua = new Movie(this, "ocean.mp4");  
  agua = new Movie(this, "ocean.mid.mp4");
  // agua = new Movie(this, "ocean.hd.mp4");
  agua.loop();

  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);
  canvas = createGraphics(VIDEO_WIDTH, VIDEO_HEIGHT);

  initWaves();
  wavesDrawer = new WavesDrawer( waves );

  colorReduction = new ColorReduction();
}

void initWaves() {
  waves = new ArrayList<ArrayList<PVector>>(WAVES_QTY);
  BufferedReader reader;

  for ( int i = 1; i <= WAVES_QTY; i++ ) {
    reader = createReader( i + ".txt" );
    float x = 0;

    ArrayList<PVector> wave = new ArrayList<PVector>();

    try {
      String line = "";
      while ( (line = reader.readLine()) != null ) {
        PVector point = new PVector(x, float(line));
        wave.add(point);
        x++;
      }
    } 
    catch (IOException e) {
      e.printStackTrace();
    }

    waves.add( wave );
    println( "size of " + i + ": " + wave.size() );
  }
}

void draw() {
  background(backgroundColor);
  if(atFrame >= 2400){
    saveFrame = false;
  }

  if ( needFrame && agua.available() ) {
    agua.read();

    /** Comentar esto para pasar de cuadro por cuadro a play */
    // needFrame = false;
    // agua.pause();
    /***/

    updateEdges();
    agua.mask( wavesDrawer.getMask(2) );
    aguaEdges.mask( wavesDrawer.getMask(2) );
    // aguaSobel.mask( wavesDrawer.getMask(2) );
    // setAverageColor();
  }

  wavesDrawer.draw();
  // image(wavesDrawer.getMask(2),0,0);
  if ( frameCount % WAVES_DRAWER_INTERPOLATION_FRAMECOUNT == 0 ) {
    wavesDrawer.update();
  }

  noTint();
  image(agua, (width/2)-(VIDEO_WIDTH/2), height/2-(VIDEO_HEIGHT/2));
  tint(0, 255, 0, 80);
  image(aguaEdges, (width/2)-(VIDEO_WIDTH/2), height/2-(VIDEO_HEIGHT/2));

  // drawAverageColorCircles();
  if (saveFrame) {
    saveFrame(saveRoute);
  }

  fill(255);
  text( str(frameRate), 10, 20); 
  // text( mouseX + "," + mouseY, 10, 40 );
  atFrame++;
}

void drawAverageColorCircles() {
  // x 163
  // x 1680
  //colorReduction.processOptimizedPalette(agua, 4);

  int x = width/9;
  int y = height/4;
  int diameter = 200;

  noStroke();

  fill( getAverageColor() );
  ellipse(x, y, diameter, diameter);
  fill( getAverageColor() );
  ellipse(x, y * 2, diameter, diameter);
  fill( getAverageColor() );
  ellipse(x, y * 3, diameter, diameter);

  y = height/6;

  fill( getAverageColor() );
  ellipse(x * 8, y * 2, diameter, diameter);
  fill( getAverageColor() );
  ellipse(x * 8, y * 4, diameter, diameter);
}

void keyTyped() {
  if ( key == ' ' ) {
    agua.play();
    needFrame = true;
  }

  if ( key == 'q' ) {
    cannyLowThreshold++;
  }
  if ( key == 'a' ) {
    cannyLowThreshold--;
  }
  if ( key == 'w' ) {
    cannyHighThreshold++;
  }
  if ( key == 's' ) {
    cannyHighThreshold--;
  }

  switch(key) {
  case 'q':
  case 'a':
  case 'w':
  case 's':
    updateEdges();
    println("cannyLowThreshold: " + cannyLowThreshold);
    println("cannyHighThreshold: " + cannyHighThreshold);
  }
}

void setAverageColor() {
  averageColor = getAverageColor();
}

color getAverageColor() {
  int averageCantPuntos = floor(VIDEO_WIDTH * VIDEO_HEIGHT * 0.1); //10% de los puntos

  int r = 0;
  int g = 0;
  int b = 0;

  for ( int i = 0; i < averageCantPuntos; i++ ) {
    color currentColor = agua.get( round( random(0, VIDEO_WIDTH) ), round( random(0, VIDEO_HEIGHT) ) );
    r += red(currentColor);
    g += green(currentColor);
    b += blue(currentColor);
  }

  r /= averageCantPuntos;
  g /= averageCantPuntos;
  b /= averageCantPuntos;

  return  color(r, g, b);
}

void updateEdges() {
  opencv.loadImage(agua);
  // opencv.findSobelEdges(0,1);
  //opencv.findScharrEdges(OpenCV.BOTH);
  opencv.findCannyEdges(cannyLowThreshold, cannyHighThreshold);

  opencv.dilate();
  //opencv.erode();

  aguaEdges = opencv.getSnapshot();

  // opencv.loadImage(agua);
  // opencv.findSobelEdges(0,1);
  // aguaSobel = opencv.getSnapshot();
}

void printColor(color a) {
  println( "(" + red(a) + "," + green(a) + "," + blue(a) + ")" );
}

// Called every time a new frame is available to read
//void movieEvent(Movie m) {
//  m.read();
//}