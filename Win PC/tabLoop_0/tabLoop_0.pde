import controlP5.*;

ControlP5 controles;

TablaVirtual tabla;
ComputerVisionManager cvManager;
SoundManager soundManager;

void setup() {
  size(700, 700);

  controles = new ControlP5(this);
  crearControles();
  
  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager();
  soundManager = new SoundManager();

}


void draw() {
  background(0);
  text("FR: " + frameRate, 10, 10);

  
  // -----
  // DETECTING WHETHER A gridPoint is active on the cameraImage
  PVector[][] gridPoints = tabla.getGridPoints();
  for (int track=0; track < gridPoints.length; track++) {
    for (int beat=0; beat < gridPoints[0].length; beat++) {

      // IF CVMANAGER DETECTS POINT IS "ON" 
      boolean isOn = cvManager.isOn(gridPoints[track][beat].x, gridPoints[track][beat].y);
      
      // SET THE z COMPONENT OF THE gridPoint PVector TO 1 (OR MORE THAN 0);
      gridPoints[track][beat].z =  isOn ? 1 : 0;
      
      // TRIGGER TRACK AUDIO
      soundManager.triggerSound(track);
      
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

void sliderCorreccionPerspectiva(float value) {
  // CALLBACK PARA Slider DE BEZIER MIDPOINT
  tabla.bezierMidPoint.x = map(value, -1, 1, 0, 1);
  tabla.ordenarBeatGrid();
}

void crearControles() {

  controles.addSlider("sliderCorreccionPerspectiva")
    .setLabel("PERPECTIVA")
    .setPosition(20, height - 50)
    .setWidth(200)
    .setRange(-1, 1)
    .setValue(0)
    .setNumberOfTickMarks(9)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false);
}
