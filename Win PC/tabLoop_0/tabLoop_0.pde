
import controlP5.*;
import processing.sound.*;
import java.util.Date;

ControlP5 controles;

SettingsLoader config;
TablaVirtual tabla;
ComputerVisionManager cvManager;
//SoundManager soundManager;

void setup() {
  size(1000, 700);


  config = new SettingsLoader("configuracion.xml");
  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager(this);
  //soundManager = new SoundManager();

  cargarConfiguracionExterna(config);

  controles = new ControlP5(this);
  crearControles();
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
      //soundManager.triggerSound(track);
    }
  }
  // -----

  cvManager.update();
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
    config.saveCvKernelSize(cvManager.areaSize);
    config.saveCvThreshold(cvManager.umbral);

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

void crearControles() {

  controles.addSlider("sliderCorreccionPerspectiva")
    .setLabel("PERSPECTIVA")
    .setPosition(20, height - 70)
    .setWidth(200)
    .setRange(-1, 1)
    .setValue(config.loadPerspectiveCorrection())
    .setNumberOfTickMarks(9)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false);

  int kSize = cvManager.areaSize;
  controles.addSlider("kernelSize")
    .setLabel("KERNEL DE PUNTO")
    .setPosition(20, height - 50)
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

  controles.addButton("saveConfig")
    .setLabel("GUARDAR CONFIGURACION")
    .setSize(150, 20)
    .setPosition(350, height - 50);
}
