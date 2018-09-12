import controlP5.*;
import java.util.Date;
import java.io.File;
import java.io.FilenameFilter;
import processing.serial.*;


ControlP5 controles;

public SettingsLoader config;
public TablaVirtual tabla;
public ComputerVisionManager cvManager;
public SoundManager soundManager;
public TempoManager tempo;
public ColorPalette colorPalette;
public OscManager oscManager;
public ArduinoManager arduino;

Serial port;

PImage fondo;

void setup() {
  size(960, 700);
  cursor(HAND);
  frameRate(30);

  colorPalette = new ColorPalette();

  config = new SettingsLoader("configuracion.xml");
  tabla = new TablaVirtual();
  cvManager = new ComputerVisionManager(this);
  soundManager = new SoundManager(this);
  oscManager = new OscManager(this);
  arduino = new ArduinoManager(this);

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
    int atStep = tabla.stepTime();
    soundManager.reportBeat(atStep); // PARA AVISAR CUANDO CAMBIA EL BEAT
    oscManager.reportBeat(atStep);
    arduino.sendBeat(tabla.atStep);
  }
  tempo.renderTapButton();


  //-------

  //arduino.update();

  // DETECTING WHETHER A gridPoint is active on the cameraImage
  detectGridInTable();
  // -----

  cvManager.update();
  cvManager.render();

  tabla.update();
  tabla.render();

  soundManager.update();

  oscManager.update();

  //---

  //- OTHER STUF ----
  drawMouseCoordinates();

  //noLoop();
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
      if ((beat == tabla.atStep) && isOn) {
        soundManager.triggerSound(track);
        oscManager.sendTrack(track);
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
  if (key == '1') {
    //println("-|| OSC : Sending Track 1");
    //oscManager.sendTrack(1);
    //arduino.sendBeat(0);
    port.write(0);
  }
  if (key == '2') {
    //println("-|| OSC : Sending Track 2");
    //oscManager.sendTrack(2);
    //arduino.sendBeat(1);
    port.write(1);
  }
  if (key == '3') {
    port.write(2);
  }


  tabla.onKeyPressed(key);
  cvManager.onKeyPressed(key);
  soundManager.onKeyPressed(key);
}

/// ------- CONFIGURACION EXTERNA EN XML

