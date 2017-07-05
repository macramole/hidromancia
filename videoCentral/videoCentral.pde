import processing.video.*;
import gab.opencv.*;

Movie agua;
PImage aguaEdges;
PImage aguaSobel;

final int VIDEO_WIDTH = 800;
final int VIDEO_HEIGHT = 450;

color[] colors = { color(85, 173, 71), color(50, 129, 186), color(255) };

OpenCV opencv;
// int cannyLowThreshold = 211;
int cannyLowThreshold = 1;
int cannyHighThreshold = 300;

boolean needFrame = true;

WavesSearch wavesSearch;

ArrayList<ArrayList<PVector>> horizontalWaves;
final int WAVES_QTY = 3;

PrintWriter[] files;

void settings() {
    size(VIDEO_WIDTH, VIDEO_HEIGHT);
}

void setup() {
  // agua = new Movie(this, "ocean.mp4");
  agua = new Movie(this, "ocean.mid.m4v");
  agua.play();

  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);

  wavesSearch = new WavesSearch();

  horizontalWaves = new ArrayList<ArrayList<PVector>>(3);

  for ( int i = 0 ; i < WAVES_QTY ; i++ ) {
    horizontalWaves.add( new ArrayList<PVector>() );

  }

  // smooth(10);
  // frameRate(1);
  background(25);
}

void draw() {
    background(25);

  if ( needFrame && agua.available() ) {
    agua.read();

    /** Comentar esto para pasar de cuadro por cuadro a play */
    // needFrame = false;
    // agua.pause();
    /***/

    updateEdges();

    wavesSearch.searchWaves(aguaEdges.copy());
    // addNewHorizontalWaves();
  }

  // noTint();
  image(agua,0,0);

  // aguaEdges.loadPixels();
  for ( int y = 0 ; y < height ; y++ ) {
      for ( int x = 0 ; x < width ; x++ ) {
          if ( aguaEdges.get(x,y) == color(255) ) {
              aguaEdges.set( x,
                  y,
                  colors[ round( map(y, 0, VIDEO_HEIGHT,0,2 ) ) ] );
          } else {
              aguaEdges.set( x,
                  y,
                  color(0,0) );
          }
      }
  }
  // aguaEdges.updatePixels();

  tint(255, 150);
  image(aguaEdges, 0, 0);

  noTint();
  // wavesSearch.drawCurrentWave();
  // if ( aguaSobel != null ) {
  //     image(aguaSobel,0,0);
  // }
  // wavesSearch.drawCircles();
  // wavesSearch.drawHorizontally();
  // wavesSearch.drawHorizontallyThree( horizontalWaves );
  // wavesSearch.drawCurrentWaveHorizontally();

  // if ( horizontalWaves != null ) {
  //     wavesDrawer.draw(horizontalWaves);
  //     wavesDrawer.update(horizontalWaves);
  // }
  //
  // text( str(frameRate), 10, 20); //con 14 frames me dropea a 30fps

  saveFrame("out-######.png");

  if ( agua.duration() - agua.time() <= 0 ) {
      exit();
  }
}


void keyTyped() {
  if ( key == ' ' ) {
    agua.play();
    needFrame = true;
  }

  if ( key == 'x' )  {
      for ( PrintWriter f : files ) {
          f.close();
          exit();
      }
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

  if ( key == 'e' ) {
      wavesSearch.searchWaves(aguaEdges);
    //   wavesSearch.searchWaves(aguaEdges.copy());
  }
  if ( key == 'd' ) {
      wavesSearch.nextWave();
  }

  if ( key == 'r' ) {
      wavesSearch.WAVES_MIN_THRESHOLD++;
      println("WAVES_MIN_THRESHOLD: " + wavesSearch.WAVES_MIN_THRESHOLD);
  }
  if ( key == 'f' ) {
      wavesSearch.WAVES_MIN_THRESHOLD--;
      println("WAVES_MIN_THRESHOLD: " + wavesSearch.WAVES_MIN_THRESHOLD);
  }
}

void updateEdges() {
  opencv.loadImage(agua);
  // opencv.findSobelEdges(0,1);
  //opencv.findScharrEdges(OpenCV.BOTH);
  opencv.findCannyEdges(cannyLowThreshold,cannyHighThreshold);

  //opencv.dilate();
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
