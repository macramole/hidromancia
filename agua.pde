import processing.video.*;
import gab.opencv.*;

Movie agua;
PImage aguaEdges;
PImage aguaSobel;

final int VIDEO_WIDTH = 640;
final int VIDEO_HEIGHT = 360;

OpenCV opencv;
// int cannyLowThreshold = 211;
int cannyLowThreshold = 1;
int cannyHighThreshold = 300;

boolean needFrame = true;

WavesSearch wavesSearch;
WavesDrawer wavesDrawer;
ArrayList<ArrayList<PVector>> horizontalWaves;
final int WAVES_QTY = 3;

void setup() {
  size(950, 950);

  agua = new Movie(this, "ocean.mp4");
  agua.loop();

  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);

  wavesSearch = new WavesSearch();
  wavesDrawer = new WavesDrawer();
  horizontalWaves = new ArrayList<ArrayList<PVector>>();

  for ( int i = 0 ; i < WAVES_QTY ; i++ ) {
    horizontalWaves.add( new ArrayList<PVector>() );
  }


  // frameRate(1);
}

void draw() {
    background(25);

  if ( needFrame && agua.available() ) {
    agua.read();
    // needFrame = false;
    // agua.pause();

    updateEdges();

    wavesSearch.searchWaves(aguaEdges);
    ArrayList<ArrayList<PVector>> newHorizontalWaves = wavesSearch.getHorizontalWaves(WAVES_QTY);

    //agrego los nuevos waves del nuevo frame a los que ya tenía antes y los voy acumulando
    for ( int i = 0 ; i < WAVES_QTY ; i++ ) {
        // horizontalWaves.get(i).addAll( 0, currentHorizontalWaves.get(i) );
        ArrayList<PVector> oldHorizontalWave = horizontalWaves.get(i);
        ArrayList<PVector> newHorizontalWave = newHorizontalWaves.get(i);

        PVector lastOldHorizontalWave = null;

        if ( oldHorizontalWave.size() > 0 ) {
            lastOldHorizontalWave = oldHorizontalWave.get( oldHorizontalWave.size() - 1 );
        }

        for ( PVector point : newHorizontalWave ) {
            if ( lastOldHorizontalWave != null ) {
                point.x += lastOldHorizontalWave.x + 1;
            }

            oldHorizontalWave.add(point);
        }
    }
  }

  // image(aguaEdges, 0, 0);

  // wavesSearch.drawCurrentWave();
  image(aguaSobel,0,0);
  wavesSearch.draw();
  // wavesSearch.drawHorizontally();
  // wavesSearch.drawHorizontallyThree( horizontalWaves );
  // wavesSearch.drawCurrentWaveHorizontally();

  if ( horizontalWaves != null ) {
      wavesDrawer.draw(horizontalWaves);
      wavesDrawer.update(horizontalWaves);
  }
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

  opencv.loadImage(agua);
  opencv.findSobelEdges(0,1);
  aguaSobel = opencv.getSnapshot();

}

void printColor(color a) {
   println( "(" + red(a) + "," + green(a) + "," + blue(a) + ")" );
}

// Called every time a new frame is available to read
//void movieEvent(Movie m) {
//  m.read();
//}