void cargarConfiguracionExterna(SettingsLoader config) {
  if (config.isLoaded()) {
    tempo.loadSettings(config);
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
    //TABLA
    config.saveBoundingBox(tabla.boundingBox);
    config.saveCornerPoints(tabla.cornerPoints);
    config.savePerspectiveCorrection(map(tabla.getPerspectiveCorrection(), 0, 1, -1, 1));
    config.saveStepwiseOffsets(tabla.getStepwiseOffsets());
    config.savePointsOffset(tabla.getGridPointOffsets());

    // COMPUTER VISION
    config.saveCvKernelSize(cvManager.kernelAreaSize);
    config.saveKernelMode(cvManager.kernelModeAverage); // NOT WORKING WELL
    config.saveCvThreshold(cvManager.umbral);
    //config.saveAdaptiveBinarization(cvManager.enableAdaptiveBinarization);
    config.saveCvBrightness(cvManager.brillo);
    config.saveCvContrast(cvManager.contraste);
    config.saveCvDilate(cvManager.dilatePasses);
    config.saveCvErode(cvManager.erodePasses);

    // SONIDO
    config.saveSoundChannelFiles(soundManager.getFileNamesOrdered()); // FIRST THIS
    //config.saveSoundVolumes(soundManager.getChannelVolumes()); // SECOND THIS //<>//
    config.saveTempo(tempo.getBPM());


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
void kernelMode(boolean state) {
  // TRUE: AVERAGE, FALSE: AT LEAST 1 POINT
  cvManager.setKernelModeAverage(state);
  controles.getController("kernelMode").setLabel(state ? "MODO KERNEL => PROMEDIO" : "MODO KERNEL => AL MENOS 1 PIXEL");
}

void saveConfig(int value) {
  guardarConfiguracionExterna();
}

void loadConfig(int value) {
  cargarConfiguracionExterna(config);
}

void umbralCV(float value) {
  cvManager.setUmbral(value);
}

void brilloCV(float value) {
  cvManager.setBrillo(value);
}

void contrasteCV(float value) {
  cvManager.setContraste(value);
}

void dilatarCV(float value) {
  cvManager.setDilatePasses(int(value));
}
void erosionarCV(float value) {
  cvManager.setErodePasses(int(value));
}

void resetPointOffsets(boolean state) {
  tabla.resetPointsOffset();
}

/*
void enableAdaptiveBinarization(boolean state) {
  cvManager.enableAdaptiveBinarization(state);
}
*/

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

void tempo(int value) {
  tempo.setBPM(value);
}

void playPauseButton(boolean state) {
  if (state) {
    tabla.play();
    controles.getController("playPauseButton").setLabel("PAUSAR");
  } else {
    tabla.pause();
    controles.getController("playPauseButton").setLabel("PLAY");
  }
}

void crearControles() {

  int sliderHeight = 13;
  int sliderWidth = 150;
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


  controles.addToggle("kernelMode")
    .setLabel("MODO KERNEL => AL MENOS 1 PIXEL")
    .setSize(40, 20)
    .setPosition(grillaX, 620)
    .setValue(false);

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
  /*
  controles.addToggle("enableAdaptiveBinarization")
   .setLabel("BINARIZACION ADAPTATIVA")
   .setSize(40, 20)
   .setPosition(camX, 583)
   .setValue(false);
   */


  // SI LA CUENTA DE setValue SE HACE EN EL MOMENTO, NO SE ASIGNA. BUG? HAY Q HACERLA ANTES/AFUERA.
  float valorUmbral = cvManager.umbral / 255.0;
  controles.addSlider("umbralCV")
    .setLabel("UMBRAL BINARIO")
    .setPosition(camX, 590)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 1)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(valorUmbral);

  /*
  controles.addSlider("adaptiveBinarizationFrequency")
   .setLabel("FRECUENCIA (MINUTOS)")
   .setPosition(camX, 665)
   .setSize(sliderWidth, sliderHeight)
   .setRange(5, 60)
   .setNumberOfTickMarks(5)
   .setSliderMode(Slider.FLEXIBLE)
   .snapToTickMarks(false)
   .setValue(valorUmbral);
   */

  // BRILLO CV
  float br = cvManager.brillo / 255.0;
  controles.addSlider("brilloCV")
    .setLabel("BRILLO")
    .setPosition(camX, 630)
    .setSize(sliderWidth, sliderHeight)
    .setRange(-1, 1)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(br);

  // CONTRASTE CV
  float con = cvManager.contraste;
  controles.addSlider("contrasteCV")
    .setLabel("CONTRASTE")
    .setPosition(camX, 670)
    .setSize(sliderWidth, sliderHeight)
    .setRange(0, 1)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(false)
    .setValue(con);

  // DILATE
  int dil = cvManager.dilatePasses;
  controles.addSlider("dilatarCV")
    .setLabel("DILATAR")
    .setPosition(580, 630)
    .setSize(int(sliderWidth * 0.5), sliderHeight)
    .setRange(0, 4)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(true)
    .setValue(dil);

  // ERODE
  int ero = cvManager.erodePasses;
  controles.addSlider("erosionarCV")
    .setLabel("EROSIONAR")
    .setPosition(580, 670)
    .setSize(int(sliderWidth * 0.5), sliderHeight)
    .setRange(0, 4)
    .setNumberOfTickMarks(5)
    .setSliderMode(Slider.FLEXIBLE)
    .snapToTickMarks(true)
    .setValue(ero);


  controles.addToggle("imageViewScaling")
    .setLabel("MINIMIZAR IMAGENES")
    .setSize(50, 20)
    .setPosition(580, 583);

  // TEMPO
  controles.addKnob("tempo")
    .setLabel("TEMPO (BPM)")
    .setPosition(900, 580)
    .setSize(35, 35)
    .setRange(60, 250)
    .setNumberOfTickMarks(6)
    .snapToTickMarks(false)
    .setValue(tempo.getBPM());

  controles.addToggle("playPauseButton")
    .setLabel("PAUSAR")
    .setSize(50, 15)
    .setPosition(790, 602)
    .setState(true);


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

/// ----- OSC STUFF\
/*
// THIS WORKS IF OUT AND IN PORTS ARE THE SAME (DEBUGGING ON SAME COMPUTER)
 void oscEvent(OscMessage theOscMessage) {
 print("### received an osc message.");
 print(" addrpattern: "+theOscMessage.addrPattern());
 println(" typetag: "+theOscMessage.typetag());
 println(" || VALUE: "+ theOscMessage.get(0).intValue());
 }
 */
