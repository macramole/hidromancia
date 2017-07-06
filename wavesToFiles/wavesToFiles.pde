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

ArrayList<ArrayList<PVector>> horizontalWaves;
final int WAVES_QTY = 3;

PrintWriter[] files;

void setup() {
  size(950, 950);

  agua = new Movie(this, "ocean.mp4");
  agua.play();

  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);

  wavesSearch = new WavesSearch();

  horizontalWaves = new ArrayList<ArrayList<PVector>>(3);

  //String path = "/home/macramole/Code/ide-projects/processing3/hidromancia/wavesToFiles/data/";
  String path = "/home/tomas/sketchbook/hidromancia/wavesToFiles/data/";
  files = new PrintWriter[3];

  for ( int i = 0 ; i < WAVES_QTY ; i++ ) {
    horizontalWaves.add( new ArrayList<PVector>() );

    try {
        // files[i] = new File(path + (i+1) + ".txt");
        files[i] = new PrintWriter(path + (i+1) + ".txt", "UTF-8");
    } catch (IOException e) {
		e.printStackTrace();
    }

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

    wavesSearch.searchWaves(aguaEdges);
    addNewHorizontalWaves();
  }

  image(agua,0,0);
  // image(aguaEdges, 0, 0);

  // wavesSearch.drawCurrentWave();
  // if ( aguaSobel != null ) {
  //     image(aguaSobel,0,0);
  // }
  // wavesSearch.draw();
  // wavesSearch.drawHorizontally();
  // wavesSearch.drawHorizontallyThree( horizontalWaves );
  // wavesSearch.drawCurrentWaveHorizontally();

  // if ( horizontalWaves != null ) {
  //     wavesDrawer.draw(horizontalWaves);
  //     wavesDrawer.update(horizontalWaves);
  // }
  //
  // text( str(frameRate), 10, 20); //con 14 frames me dropea a 30fps

  if ( agua.duration() - agua.time() <= 0 ) {
      for ( PrintWriter f : files ) {
          f.close();
          exit();
      }
  }
}

//con 8 frames doy la vuelta
void addNewHorizontalWaves() {
    ArrayList<ArrayList<PVector>> newHorizontalWaves = wavesSearch.getHorizontalWaves(WAVES_QTY);

    //agrego los nuevos waves del nuevo frame a los que ya tenía antes y los voy acumulando
    for ( int i = 0 ; i < WAVES_QTY ; i++ ) {
        ArrayList<PVector> newHorizontalWave = newHorizontalWaves.get(i);

        for ( PVector point : newHorizontalWave ) {
            files[i].println(point.y);
        }
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

  opencv.loadImage(agua);
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