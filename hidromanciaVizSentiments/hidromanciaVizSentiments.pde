import processing.video.*;

Movie agua;
ArrayList<ArrayList<PVector>> waves;
// ArrayList<SentimentsCorrelation> correlations;
float[][] correlations;

int currentFrame = -1;
int qtyFrames = 0;

final int QTY_SENTIMENTS = 5;
final int FIELD_ANGER = 0;
final int FIELD_FEAR = 1;
final int FIELD_JOY = 2;
final int FIELD_LOVE = 3;
final int FIELD_SADNESS = 4;
final String[] STR_SENTIMENTS = { "Enojo", "Miedo", "Goce", "Amor", "Tristeza" };
int[] sentimentsScore;

final int BAR_WIDTH = 80;
final int BAR_HEIGHT = 400;
final int BAR_GAP = 10;
final int GRAPH_WIDTH = QTY_SENTIMENTS * BAR_WIDTH + (QTY_SENTIMENTS - 1) * BAR_GAP;
// final color[] BAR_COLORS = { color(255,0,0),color(255,0,0),color(255,0,0),color(255,0,0),color(255,0,0) };

final color[] BAR_COLORS = { color(87,184,148),color(249,120,80),color(123,141,191),color(223,114,182),color(151,211,67) };

void setup() {
    size(1280, 720);
    // size(720, 1280);

    // agua = new Movie(this, "ocean.hd.mp4");
    agua = new Movie(this, "ocean.hd.mp4");
    agua.play();

    sentimentsScore = new int[QTY_SENTIMENTS];

    loadWaves();
    loadSentimentsCorrelation();

    frameRate(24);
    smooth();
}

