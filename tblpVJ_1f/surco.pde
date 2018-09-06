


class Surco {

  PShape borde;
  float radio;
  float angulo, resolucionAngular;
  float theta, n, delta_n;
  int flip;

  //float posX, posY, posZ;
  color col;

  float ancho;

  float velSubida, tamanioBox, offSetTimeZ;

  float perspectiva;

  PShape estaHeroina;

  int cualHeroina;

  boolean volando;


  Surco(float _radio) {

    radio  = _radio;
    //println("radio:"+radio);

    resolucionAngular = 2*PI*radio/6;
    //println("resolucionAngular:"+resolucionAngular);

    theta = TWO_PI / resolucionAngular;
    flip = int(random(2))*2-1;

    //println("theta: "+theta);

    velSubida = 0;
    tamanioBox = 0;


    borde = createShape();
    //seleccionarColor();
    //col = color(random(64, 255), random(64, 255), random(64, 255));

    ancho = 4;

    delta_n = 7;

    perspectiva = 3.6;

    volando = false;
    estaHeroina = heroinas[int(random(10))];
    estaHeroina.setVisible(false);
  }

  void generar() {

    borde.beginShape();
    //borde.fill(col);
    //borde.noStroke();
    borde.noFill();
    borde.stroke(col);
    borde.strokeWeight(ancho);

    for (int i = int(resolucionAngular); i > 0; i--) {

      //println("i: "+i);
      n = random(radioDelta/delta_n/5, radioDelta/delta_n);
      if (flip >0) {
        flip = -1;
      } else {
        flip = 1;
      }
      float x = (radio+(n*flip)) * cos(theta*i);
      float y = (radio+(n*flip)) * sin(theta*i);
      //println("x["+i+"]: "+x);
      //println("y["+i+"]: "+y);
      borde.vertex(x, y);
    }

    borde.endShape(CLOSE);
  }


  void dibujar() {

    if (volando) {
      estaHeroina.setVisible(true);
    } else {
      estaHeroina.setVisible(false);
    }


    pushMatrix();
    rotateX(PI/perspectiva);

    emergente();
    popMatrix();

    pushMatrix();
    rotateX(PI/perspectiva);
    girar();
    shape(borde, 0, 0);
    popMatrix();
  }

  void cambiar() {
    for (int i = 0; i < borde.getVertexCount(); i++) {
      //PVector v = borde.getVertex(i);
      //v.x += random(-1, 1);
      //v.y += random(-1, 1);
      if (flip >0) {
        flip = -1;
      } else {
        flip = 1;
      }

      if (theta*(i+7) > (TWO_PI*21.5/24-angulo) % TWO_PI && theta*(i-7) < (TWO_PI*21.5/24-angulo) % TWO_PI ) {
        delta_n = 1.6;
      } else {
        delta_n = 7;
      }
      //println("delta_n["+i+"]: "+delta_n);

      n = random(radioDelta/delta_n/5, radioDelta/delta_n);


      float x = (radio+(n*flip)) * cos(theta*i);
      float y = (radio+(n*flip)) * sin(theta*i);
      //println("x["+i+"]: "+x);
      //println("y["+i+"]: "+y);

      borde.setVertex(i, x, y);
      //borde.stroke(col);
    }
  }



  void girar() {
    angulo = (millis()*0.1*-velRot) % TWO_PI;

    rotateZ(angulo);
  }


  void seleccionarColorPaleta(color _col) {
    borde.stroke(_col);
  }


  void emergente() {
    float x = (radio-25) * cos(TWO_PI*23/24);
    float y = (radio-25) * sin(TWO_PI*23/24);

    float z = ((offSetTimeZ+millis())*0.1*velSubida);

    if (velSubida > 0) {
      velSubida *= 0.995;
    }

    if (z > height*1.25) {
      offSetTimeZ = 0;
      tamanioBox = 0;
      //estaHeroina.setVisible(true);
      volando = false;
      velSubida = 0;
    }



    pushMatrix();
    pushStyle();

    rotate(-PI/8);

    translate(x, y, z);

    rotateZ(PI/8);

    scale(0.66, 1);

    //rotate(PI/4);
    //noFill();
    //fill(random(0, 255), random(0, 255), random(0, 255));
    //fill(col);
    //stroke(0);
    //strokeWeight(ancho*0.4);
    //rotateX(millis()*0.001);
    //rotateY(millis()*0.0015);
    //rotateZ(millis()*0.0005);
    //box(tamanioBox);



    shape(estaHeroina, 0, 0);

    popStyle();
    popMatrix();
  }
}
