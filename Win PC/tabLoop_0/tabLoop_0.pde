import controlP5.*; //<>// //<>// //<>//
import processing.sound.*;
import java.util.Date;

ControlP5 controles;

SettingsLoader config;
public TablaVirtual tabla;
ComputerVisionManager cvManager;
//SoundManager soundManager;

void setup() {
  size(1000, 700);
  cursor(HAND);


  config = new SettingsLoader("configuracion.xml");
  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager(this);
  // soundManager = new SoundManager(this);

  cargarConfiguracionExterna(config);

  controles = new ControlP5(this);
  crearControles();

}


void draw() {
  background(0);
  text("FR: " + frameRate, 10, 10);


  // DETECTING WHETHER A gridPoint is active on the cameraImage
  detectGridInTable();
  // -----

  cvManager.update();
  cvManager.render();

  tabla.update();
  tabla.render();

  //---

}

void detectGridInTable() {
  // DETECTING WHETHER A gridPoint is active on the cameraImage
  PVector[][] gridPoints = tabla.getGridPoints(); // THIS GET'S THE OFFSETED COPY OF GRIDPOINTS
  for (int track=0; track < gridPoints.length; track++) {
    for (int beat=0; beat < gridPoints[0].length; beat++) {

      //println(gridPoints[track][beat].x + " \t\t " + gridPoints[track][beat].y);

      // IF CVMANAGER DETECTS POINT IS "ON" 
      boolean isOn = cvManager.isOn(gridPoints[track][beat].x, gridPoints[track][beat].y);

      // SET THE z COMPONENT OF THE gridPoint PVector TO 1 (OR MORE THAN 0);
      tabla.setGridPointState(track, beat, isOn);

      // TRIGGER TRACK AUDIO
      //soundManager.triggerSound(track);
    }
  }
}

// SYSTEM INPUT EVENTS --------------

void mousePressed() {
  tabla.onMousePressed(mouseX, mouseY);
}

void mouseReleased() {
  tabla.onMouseReleased(mouseX, mouseY);
  cursor(HAND);
}

void mouseDragged() {
  tabla.onMouseDragged(mouseX, mouseY);
}

void keyPressed() {
  if (keyCode == DOWN) {
  }
  if (keyCode == UP) {
  }
  if (key == ' ') {
    // cvManager.adaptContrast(tabla.getGridPoints());
  }
  //soundManager.onKeyPrssd(key);
}

void cargarConfiguracionExterna(SettingsLoader config) {
  if (config.isLoaded()) {
    tabla.loadSettings(config);
    cvManager.loadSettings(config);
    println("-|| CONFIGURACION ANTERIOR CARGADA");
  } else {
    println("-|| LA CONFIGURACION ANTERIOR NO SE CARGO.\n-||FIJATE QUE ONDA CON EL ARCHIVO configuracion.xml EN LA CARPETA data");
  }
}

void guardarConfiguracionExterna() {
  if (config.isLoaded()) {
    config.saveBoundingBox(tabla.boundingBox);
    config.saveCornerPoints(tabla.cornerPoints);
    config.savePerspectiveCorrection(map(tabla.getPerspectiveCorrection(), 0, 1, -1, 1));
    config.saveCvKernelSize(cvManager.kernelAreaSize);
    config.saveCvThreshold(cvManager.umbral);
    config.savePointsOffset(tabla.getGridPointOffsets());
    config.saveAdaptiveBinarization(cvManager.enableAdaptiveBinarization);


    config.guardar();
    println("-|| CONFIGURACION GUARDADA");
  } else {
    println("-|| LA CONFIGURACION NO SE GUARDO.\n-||FIJATE QUE ONDA CON EL ARCHIVO configuracion.xml EN LA CARPETA data");
  }
}

/// GUI CONTROLLERS ------------------------

void sliderCorreccionPerspectiva(float value) {
  // CALLBACK PARA Slider DE BEZIER MIDPOINT
  tabla.bezierMidPoint.x = map(value, -1, 1, 0, 1);
  tabla.ordenarBeatGrid();
}

void kernelSize(float value) {
  int kernelEntero = (int)value;
  cvManager.setKernelSize(kernelEntero);
  tabla.kernelSize = kernelEntero;
}

void saveConfig(int value) {
  guardarConfiguracionExterna();
}

void umbralCV(float value) {
  cvManager.setUmbral(value);
}

void resetPointOffsets(boolean state){
  tabla.resetPointsOffset();
}

void enableAdaptiveBinarization(boolean state){
 cvManager.enableAdaptiveBinarization(state); 
}

void crearControles() {

  controles.addSlider("sliderCorreccionPerspectiva")
    .setLabel("PERSPECTIVA")
    .setPosition(20, height - 90)
    .setWidth(200)
    .setRange(-1, 1)
    .setValue(config.loadPerspectiveCorrection())
    .setNumberOfTickMarks(9)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false);

  int kSize = cvManager.kernelAreaSize;
  controles.addSlider("kernelSize")
    .setLabel("KERNEL DE PUNTO")
    .setPosition(20, height - 60)
    .setWidth(200)
    .setRange(1, 21)
    .setNumberOfTickMarks(11)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(true)
    .setValue(kSize);

  // SI LA CUENTA DE setValue SE HACE EN EL MOMENTO, NO SE ASIGNA. BUG? HAY Q HACERLA ANTES/AFUERA.
  float valorUmbral = cvManager.umbral / 255.0;
  controles.addSlider("umbralCV")
    .setLabel("UMBRAL BINARIO")
    .setPosition(20, height - 30)
    .setWidth(200)
    .setRange(0, 1)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(valorUmbral);

  controles.addButton("resetPointOffsets")
    .setLabel("RESETEAR OFFSETS DE PUNTOS")
    .setSize(150, 20)
    .setPosition(330, height - 90);

  controles.addToggle("enableAdaptiveBinarization")
    .setLabel("Habilitar Binarizacion Adaptativa")
    .setSize(40, 20)
    .setPosition(330, height - 60);


  controles.addButton("saveConfig")
    .setLabel("GUARDAR CONFIGURACION")
    .setSize(150, 20)
    .setPosition(500, height - 60);
}
