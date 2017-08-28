class WavesSearch {
    ArrayList < ArrayList<PVector> > wavesArray;
    ArrayList < ArrayList<PVector> > wavesRejectedArray;
    int currentWaveIndex = -1;
    color[] colors = { color(85, 173, 71), color(50, 129, 186), color(255) };

    PVector[][][] kernelNeighbors = {
        { { new PVector(1,0), new PVector(0,1) }, { new PVector(-1,0), new PVector(1,0) }, { new PVector(-1,0), new PVector(0,1) } },
        { { new PVector(0,1), new PVector(0,-1) }, {  }, { new PVector(0,-1), new PVector(0,1) } },
        { { new PVector(0,-1), new PVector(1,0) }, { new PVector(-1,0), new PVector(1,0) }, { new PVector(-1,0), new PVector(0,-1) } }
    };
    final float KERNEL_WEIGHT_SPOT = 1;
    final float KERNEL_WEIGHT_NEIGHBORS = 0.2;

    int WAVES_MIN_THRESHOLD = 10;

    WavesSearch() {
        wavesArray = new ArrayList < ArrayList<PVector> >();
        wavesRejectedArray = new ArrayList < ArrayList<PVector> >();
    }

    public void searchWaves(PImage tex) {
        // final int cantWaves = 10;
        // int currentCantWaves = 0;

        wavesArray.clear();
        wavesRejectedArray.clear();

        color currentPixel;
        tex.loadPixels();
        for ( int y = 0 ; y < tex.height ; y++ ) {
            for ( int x = 0 ; x < tex.width ; x++ ) {
                currentPixel = tex.get(x,y);
                //printColor(currentPixel);
                if ( currentPixel != color(0) ) {
                    initSearchWave(new PVector(x,y),tex);

                    // if ( currentCantWaves >= cantWaves ) {
                    //     return;
                    // }
                    // currentCantWaves++;
                }
            }
        }

        // println( wavesArray.size() + " waves found" );
    }
    private void initSearchWave(PVector point, PImage tex) {
        float[][] kernel = { //<>//
            { 1, 1, 1 },
            { 1, 1, 1 },
            { 1, 1, 1 }
        };

        ArrayList<PVector> waveArray = new ArrayList<PVector>();
        waveArray.add( point );
        tex.set( int(point.x), int(point.y), color(0) );

        ArrayList<PVector> foundWave = searchWave( point, kernel, tex, waveArray );

        if ( foundWave != null && foundWave.size() > WAVES_MIN_THRESHOLD ) {
            if ( isWaveAFunction(foundWave) ) {
                wavesArray.add( fixWave(foundWave) );
            } else {

                //me fijo si una sub wave mas chica sí es función
                for ( int length = foundWave.size() - 1 ; length > WAVES_MIN_THRESHOLD ; length-- ) {
                    int start = 0;
                    int end = start + length;
                    while( end < foundWave.size() ) {
                        ArrayList<PVector> subFoundWave = new ArrayList<PVector>( foundWave.subList(start,end) );
                        if ( isWaveAFunction( subFoundWave ) ) {
                            wavesArray.add( fixWave(subFoundWave) );
                            return;
                        }
                        start++;
                        end++;
                    }
                }
                
                wavesRejectedArray.add( fixWave(foundWave) ); //esto lo estoy usando en el draw nada mas
            }
        }
    }
    private ArrayList<PVector> searchWave(PVector point, float[][] kernel, PImage tex, ArrayList<PVector> waveArray) {
        float[][] votes = {
            { 0, 0, 0 },
            { 0, 0, 0 },
            { 0, 0, 0 }
        };

        int kernelX, kernelY;

        // println("Point: " + point.x + "," + point.y);

        for ( int y = int(point.y) - 1 ; y <= int(point.y) + 1 ; y++ ) {
            for ( int x = int(point.x) - 1 ; x <= int(point.x) + 1 ; x++ ) {
                if ( x < 0 || y < 0 || x >= tex.width || y >= tex.height ) {
                    continue;
                }
                if ( tex.get(x,y) != color(0) ) {
                    kernelX = x - int(point.x) + 1;
                    kernelY = y - int(point.y) + 1;

                    // println("Spotted: " + x + "," + y);
                    // println(kernelX + "," + kernelY);

                    votes[kernelY][kernelX] += kernel[kernelY][kernelX];
                }
            }
        }

        PVector nextPoint = getMostVoted(votes, point, kernel);

        if ( nextPoint != null ) {
            // println("Next point is: " + nextPoint.x + "," + nextPoint.y);
            // println("Kernel is: ");
            // printKernel(kernel);
            // println("");

            waveArray.add( nextPoint );
            tex.set( int(nextPoint.x), int(nextPoint.y), color(0) );

            return searchWave( nextPoint, kernel, tex, waveArray );
        } else {
            return waveArray;
        }
    }
    private PVector getMostVoted( float[][] votes, PVector lastPoint, float[][] kernel ) {
        PVector maxPoint = null;
        float maxValue = 0;

        for ( int y = 0 ; y <= 2 ; y++ ) {
            for ( int x = 0 ; x <= 2 ; x++ ) {
                if ( votes[y][x] > maxValue ) {
                    maxValue = votes[y][x];
                    maxPoint = new PVector(x,y);
                }
            }
        }

        if ( maxPoint != null ) {
            updateKernel(kernel, maxPoint);

            maxPoint.x += lastPoint.x - 1;
            maxPoint.y += lastPoint.y - 1;
        }

        return maxPoint;
    }
    private void updateKernel(float[][] kernel, PVector point) {
        kernel[int(point.y)][int(point.x)] += KERNEL_WEIGHT_SPOT;
        PVector[] neighbors = kernelNeighbors[int(point.y)][int(point.x)];

        for ( PVector neighbor : neighbors ) {
            kernel[int(point.y + neighbor.y)][int(point.x + neighbor.x)] += KERNEL_WEIGHT_NEIGHBORS;
        }
    }
    private void printKernel(float[][] kernel) {
        String strKernel = "";
        for ( int y = 0 ; y <= 2 ; y++ ) {
            for ( int x = 0 ; x <= 2 ; x++ ) {
                strKernel += str(kernel[y][x]) + " ";
            }
            strKernel += "\n";
        }
        println(strKernel);
    }

    public ArrayList<PVector> fixWave(ArrayList<PVector> wave) {
        ArrayList<PVector> retArray = wave;

        // si esta descendente darlo vuelta
        if ( wave.get(0).x > wave.get(1).x ) {
            retArray = new ArrayList<PVector>();

            for ( int i = wave.size() - 1 ; i >= 0 ; i-- ) {
                retArray.add( wave.get(i) );
            }
        }

        return retArray;
    }

    public ArrayList<PVector> getHorizontalWave() {
        ArrayList<PVector> horizontalWave = new ArrayList<PVector>();

        float lastX = 0;

        for ( int i = 0 ; i < wavesArray.size() ; i++ ) {
            ArrayList<PVector> wave = wavesArray.get(i);

            PVector first = wave.get(0);
            PVector horizontalWavePoint;

            int interpolationGap = 0;

            for ( int j = 0 ; j < wave.size() ; j++ ) {
                PVector point = wave.get(j);

                float x = point.x - first.x + lastX + interpolationGap;
                float y = point.y - first.y;

                horizontalWavePoint = new PVector(x,y);

                // interpolación entre wave y wave
                if ( j == 0 && i > 0 ) {
                    PVector lastHorizontalWavePoint = horizontalWave.get( horizontalWave.size() - 1 );

                    int interpolationLength = int(horizontalWavePoint.y - lastHorizontalWavePoint.y);
                    int interpolationDirection = interpolationLength > 0 ? 1 : -1;
                    interpolationLength = abs(interpolationLength);

                    for ( int k = 1 ; k <= interpolationLength ; k++ ) {
                        PVector interpolationWavePoint = new PVector( lastHorizontalWavePoint.x + k, lastHorizontalWavePoint.y + (k * interpolationDirection) );

                        // interpolationWavePoint.lerp( horizontalWavePoint, 1/k );
                        horizontalWave.add(interpolationWavePoint);
                    }
                    horizontalWavePoint.x += interpolationLength;
                    interpolationGap += interpolationLength;
                }

                horizontalWave.add(horizontalWavePoint);
            }

            lastX = wave.get( wave.size() - 1 ).x - first.x + lastX + interpolationGap;
        }

        return horizontalWave;
    }


    // divide la principal en qty partes iguales
    public ArrayList<ArrayList<PVector>> getHorizontalWaves( int qty ) {
        ArrayList<ArrayList<PVector>> horizontalWaves = new ArrayList<ArrayList<PVector>>(); //<>//
        ArrayList<PVector> horizontalWave = getHorizontalWave();

        int division = floor( horizontalWave.size() / qty );

        for ( int i = 1 ; i <= qty ; i++ ) {
            ArrayList<PVector> horizontalWaveSmall = new ArrayList<PVector>();

            int firstIndex = division * (i-1);
            int maxIndex = division * i;

            if ( i == qty ) {
                maxIndex = horizontalWave.size();
            }

            if ( horizontalWave.size() > 0 ) {
                float firstX = horizontalWave.get(firstIndex).x;

                for ( int j = firstIndex ; j < maxIndex ; j++ ) {
                    PVector point = horizontalWave.get(j);
                    point.x -= firstX;

                    horizontalWaveSmall.add( point );
                }
            }

            horizontalWaves.add( horizontalWaveSmall );
        }

        return horizontalWaves;
    }

    public boolean isWaveAFunction(ArrayList<PVector> wave) {
        ArrayList<Float> xValues = new ArrayList<Float>();

        for ( PVector point : wave ) {
            if ( xValues.contains( point.x ) ) {
                return false;
            }
            xValues.add( point.x );
        }

        return true;
    }

    public void nextWave() {
        currentWaveIndex++;

        if ( currentWaveIndex >= wavesArray.size() ) {
            println("currentWaveIndex to 0");
            currentWaveIndex = 0;
        }

        println(currentWaveIndex);
    }
    public void drawCurrentWave() {
        if ( currentWaveIndex < 0 || currentWaveIndex >= wavesArray.size() ) {
            return;
        }

        ArrayList<PVector> currentWave = wavesArray.get(currentWaveIndex);

        stroke(255,0,0);
        for ( PVector point : currentWave ) {
            point( point.x, point.y );
        }
    }
    public void draw() {
        strokeWeight(2);

        stroke(255,0,0);
        for ( ArrayList<PVector> wave : wavesArray ) {
            // stroke( colors[ round(random(0,2)) ] );
            for ( PVector point : wave ) {
                point( point.x, point.y );
            }
        }


        stroke(0,255,0);
        fill(0,255,0);
        for ( ArrayList<PVector> wave : wavesRejectedArray ) {
            // stroke( colors[ round(random(0,2)) ] );
            for ( PVector point : wave ) {
                point( point.x, point.y );
            }
        }

        fill(255,0,0);
        text("Waves saved: " + str(wavesArray.size()), 10, height - 40);
        text("Waves rejected: " + str(wavesRejectedArray.size()) + " (" +
            ((float)wavesRejectedArray.size()/(wavesRejectedArray.size()+wavesArray.size())) * 100 + "%)",
            10,
            height - 20);
    }
    public void drawCircles() {
        strokeWeight(1);
        noStroke();

        for ( ArrayList<PVector> wave : wavesArray ) {
            PVector point = wave.get(0);


            fill(colors[ round( map(point.y, 0, VIDEO_HEIGHT,0,2 ) ) ], 100);
            // stroke( colors[ round( map(point.y, 0, VIDEO_HEIGHT,0,2 ) ) ] );

            ellipse( point.x, point.y, wave.size(), wave.size() );
            // for ( PVector point : wave ) {
            //     point( point.x, point.y );
            // }
        }
    }
    public void drawHorizontally() {
        stroke(0,0,255);
        strokeWeight(1);

        pushMatrix();
        translate(0,height/2);

        for ( PVector point : getHorizontalWave() ) {
            point( point.x, point.y );
        }

        popMatrix();
    }
    public void drawHorizontallyThree() {
        drawHorizontallyThree( getHorizontalWaves(3) );
    }
    public void drawHorizontallyThree(ArrayList<ArrayList<PVector>> threeHorizonalWaves) {
        stroke(0,0,255);
        // println(threeHorizonalWaves.size());
        // println(threeHorizonalWaves.get(0).size());
        // println(threeHorizonalWaves.get(1).size());
        // println(threeHorizonalWaves.get(2).size());

        for ( int i = 0 ; i < threeHorizonalWaves.size() ; i++ ) {
            ArrayList<PVector> horizontalWave = threeHorizonalWaves.get(i);

            pushMatrix();
            translate(0, (height/7) * (1+2*i) );

            for ( PVector point : horizontalWave ) {
                point( point.x, point.y );
            }

            popMatrix();
        }
    }

    public void printPVectorArray( ArrayList<PVector> wave ) {
        String strPrint = "[ ";
        for ( PVector point : wave ) {
            strPrint += "(" + point.x + "," + point.y + ") , ";
        }
        strPrint += " ]";
        println(strPrint);
    }

    public void drawCurrentWaveHorizontally() {
        if ( currentWaveIndex < 0 || currentWaveIndex >= wavesArray.size() ) {
            return;
        }

        stroke(0,0,255);

        pushMatrix();
        translate(0,height/2);
        float lastX = 0;

        for ( int i = 0 ; i <= currentWaveIndex ; i++ ) {
            ArrayList<PVector> wave = wavesArray.get(i);

            printPVectorArray(wave);
            println("Last X: " + lastX);

            PVector first = wave.get(0);

            for ( PVector point : wave ) {
                float x = point.x - first.x + lastX;
                float y = point.y - first.y;

                point( x, y );

                println(x + "," + y);
            }
            println("-");

            lastX = wave.get( wave.size() - 1 ).x - first.x + lastX;
        }
        println("");

        popMatrix();
    }
}
