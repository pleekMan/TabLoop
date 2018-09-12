import netP5.*;
import oscP5.*;

import processing.svg.*;

//PShader blur;
PShader sh;
PImage fdoComic;

PShape siluetaCiudad, siluetaCiudad2, estrella;


Surco[] surcos;


color[] paletaColores;

float radioDelta, radioOffset;
float velRot;

color celesteMusica, 
  magentGastro, 
  bordoVisuales, 
  amariBACiudVerde, 
  azulHumor, 
  amarillCine, 
  naranjModa, 
  blancoDeportUrb, 
  celestArteUrb, 
  amariTranspSust, 
  celesteEmergentito, 
  rojoLetras, 
  naranjaRadioEnVivo, 
  marronDanzasUrb;

PShape h_musica, 
  h_cine, 
  h_moda, 
  h_arteUrb, 
  h_visuales, 
  h_BACVerde, 
  h_humor, 
  h_deportUrb, 
  h_emergentito, 
  h_letras, 
  h_radioEnVivo;

PShape[] heroinas;

OscP5 oscComm;

void settings(){
 fullScreen(P3D,2); 
}

void setup() {
  //size(1024, 768, P3D);
  //size(640,480, P3D);
  ortho();
  //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0+100, -height, 0, 0, 1, 0);

  sh = loadShader("sh.frag", "sh.vert");
  sh.set("resolution", (float)width, (float)height);

  fdoComic = loadImage("fdoComicInv.png");

  siluetaCiudad = loadShape("silueta_ciudad.svg");
  siluetaCiudad2 = loadShape("silueta_ciudad_2.svg");
  estrella = loadShape("estrella.svg");

  h_musica = loadShape("h_musica.svg");
  h_cine = loadShape("h_cine.svg");
  h_moda = loadShape("h_moda.svg");
  h_arteUrb = loadShape("h_arteUrb.svg");
  h_visuales = loadShape("h_visuales.svg");
  h_BACVerde = loadShape("h_BACVerde.svg");
  h_humor = loadShape("h_humor.svg");
  h_deportUrb = loadShape("h_deportUrb.svg");
  h_emergentito = loadShape("h_emergentito.svg");
  h_letras = loadShape("h_letras.svg");
  h_radioEnVivo = loadShape("h_radioEnVivo.svg");

  heroinas = new PShape[10];

  heroinas[0] = h_musica;
  heroinas[1] = h_cine;
  heroinas[2] = h_moda;
  heroinas[3] = h_arteUrb;
  heroinas[4] = h_visuales;
  heroinas[5] = h_BACVerde;
  heroinas[6] = h_humor;
  heroinas[7] = h_deportUrb;
  heroinas[8] = h_letras;
  heroinas[9] = h_radioEnVivo;


  celesteMusica = color(113, 205, 242);
  magentGastro = color(210, 31, 70);
  bordoVisuales = color(130, 21, 26);
  amariBACiudVerde = color(246, 235, 0);
  azulHumor = color(0, 103, 141);
  amarillCine = color(255, 206, 0);
  naranjModa = color(232, 124, 37);
  blancoDeportUrb = color(255, 255, 255);
  celestArteUrb = color(0, 138, 203);
  amariTranspSust = color(255, 229, 0);
  celesteEmergentito = color(113, 205, 242);
  rojoLetras = color(238, 33, 36);
  naranjaRadioEnVivo = color(248, 156, 31);
  marronDanzasUrb = color(169, 115, 43);

  surcos = new Surco[10];

  paletaColores = new color[10];

  paletaColores[0] = amarillCine;
  paletaColores[1] = naranjModa;
  paletaColores[2] = marronDanzasUrb;
  paletaColores[3] = bordoVisuales;
  paletaColores[4] = magentGastro;
  paletaColores[5] = color(230, 129, 172); //#E681AC
  paletaColores[6] = azulHumor;
  paletaColores[7] = celestArteUrb;
  paletaColores[8] = celesteMusica;
  paletaColores[9] = color(114, 191, 68); // #72BF44

  radioDelta = width / surcos.length * 0.80;
  radioOffset = width/8;

  for (int i=0; i < surcos.length; i++) {
    surcos[i] = new Surco(radioDelta*(i+1)+radioOffset);
    surcos[i].col = paletaColores[i];
    surcos[i].generar();
  }

  velRot = 0.003;

  oscComm = new OscP5(this, 12001);
}


void draw() {

  //shader(sh);
  //sh.set("time", (float)millis());
  //sh.set("vX", map(mouseX, 0, width, 0.0, 1.0));

  //velRot = mouseY/40000.0;

  background(0);


  pushMatrix();
  pushStyle();
  //fill(0, 0, 0, 0.5);
  //noStroke();
  //rect(0, 0, width, height);

  translate(0, 0, -width*2);
  image(fdoComic, 0, 0, width, height);

  //translate(width/2, height/4, width*0.2);
  //scale(1.5);

  ////estrella.setFill(color(amariTranspSust, 0.3));
  //shape(estrella, 0, 0);

  popStyle();
  popMatrix();




  pushMatrix();

  translate(width*0.05, height*0.95);

  //rotateX(PI/4);

  //rotateZ(millis()*0.1*-0.01);

  for (int i=0; i < surcos.length; i++) {
    surcos[i].dibujar();
    //surcos[i].girar();
  }

  popMatrix();

  pushMatrix();

  translate(0, height*1.03, width/2);

  siluetaCiudad.setFill(color(192));
  shape(siluetaCiudad, -170, 0, width*1.3, width*0.2);

  translate(0, 0, -width);
  siluetaCiudad2.setFill(color(64));
  translate(0, 0, -width);

  shape(siluetaCiudad2, -50, -20, width, width*0.34);

  popMatrix();
}

void keyPressed() {

  for (int i=0; i < surcos.length; i++) {

    //if (key == ' ') {
    //  //surcos[i].seleccionarColor();
    //  surcos[i].cambiar();
    //}

    if (key == i+48) {            
      surcos[i].offSetTimeZ = millis()*-1.0;
      //println("surcos["+i+"].offSetTimeZ: "+surcos[i].offSetTimeZ);
      surcos[i].velSubida = 9;
      //println("surcos[i].velSubida: "+surcos[i].velSubida);
      surcos[i].volando = true;
      surcos[i].estaHeroina = heroinas[int(random(10))];
      surcos[i].estaHeroina.setVisible(true);

      //surcos[i].tamanioBox = surcos[i].ancho*12;
      surcos[i].cambiar();
    }
  }
}

void triggerHeroina(int i) {


    surcos[i].offSetTimeZ = millis()*-1.0;
    //println("surcos["+i+"].offSetTimeZ: "+surcos[i].offSetTimeZ);
    surcos[i].velSubida = 9;
    //println("surcos[i].velSubida: "+surcos[i].velSubida);
    surcos[i].volando = true;
    surcos[i].estaHeroina = heroinas[int(random(10))];
    surcos[i].estaHeroina.setVisible(true);

    //surcos[i].tamanioBox = surcos[i].ancho*12;
    surcos[i].cambiar();
  
}

/// ----- OSC STUFF\
// THIS WORKS IF OUT AND IN PORTS ARE THE SAME (DEBUGGING ON SAME COMPUTER)
void oscEvent(OscMessage theOscMessage) {
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());
  int inValue = theOscMessage.get(0).intValue();
  //println(" || VALUE: " + inValue );
  
  triggerHeroina(inValue);
}
