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

    loadWaves();
    loadSentimentsCorrelation();

    frameRate(24);
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

    drawWaves();
    drawSentiments();

    frame.setTitle(str(frameRate));
}

void drawSentiments() {
    if ( currentFrame >= qtyFrames ) {
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
        for ( int i = 0 ; i < QTY_SENTIMENTS ; i++ ) {
            fill( BAR_COLORS[i] );
            rect(0, 0, BAR_WIDTH, -BAR_HEIGHT * correlation[i]);

            fill(255);
            text( STR_SENTIMENTS[i], BAR_WIDTH / 2, 15 );

            translate(BAR_WIDTH + BAR_GAP, 0);
        }
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
