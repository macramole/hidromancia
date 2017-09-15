import processing.video.*;

Movie agua;
PImage aguaFrameCurrent;
PImage aguaFramePrevious;
final int AGUA_INBETWEEN_FRAMES = 10;

ArrayList<ArrayList<PVector>> waves;
// ArrayList<SentimentsCorrelation> correlations;
float[][] correlations;

int currentFrame = -1;
int currentFrameNeeded = 0;
int qtyFrames = 0;

final int QTY_SENTIMENTS = 5;
final int FIELD_ANGER = 0;
final int FIELD_FEAR = 1;
final int FIELD_JOY = 2;
final int FIELD_LOVE = 3;
final int FIELD_SADNESS = 4;
final String[] STR_SENTIMENTS = { "Enojo", "Miedo", "Goce", "Amor", "Tristeza" };
int[] sentimentsScore;
float[] sentimentsScoreProportion;
float[] sentimentsScoreProportionPrevious;
int indexLastSentimentScored;

final int BAR_WIDTH = 80;
final int BAR_HEIGHT = 400;
final int BAR_GAP = 10;
final int GRAPH_WIDTH = QTY_SENTIMENTS * BAR_WIDTH + (QTY_SENTIMENTS - 1) * BAR_GAP;
// final color[] BAR_COLORS = { color(255,0,0),color(255,0,0),color(255,0,0),color(255,0,0),color(255,0,0) };

final color[] BAR_COLORS = { color(87,184,148),color(249,120,80),color(123,141,191),color(223,114,182),color(151,211,67) };

void setup() {
    // size(1280, 720);
    size(1920, 1080);
    // size(720, 1280);

    // agua = new Movie(this, "ocean.hd.mp4");
    agua = new Movie(this, "ocean.processed.mp4");
    // agua = new Movie(this, "ocean.fullhd.mp4");
    agua.play();

    initSentimentsScore();

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

void initSentimentsScore() {
    sentimentsScore = new int[QTY_SENTIMENTS];
    sentimentsScoreProportion = new float[QTY_SENTIMENTS];
    sentimentsScoreProportionPrevious = new float[QTY_SENTIMENTS];

    for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
        sentimentsScoreProportion[i] = sentimentsScoreProportionPrevious[i] = (float)1/QTY_SENTIMENTS;
        sentimentsScore[i] = 1;
    }
}
void updateSentimentsScore() {
    if ( currentFrame >= qtyFrames || currentFrame < 0 ) {
        return;
    }

    float[] correlation = correlations[currentFrame];

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
    indexLastSentimentScored = maxSentimentCorrelationIndex;

    //sentimentsScoreProportion
    int sumScores = 0;
    for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
        sumScores += sentimentsScore[i];
        sentimentsScoreProportionPrevious[i] = sentimentsScoreProportion[i];
    }
    for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
        sentimentsScoreProportion[i] = (float)sentimentsScore[i] / sumScores;
    }
}

void draw() {
    background(0); //<>//

    if ( frameCount % AGUA_INBETWEEN_FRAMES == 0 ) {
        currentFrameNeeded++;
        agua.play();
        aguaFramePrevious = aguaFrameCurrent.copy();
    }

    if ( currentFrame < currentFrameNeeded && agua.available() ) {
        agua.read();
        agua.pause();
        currentFrame++;

        aguaFrameCurrent = (PImage)agua;
        updateSentimentsScore();
    }
    //
    // pushMatrix();
    //     translate(width/2,height/2);
    //     rotate(PI/2);
    //     translate(-agua.width/2,-agua.height/2);
        // image(agua, 0, 0);
    // popMatrix();

    drawAgua();
    drawWaves();
    drawSentiments();

    surface.setTitle(str(frameRate));
    if ( agua.duration() - agua.time() <= 0 ) {
        exit();
    }
}

void drawAgua() {
    if ( aguaFramePrevious != null ) {
        image(aguaFramePrevious, 0, 0);
    }
    if ( aguaFrameCurrent != null ) {
        // int opacity = round ( map(frameCount % AGUA_INBETWEEN_FRAMES, 0, AGUA_INBETWEEN_FRAMES-1, 0, 255) );
        int opacity = round ( getLerpAmount() * 255 );
        tint(255, opacity);
        image(aguaFrameCurrent, 0, 0);
        noTint();
    }

    //para que no sea tan brilloso
    stroke(0,40);
    strokeWeight(1);
    noFill();
    for ( int x = 0 ; x < width ; x+=2 ) {
        beginShape();
            vertex(x,0);
            vertex(x,height);
        endShape();
    }
}

