import controlP5.*; //<>//
import java.util.Date;
import java.io.File;
import java.io.FilenameFilter;

ControlP5 controles;

public SettingsLoader config;
public TablaVirtual tabla;
public ComputerVisionManager cvManager;
public SoundManager soundManager;
public TempoManager tempo;
public ColorPalette colorPalette;

PImage fondo;

void setup() {
  size(960, 700);
  cursor(HAND);
  frameRate(30);

  colorPalette = new ColorPalette();

  config = new SettingsLoader("configuracion.xml");
  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager(this);
  soundManager = new SoundManager(this, "samples");

  tempo = new TempoManager();
  tempo.setBPM(120);
  tempo.start();

  cargarConfiguracionExterna(config);

  controles = new ControlP5(this);
  crearControles();

  fondo = loadImage("tabLoop_back.png");
}


void draw() {
  background(fondo);

  // TEMPO STUFF
  tempo.update();
  if (tempo.isOnBeat()) {
    tabla.stepTime();
    soundManager.reportBeat(tabla.atStep); // PARA SABER CUANDO CAMBIA EL BEAT
  }
  tempo.renderTapButton();
  //-------

  // DETECTING WHETHER A gridPoint is active on the cameraImage
  detectGridInTable();
  // -----

  cvManager.update();
  cvManager.render();

  tabla.update();
  tabla.render();

  //soundManager.update();

  //---

  //- OTHER STUF ----
  drawMouseCoordinates();

  //noLoop();
}

void detectGridInTable() {



  //int atBeat = tabla.getAtBeat();

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
      if ((beat == tabla.atStep) && isOn) {
        soundManager.triggerSound(track);
      }
    }
  }
}

// SYSTEM INPUT EVENTS --------------

void mousePressed() {
  tabla.onMousePressed(mouseX, mouseY);
  if (tempo.isOverTapMarker(mouseX, mouseY)) {
    tempo.tap();
  }
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
  tabla.onKeyPressed(key);
  soundManager.onKeyPressed(key);
}

void cargarConfiguracionExterna(SettingsLoader config) {
  if (config.isLoaded()) {
    tabla.loadSettings(config);
    cvManager.loadSettings(config);
    soundManager.loadSettings(config, "samples", this);

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
    config.saveSoundChannelFiles(soundManager.getFileNamesOrdered());
    config.saveStepwiseOffsets(tabla.getStepwiseOffsets());


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

void loadConfig(int value){
  cargarConfiguracionExterna(config);
}

void umbralCV(float value) {
  cvManager.setUmbral(value);
}

void resetPointOffsets(boolean state) {
  tabla.resetPointsOffset();
}

void enableAdaptiveBinarization(boolean state) {
  cvManager.enableAdaptiveBinarization(state);
}

void imageViewScaling(boolean state) {
  cvManager.setImageMinimized(state);
  /*
  if (state) {
   controles.getController("imageViewScaling").setLabel("MAXIMIZAR");
   controles.getController("imageViewScaling").setPosition(width - 50, 100);
   } else {
   controles.getController("imageViewScaling").setLabel("MINIMIZAR");
   controles.getController("imageViewScaling").setPosition(width - 50, 240);
   }
   */
}

void crearControles() {

  int sliderHeight = 13;
  int sliderWidth = 200;
  color sliderColorBack = colorPalette.BACKGROUND_DARK;
  color sliderColorFront = colorPalette.HIGHLIGHT_GREEN;
  color sliderColorActive = colorPalette.HIGHLIGHT_GREEN_DARK;


  int grillaX = 18;
  int camX = 345;

  controles.setColorBackground(sliderColorBack);
  controles.setColorForeground(sliderColorActive);
  controles.setColorActive(sliderColorFront);



  // GRILLA Y TABLA VIRTUAL

  controles.addButton("resetPointOffsets")
    .setLabel("RESETEAR OFFSETS DE GRILLA")
    .setSize(150, 20)
    .setPosition(grillaX, 590);

  /*
  controles.addSlider("sliderCorreccionPerspectiva")
    .setLabel("PERSPECTIVA")
    .setPosition(grillaX, 630)
    .setSize(sliderWidth, sliderHeight)
    .setRange(-1, 1)
    .setValue(config.loadPerspectiveCorrection())
    .setNumberOfTickMarks(9)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false);
  */
  
  int kSize = cvManager.kernelAreaSize;
  controles.addSlider("kernelSize")
    .setLabel("KERNEL DE PUNTO")
    .setPosition(grillaX, 665)
    .setSize(sliderWidth, sliderHeight)
    .setRange(1, 21)
    .setNumberOfTickMarks(11)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(true)
    .setValue(kSize);

  // CAMARA Y SENSADO

  controles.addToggle("enableAdaptiveBinarization")
    .setLabel("BINARIZACION ADAPTATIVA")
    .setSize(40, 20)
    .setPosition(camX, 583)
    .setValue(false);


  // SI LA CUENTA DE setValue SE HACE EN EL MOMENTO, NO SE ASIGNA. BUG? HAY Q HACERLA ANTES/AFUERA.
  float valorUmbral = cvManager.umbral / 255.0;
  controles.addSlider("umbralCV")
    .setLabel("UMBRAL BINARIO")
    .setPosition(camX, 630)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 1)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(valorUmbral);

  controles.addSlider("adaptiveBinarizationFrequency")
    .setLabel("FRECUENCIA (MINUTOS)")
    .setPosition(camX, 665)
    .setSize(sliderWidth, sliderHeight)
    .setRange(5, 60)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(valorUmbral);


  controles.addToggle("imageViewScaling")
    .setLabel("MINIMIZAR IMAGENES (PERFORMANCE)")
    .setSize(50, 20)
    .setPosition(520, 583);

  // TEMPO
  controles.addKnob("tempo")
    .setLabel("TEMPO")
    .setPosition(900, 580)
    .setSize(35, 35)
    .setRange(60, 200)
    .setNumberOfTickMarks(6)
    .snapToTickMarks(true)
    .setValue(11);

  controles.addTextfield("bpmDisplay")
    .setLabel("BPM")
    .setPosition(790, 602)
    .setSize(50, 13)
    .setValue(" 60");

  // CONFIGURACION

  controles.addButton("saveConfig")
    .setLabel("GUARDAR")
    .setSize(50, 20)
    .setPosition(740, 665);

  controles.addButton("loadConfig")
    .setLabel("CARGAR")
    .setSize(50, 20)
    .setPosition(810, 665);
}

public void drawMouseCoordinates() {
  // MOUSE POSITION
  fill(150);
  text("FR: " + (int)frameRate, width - 70, height - 20);
  text("X: " + mouseX + " / Y: " + mouseY, mouseX, mouseY);
}
