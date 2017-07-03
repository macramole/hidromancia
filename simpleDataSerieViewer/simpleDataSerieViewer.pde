ArrayList<ArrayList<PVector>> waves;

final int WAVES_QTY = 3;

void setup() {

    size(800,500);

    waves = new ArrayList<ArrayList<PVector>>(WAVES_QTY);
    BufferedReader reader;

    for ( int i = 1 ; i <= WAVES_QTY ; i++ ) {
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
        } catch (IOException e) {
            e.printStackTrace();
        }

        waves.add( wave );
        println( "size of " + i + ": " + wave.size() );
    }
}
void draw() {
    background(25);
    drawHorizontallyThree();

    text(frameRate, 10, 20);
}
void drawHorizontallyThree() {
    stroke(0,0,255);
    // println(threeHorizonalWaves.size());
    // println(threeHorizonalWaves.get(0).size());
    // println(threeHorizonalWaves.get(1).size());
    // println(threeHorizonalWaves.get(2).size());

    for ( int i = 0 ; i < waves.size() ; i++ ) {
        ArrayList<PVector> horizontalWave = waves.get(i);

        pushMatrix();
        translate(0, (height/7) * (1+2*i) );

        for ( PVector point : horizontalWave ) {
            point( point.x, point.y );

            if ( point.x > width ) {
                break;
            }
        }

        popMatrix();
    }
}
