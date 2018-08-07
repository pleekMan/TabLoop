import controlP5.*;


TablaVirtual tabla;

ControlP5 controles;

void setup() {
  size(700, 500);
  tabla = new TablaVirtual();

  controles = new ControlP5(this);
  crearControles();

}


void draw() {
  background(0);


  tabla.update();
  tabla.render();
}


void mousePressed() {
  tabla.detectarTocarEsquinas(mouseX, mouseY);
}

void mouseReleased() {
  tabla.draggingCorner = false;
}

void keyPressed() {
  if (keyCode == DOWN) {

  }
  if (keyCode == UP) {

  }

}

void correccionPerspectiva(float value) {
  tabla.bezierMidPoint.x = map(value, -1, 1, 0, 1);
  tabla.ordenarTrackSteps();
}

void crearControles(){
  
  controles.addSlider("correccionPerspectiva")
    .setLabel("PERPECTIVA")
    .setPosition(20, height - 50)
    .setWidth(200)
    .setRange(-1, 1)
    .setValue(0)
    .setNumberOfTickMarks(9)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false);
    
}