void drawSentimentsOld() {
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

void drawSentiments() {
    if ( currentFrame >= qtyFrames || currentFrame < 0 ) {
        return;
    }

    float[] correlation = correlations[currentFrame];
    float[] correlationNext = correlations[currentFrame+1];

    float lerpAmount = getLerpAmount();

    int radius = 200;
    // ArrayList<PVector> v = new ArrayList<PVector>();

    pushMatrix();
        translate(width/2,height/2);

        textAlign(CENTER);
        ellipseMode(CENTER);




        //background Pentagons
        pushMatrix();
            rotate(PI);
            // fill(0,40);
            noFill();
            strokeWeight(50);
            // stroke(255,0,0);
            stroke(0,60);
            polygon(0,0, 340, 5);
            stroke(0,45);
            // stroke(0,255,0);
            polygon(0,0, 280, 5);
            stroke(0,30);
            // stroke(0,0,255);
            polygon(0,0, 220, 5);
            stroke(0,15);
            // stroke(0,255,255);
            polygon(0,0, 160, 5);
        popMatrix();


        fill(0,60);
        noStroke();
        pushMatrix();
            rotate(PI / 2);
            for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
                rotate(1.25664); //72 deg (https://en.wikipedia.org/wiki/Pentagon#Regular_pentagons)
                pushMatrix();
                    translate(0,-radius*0.5);
                    rect( ( -radius/2 ) *0.73 ,0,radius *0.73, 150);
                popMatrix();
            }
        popMatrix();

        rotate(PI / 2);
        for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
            rotate(1.25664); //72 deg (https://en.wikipedia.org/wiki/Pentagon#Regular_pentagons)
            pushMatrix();
                translate(0,-radius*0.5);

                //Barras de sentimientos acumulados
                color c = color(
                    red(BAR_COLORS[i]),
                    green(BAR_COLORS[i]),
                    blue(BAR_COLORS[i]),
                    160
                );

                if ( i == indexLastSentimentScored ) {
                    // float lerpValueColor = lerp(160,255, lerpAmount);
                    // c = color(
                    //     red(BAR_COLORS[i]),
                    //     green(BAR_COLORS[i]),
                    //     blue(BAR_COLORS[i]),
                    //     lerpValueColor
                    // );
                    c = BAR_COLORS[i];
                }

                // fill(BAR_COLORS[i]);
                float lerpValue = lerp(abs(sentimentsScoreProportionPrevious[i]),abs(sentimentsScoreProportion[i]), lerpAmount);
                noStroke();

                //barra
                fill(c);
                rect( ( -radius/2 ) *0.73 ,0,radius *0.73,-lerpValue*500);
                fill(255);
                //main Pentagon
                int pentagonWidth = 6;
                rect( ( -radius/2 ) *0.73 ,0,radius *0.73, pentagonWidth);

                stroke(255);
                strokeWeight(1);
                patternLine( ( -radius/1.3 ) *0.73 ,-55, (radius/1.4) *0.73, -55,  0x5555, 5);
                patternLine( ( -radius ) *0.73 ,-100, (radius) *0.73, -100,  0x5555, 5);
                patternLine( ( -radius ) *0.9 ,-150, (radius) *0.9, -150,  0x5555, 5);
                patternLine( ( -radius ) *1.1 ,-200, (radius) *1.1, -200,  0x5555, 5);

                //Barras de sentimientos instantaneos
                lerpValue = lerp(abs(correlation[i]),abs(correlationNext[i]), lerpAmount);

                // stroke(BAR_COLORS[i]);
                noFill();
                stroke(c);
                strokeWeight(2);
                beginShape();
                    vertex(0, pentagonWidth + 1);
                    vertex(0, radius/2 + lerpValue * radius );
                endShape();

                // v.add( new PVector(
                //     modelX(0, abs(correlation[i]) * radius, 0 ),
                //     modelY(0, abs(correlation[i]) * radius, 0 )
                // ) );
                // fill(BAR_COLORS[i]);
                fill(c);
                ellipse(0, radius/2 + lerpValue * radius + 5, 5, 5);

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
    ArrayList<PVector> waveNext = waves.get(currentFrame + 1);
    // int padNeeded = width - wave.size();
    // if ( padNeeded < 0 ) {
    //     padNeeded = 0;
    // }
    float lerpAmount = getLerpAmount();

    stroke(255);
    strokeWeight(1);
    noFill();

    float lastPoint = 0;
    int cantCols = 1;
    final int MAX_COLS = 7;

    pushMatrix();
        translate(width - width/5,0);
        fill(255,80);
        
        pushMatrix();
            translate(-50,0);
            // fill(255);
            text("Olas encontradas:",0,0);
        popMatrix();

        // for ( int i = 0 ; i < padNeeded/2 ; i++ ) {
        //     point( i, 0 );
        // }
        beginShape();
        float lerpValue;
        // for ( PVector point : wave ) {
        for ( int i = 0 ; i < wave.size() ; i++ ) {
            PVector point = wave.get(i);
            PVector pointNext;

            if ( i < waveNext.size() ) {
                pointNext = waveNext.get(i);
            } else {
                pointNext = point;
            }

            // point( point.x + padNeeded/2, point.y );
            // point( point.y, point.x - lastPoint );
            lerpValue = lerp(point.y, pointNext.y, lerpAmount);
            vertex( lerpValue + cantCols * 25, point.x - lastPoint );

            if ( point.x - lastPoint > height ) {
                // break;
                endShape();
                cantCols++;
                lastPoint = point.x;
                if ( cantCols == MAX_COLS ) {
                    break;
                }
                beginShape();
            }
        }
        endShape();
        // for ( int i = wave.size() + padNeeded/2 ; i < height ; i++ ) {
        //     point( i, 0 );
        // }
    popMatrix();
}

float getLerpAmount() {
    float lerpAmount = map(frameCount % AGUA_INBETWEEN_FRAMES, 0, AGUA_INBETWEEN_FRAMES-1, 0, 0.96);
    //si esta desincronizado bancala en 1 hasta que se sincronice
    if (currentFrameNeeded > currentFrame) {
        lerpAmount = 1.0;
    }
    return lerpAmount;
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

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
