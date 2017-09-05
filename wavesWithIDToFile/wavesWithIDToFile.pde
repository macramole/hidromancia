import processing.video.*;
import gab.opencv.*;

Movie agua;
PImage aguaEdges;
PImage aguaSobel;

final int VIDEO_WIDTH = 640;
final int VIDEO_HEIGHT = 360;

OpenCV opencv;
// int cannyLowThreshold = 211;
// int cannyLowThreshold = 1;
// int cannyHighThreshold = 300;
// int cannyLowThreshold = 170;
// int cannyHighThreshold = 380;
int cannyLowThreshold = 30;
int cannyHighThreshold = 250;

boolean needFrame = true;

WavesSearch wavesSearch;

PrintWriter file;

int lastID = -1;

//true es cada id es por frame
//false es wave por wave con diferentes id.
final boolean WAVES_PER_FRAME = true;

void setup() {
  size(950, 950);

  agua = new Movie(this, "ocean.mp4");
  agua.play();

  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);

  wavesSearch = new WavesSearch();

  String path = "/home/macramole/Code/sketchbook/hidromancia/data/";
  // String path = "/home/macramole/Code/ide-projects/processing3/hidromancia/data/";

  try {
      if ( WAVES_PER_FRAME ) {
          file = new PrintWriter(path + "wavesPerFrame.tsv", "UTF-8");
      } else {
          file = new PrintWriter(path + "wavesWithID.tsv", "UTF-8");
      }
      file.println("y\tid");
  } catch (IOException e) {
      e.printStackTrace();
  }

  // smooth(10);
  // frameRate(1);
  background(25);
}

void draw() {
    background(25);

  if ( needFrame && agua.available() ) {
    agua.read();
    agua.pause();

    /** Comentar esto para pasar de cuadro por cuadro a play */
    // needFrame = false;
    // agua.pause();
    /***/

    updateEdges();

    wavesSearch.searchWaves(aguaEdges);

    if ( WAVES_PER_FRAME ) {
        saveWavesPerFrame();
    } else {
        saveWavesWithID();
    }
    agua.play();
  }

  image(agua,0,0);
  wavesSearch.draw();
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


  if ( agua.duration() - agua.time() <= 0 ) {
      file.close();
      exit();
  }

  surface.setTitle(str(frameRate));
}
void saveWavesWithID() {
    for ( ArrayList<PVector> wave : wavesSearch.wavesArray )  {
        lastID++;
        PVector first = wave.get(0);

        for ( PVector point : wave ) {
            float y = point.y - first.y;

            String row = y + "\t" + lastID;
            file.println(row);
        }
    }
}
void saveWavesPerFrame() {
    lastID++;
    for ( PVector point : wavesSearch.getHorizontalWave() )  {
        String row = point.y + "\t" + lastID;
        file.println(row);
    }
}

void keyTyped() {
  if ( key == ' ' ) {
    agua.play();
    needFrame = true;
  }
  if ( key == 't' ) {
    println(agua.duration() - agua.time());
  }

  if ( key == 'x' )  {
      file.close();
      exit();
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
