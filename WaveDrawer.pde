class WaveDrawer{

  int size;//largo de la línea
  float radio; //radio del circulo(relación con la cantidad de puntos)
  int relation; //TENGO QUE VER COMO NO USAR ESTE NUM PARA QUE EL SIZE PUEDA VARIAR Y QUE NO ME JODA EL RADIO

  float ratio; //distancia entre los puntos
  int nLinesTillFullCircle;//cuantas lineas hasta completar el círculo
  int from;

  int resol;//detalle de la linea
  int idx;//rasteo que seccion de la línea dibujé

  WaveDrawer(float _radio,float  _speed){

    size = width;//largo de la línea
    radio = _radio;

    //ratio = size/6.27;//ASí depende de la cantidad de puntos que tiene la línea (para no overlapear)
    ratio = (25.69)/_speed;
    nLinesTillFullCircle = int(ratio * 6.6); //599;
    from = 0;

    resol = 1;  //detalle de la linea
    idx = 0;

    stroke(255);
    strokeWeight(3);
  }

  public void draw(ArrayList<PVector> points){

    for(int i = from; i<idx;i++){
      float x = (cos(points.get(i).x/ratio)) * (size + pow(points.get(i).y,3) );
      float y = (sin(points.get(i).x/ratio)) * (size + pow(points.get(i).y,3) );

      float x2 = (cos(points.get(i + 1).x/ratio)) * (size + pow(points.get(i+1).y,3) );
      float y2 = (sin(points.get(i + 1).x/ratio)) * (size + pow(points.get(i+1).y,3) );

      pushMatrix();
      translate(width/2,height/2);
      scale(radio);
      stroke(255);
      line(x,y,x2,y2);
      popMatrix();

    }
  }
  public void update(ArrayList<PVector> points){
    idx ++;
    if(idx >= points.size() - 1){
      idx = 0;
      from = 0;
    }else if(idx > nLinesTillFullCircle){
      from++;
    }
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