void loadWaves() {
    BufferedReader reader;
    reader = createReader( "wavesPerFrame.tsv" );

    waves = new ArrayList<ArrayList<PVector>>();

    try {
        reader.readLine(); //es el header

        final int FIELD_Y = 0;
        final int FIELD_ID = 1;

        int currentId = 0;
        int currentX = 0;

        String line = reader.readLine();
        String[] arrLine = line.split("\t");

        while ( line != null ) {
            ArrayList<PVector> wave = new ArrayList<PVector>();
            currentId = int(arrLine[FIELD_ID]);
            currentX = 0;

            while ( line != null && currentId == int(arrLine[FIELD_ID]) ) {
                PVector point = new PVector( currentX, float(arrLine[FIELD_Y]) );
                wave.add(point);

                currentX++;
                line = reader.readLine();
                if ( line != null ) {
                    arrLine = line.split("\t");
                }
            }
            qtyFrames++;
            waves.add(wave);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    // qtyFrames--;
    println( "size of waves : " + waves.size() );
    println( "size of qtyFrames : " + qtyFrames );
}
void loadSentimentsCorrelation() {
    BufferedReader reader;
    reader = createReader( "maxCrossCorrelationsPerFrame.tsv" );

    correlations = new float[qtyFrames][QTY_SENTIMENTS];

    try {
        reader.readLine(); //es el header

        String line = reader.readLine();
        String[] arrLine;

        // while ( line != null ) {
        for ( int i = 0 ; i < qtyFrames ; i++ ) {
            // SentimentsCorrelation s = new SentimentsCorrelation();

            arrLine = line.split("\t");
            for ( int j = 0 ; j < QTY_SENTIMENTS ; j++ ) {
                correlations[i][j] = float(arrLine[j]);
            }

            line = reader.readLine();
            if ( line == null ) {
                break;
            }
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}

void draw() {
    background(0);

    if ( agua.available() ) {
        agua.read();
        currentFrame++;
    }
    //
    // pushMatrix();
    //     translate(width/2,height/2);
    //     rotate(PI/2);
    //     translate(-agua.width/2,-agua.height/2);
        image(agua, 0, 0);
    // popMatrix();

    // drawWaves();
    // drawSentiments();
    drawSentiments2();

    frame.setTitle(str(frameRate));
    if ( agua.duration() - agua.time() <= 0 ) {
        exit();
    }
}

void drawSentiments() {
    if ( currentFrame >= qtyFrames || currentFrame < 0 ) {
        return;
    }

    float[] correlation = correlations[currentFrame];

    textAlign(CENTER);

    pushMatrix();
        translate(width / 2 - GRAPH_WIDTH / 2 , height/2 + BAR_HEIGHT / 2 );

        noFill();
        stroke(255);
        strokeWeight(1);
        rect(-BAR_GAP,0,GRAPH_WIDTH+BAR_GAP*2, -BAR_HEIGHT);
        fill(255);
        pushMatrix();
            for ( int i = 20 ; i < 100 ; i+= 20 ) {
                translate(0, -BAR_HEIGHT * (20/100.0) );
                text(str(i) + "% -", -BAR_GAP*3, 4);
                noStroke();
                rect(-BAR_GAP,0,GRAPH_WIDTH+BAR_GAP*2,1);
            }
        popMatrix();


        noStroke();
        float maxSentimentCorrelation = -1;
        int maxSentimentCorrelationIndex = -1;

        for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
            float corr = correlation[i];
            if ( corr > maxSentimentCorrelation ) {
                maxSentimentCorrelation = corr;
                maxSentimentCorrelationIndex = i;
            }
        }

        sentimentsScore[maxSentimentCorrelationIndex]++;

        for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
            color c = color( red(BAR_COLORS[i]), green(BAR_COLORS[i]), blue(BAR_COLORS[i]), 100 );
            fill(c);
            rect(0, 0, BAR_WIDTH, -BAR_HEIGHT * -abs(correlation[i]) );
            fill( BAR_COLORS[i] );
            rect(0, 0, BAR_WIDTH, -BAR_HEIGHT * sentimentsScore[i] / (qtyFrames/2));

            fill(255);
            text( STR_SENTIMENTS[i], BAR_WIDTH / 2, 15 );

            translate(BAR_WIDTH + BAR_GAP, 0);
        }
    popMatrix();
}

void drawSentiments2() {
    if ( currentFrame >= qtyFrames || currentFrame < 0 ) {
        return;
    }

    float[] correlation = correlations[currentFrame];
    int radius = 200;

    float maxSentimentCorrelation = -1;
    int maxSentimentCorrelationIndex = -1;

    for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
        float corr = correlation[i];
        if ( corr > maxSentimentCorrelation ) {
            maxSentimentCorrelation = corr;
            maxSentimentCorrelationIndex = i;
        }
    }

    sentimentsScore[maxSentimentCorrelationIndex]++;

    // ArrayList<PVector> v = new ArrayList<PVector>();

    pushMatrix();
        translate(width/2,height/2);

        textAlign(CENTER);
        ellipseMode(CENTER);

        rotate(PI);
        for ( int i = 0 ; i < 5 ; i++ ) {
            rotate(1.25664); //72 deg (https://en.wikipedia.org/wiki/Pentagon#Regular_pentagons)
            pushMatrix();
                translate(0,-radius*0.5);

                //Barras de sentimientos acumulados
                color c = color(
                    red(BAR_COLORS[i]),
                    green(BAR_COLORS[i]),
                    blue(BAR_COLORS[i]),
                    180
                );
                // fill(BAR_COLORS[i]);
                fill(c);
                noStroke();
                rect( ( -radius/2 ) *0.73 ,0,radius *0.73,-sentimentsScore[i]);
                fill(255);
                int pentagonWidth = 6;
                rect( ( -radius/2 ) *0.73 ,0,radius *0.73, pentagonWidth);

                stroke(255);
                strokeWeight(1);
                patternLine( ( -radius/1.3 ) *0.73 ,-50, (radius/1.4) *0.73, -50,  0x5555, 5);
                patternLine( ( -radius ) *0.73 ,-100, (radius) *0.73, -100,  0x5555, 5);
                patternLine( ( -radius ) *0.9 ,-150, (radius) *0.9, -150,  0x5555, 5);

                //Barras de sentimientos instantaneos
                stroke(BAR_COLORS[i]);
                strokeWeight(2);
                beginShape();
                    vertex(0, pentagonWidth + 1);
                    vertex(0, abs(correlation[i]) * radius );
                endShape();

                // v.add( new PVector(
                //     modelX(0, abs(correlation[i]) * radius, 0 ),
                //     modelY(0, abs(correlation[i]) * radius, 0 )
                // ) );
                fill(BAR_COLORS[i]);
                ellipse(0, abs(correlation[i]) * radius + 5, 5, 5);

                //Texto de sentimiento
                fill(255);
                text(STR_SENTIMENTS[i],0,-5);
            popMatrix();
        }
        // translate(width/2,height/2);
        // for ( PVector p : v ) {
        //     ellipse(p.x,p.y, 5, 5);
        // }

    popMatrix();


}

void drawWaves() {
    if ( currentFrame >= waves.size() ) {
        return;
    }
    ArrayList<PVector> wave = waves.get(currentFrame);
    int padNeeded = width - wave.size();
    if ( padNeeded < 0 ) {
        padNeeded = 0;
    }

    stroke(255);
    strokeWeight(2);

    pushMatrix();
        translate(0,height/2 + GRAPH_WIDTH / 2 + 50);
        for ( int i = 0 ; i < padNeeded/2 ; i++ ) {
            point( i, 0 );
        }
        for ( PVector point : wave ) {
            point( point.x + padNeeded/2, point.y );

            if ( point.x > width ) {
                break;
            }
        }
        for ( int i = wave.size() + padNeeded/2 ; i < width ; i++ ) {
            point( i, 0 );
        }
    popMatrix();
}

//based on Bresenham's algorithm from wikipedia
//http://en.wikipedia.org/wiki/Bresenham's_line_algorithm

void patternLine(float xStart, float yStart, float xEnd, float yEnd, int linePattern, int lineScale) {
  float temp, yStep, x, y;
  int pattern = linePattern;
  int carry;
  int count = lineScale;

  boolean steep = (abs(yEnd - yStart) > abs(xEnd - xStart));
  if (steep == true) {
    temp = xStart;
    xStart = yStart;
    yStart = temp;
    temp = xEnd;
    xEnd = yEnd;
    yEnd = temp;
  }
  if (xStart > xEnd) {
    temp = xStart;
    xStart = xEnd;
    xEnd = temp;
    temp = yStart;
    yStart = yEnd;
    yEnd = temp;
  }
  float deltaX = xEnd - xStart;
  float deltaY = abs(yEnd - yStart);
  float error = - (deltaX + 1) / 2;

  y = yStart;
  if (yStart < yEnd) {
    yStep = 1;
  } else {
    yStep = -1;
  }
  for (x = xStart; x <= xEnd; x++) {
    if ((pattern & 1) == 1) {
	if (steep == true) {
	  point(y, x);
	} else {
	  point(x, y);
	}
	carry = 0x8000;
    } else {
	carry = 0;
    }
    count--;
    if (count <= 0) {
	pattern = (pattern >> 1) + carry;
	count = lineScale;
    }

    error += deltaY;
    if (error >= 0) {
	y += yStep;
	error -= deltaX;
    }
  }
}
