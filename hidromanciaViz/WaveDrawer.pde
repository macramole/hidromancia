class WaveDrawer{

    ArrayList<PVector> wave;

    int size;//largo de la línea
    float radio; //radio del circulo(relación con la cantidad de puntos)
    int relation; //TENGO QUE VER COMO NO USAR ESTE NUM PARA QUE EL SIZE PUEDA VARIAR Y QUE NO ME JODA EL RADIO

    // float ratio; //distancia entre los puntos
    float speed; //distancia entre los puntos
    int nLinesTillFullCircle;//cuantas lineas hasta completar el círculo
    int from;

    int idx;//rasteo que seccion de la línea dibujé

    final float SCALE_Y = 5;
    final int MAX_POINTS_IN_CIRCLE = 1887; //esto lo saque mirando cuantos eran, capaz haya alguna cuenta

    int currentBatch = 0;
    int currentInterpolationFrame = 0;

    color lineColor;
    boolean doColor = false;

    WaveDrawer(ArrayList<PVector> wave, float _radio,float  _speed, color lineColor){
        this.wave = wave;
        this.lineColor = lineColor;
        size = width;//largo de la línea
        radio = _radio;

        speed = _speed;

        from = 0;
        idx = 0;

        stroke(255);
        update();
        // strokeWeight(3);
    }

    public void draw() {

        pushMatrix();
        translate(width/2,height/2);
        scale(radio);
        strokeWeight(20);

        if ( radio <= 0.1 ) {
            strokeWeight(40);
        }
        // stroke(255);
        stroke(lineColor);
        // fill(25);
        noFill();

        if ( doColor ) {
            fill( averageColor );
        }

        beginShape();
        for(int i = from; i<idx;i++){

            float x = ( cos(wave.get(i).x/speed) ) * (size + wave.get(i).y * SCALE_Y);
            float y = ( sin(wave.get(i).x/speed) ) * (size + wave.get(i).y * SCALE_Y);
            PVector point = new PVector(x,y);

            int nextPointIndex = getNextBatchIndex(i);
            float x2 = (cos(wave.get(nextPointIndex).x/speed)) * (size + wave.get(nextPointIndex).y * SCALE_Y);
            float y2 = (sin(wave.get(nextPointIndex).x/speed)) * (size + wave.get(nextPointIndex).y * SCALE_Y);
            PVector nextPoint = new PVector(x2,y2);

            point.lerp( nextPoint, (float)currentInterpolationFrame / (float)(WAVES_DRAWER_INTERPOLATION_FRAMECOUNT-1) );

            vertex(point.x,point.y);
        }
        endShape(CLOSE);

        popMatrix();

        currentInterpolationFrame++;
        if ( currentInterpolationFrame >= WAVES_DRAWER_INTERPOLATION_FRAMECOUNT ) {
            currentInterpolationFrame = 0;
        }
    }

    public PImage getMask() {
        canvas.beginDraw();
        canvas.background(0);

        canvas.pushMatrix();
        canvas.translate(VIDEO_WIDTH/2,VIDEO_HEIGHT/2);
        canvas.scale(radio);
        canvas.strokeWeight(5);
        canvas.stroke(255);

        canvas.beginShape();
        for(int i = from; i<idx;i++){
            float x = ( cos(wave.get(i).x/speed) ) * (size + wave.get(i).y * SCALE_Y);
            float y = ( sin(wave.get(i).x/speed) ) * (size + wave.get(i).y * SCALE_Y);
            PVector point = new PVector(x,y);

            int nextPointIndex = getNextBatchIndex(i);
            float x2 = (cos(wave.get(nextPointIndex).x/speed)) * (size + wave.get(nextPointIndex).y * SCALE_Y);
            float y2 = (sin(wave.get(nextPointIndex).x/speed)) * (size + wave.get(nextPointIndex).y * SCALE_Y);
            PVector nextPoint = new PVector(x2,y2);

            point.lerp( nextPoint, (float)currentInterpolationFrame / (float)(WAVES_DRAWER_INTERPOLATION_FRAMECOUNT-1) );

            canvas.vertex(point.x,point.y);
        }
        canvas.endShape(CLOSE);

        canvas.popMatrix();
        canvas.endDraw();
        return canvas;
    }

    public void update() {
        // idx ++;
        // if(idx >= wave.size() - 1){
        //     idx = 0;
        //     from = 0;
        // } else if(idx % MAX_POINTS_IN_CIRCLE == 0 ){
        //     //   from += MAX_POINTS_IN_CIRCLE * (MAX_POINTS_IN_CIRCLE / idx);
        //     from++;
        //
        //     println("From: " + from);
        //     println("To: " + idx);
        // }
        from = currentBatch * MAX_POINTS_IN_CIRCLE;
        idx = from + MAX_POINTS_IN_CIRCLE - 1;

        if ( idx < wave.size() ) {
            currentBatch++;
        } else {
            currentBatch = 0;
            update();
        }
    }
    private int getNextBatchIndex(int index) {
        int realIndex = idx + (index % MAX_POINTS_IN_CIRCLE) + 1;

        if ( realIndex >= wave.size() ) {
            realIndex = (index % MAX_POINTS_IN_CIRCLE) + 1;
        }

        return realIndex;
    }

  //Dibujá de a secciones
  // void drawCircledLineFromPoints(ArrayList<PVector> points,float radio, int idx){
  // float x = (cos(points.get(idx).x/ratio)) * (size + points.get(idx).y);
  // float y = (sin(points.get(idx).x/ratio)) * (size + points.get(idx).y);
  //
  // float x2 = (cos(points.get(idx + 1).x/ratio)) * (size + points.get(idx + 1).y);
  // float y2 = (sin(points.get(idx + 1).x/ratio)) * (size + points.get(idx + 1).y);
  //
  // pushMatrix();
  // translate(width/2,height/2);
  // scale(radio);
  // stroke(255);
  // line(x,y,x2,y2);
  // popMatrix();
  //
  //
  // }
  // //Dibuja todo de una
  // void drawCircledLineFromPoints(ArrayList<PVector> points, float radio){
  //   pushMatrix();
  //   translate(width/2,height/2);
  //   scale(radio);
  //
  //   for(int i = 0;i<points.size() - 1;i++){
  //
  //     float x = (cos(points.get(i).x/ratio)) * (size + points.get(i).y);
  //     float y = (sin(points.get(i).x/ratio)) * (size + points.get(i).y);
  //
  //     float x2 = (cos(points.get(i + 1).x/ratio)) * (size + points.get(i + 1).y);
  //     float y2 = (sin(points.get(i + 1).x/ratio)) * (size + points.get(i + 1).y);
  //     line(x,y,x2,y2);
  //   }
  //
  //   popMatrix();
  // }
  void drawLineFromPoints(ArrayList<PVector> points){
    for(int i = 0;i<points.size() - 1;i++){
      strokeWeight(1);
      line(points.get(i).x,points.get(i).y,points.get(i+1).x,points.get(i+1).y);
    }
  }


}
