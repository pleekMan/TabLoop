import controlP5.*;


TablaVirtual tabla;

ControlP5 controles;
ComputerVisionManager cvManager;

void setup() {
  size(700, 700);

  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager();

  controles = new ControlP5(this);
  crearControles();
}

// comentario


void draw() {
  background(0);
  text("FR: " + frameRate, 10, 10);

  // -----
  // DETECTING WHETHER A gridPoint is active on the cameraImage
  PVector[][] gridPoints = tabla.getGridPoints();
  for (int y=0; y < gridPoints.length; y++) {
    for (int x=0; x < gridPoints[0].length; x++) {

      //boolean isOn = cvManager.isOn(gridPoints[y][x].x,gridPoints[y][x].y);      

      // IF CVMANAGER DETECTS POINT IS "ON", SET THE z COMPONENT OF THE gridPoint PVector TO 1 (OR MORE THAN 0);
      gridPoints[y][x].z = cvManager.isOn(gridPoints[y][x].x, gridPoints[y][x].y) ? 0 : 1;
    }
  }
  // -----


  cvManager.render();

  tabla.update();
  tabla.render();
}

// SYSTEM INPUT EVENTS --------------

void mousePressed() {
  tabla.onMousePressed();
}

void mouseReleased() {
  tabla.onMouseReleased();
}

void keyPressed() {
  if (keyCode == DOWN) {
  }
  if (keyCode == UP) {
  }
}

/// GUI CONTROLLERS ------------------------

void correccionPerspectiva(float value) {
  // CALLBACK PARA Slider DE BEZIER MIDPOINT
  tabla.bezierMidPoint.x = map(value, -1, 1, 0, 1);
  tabla.ordenarBeatGrid();
}

void crearControles() {

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
