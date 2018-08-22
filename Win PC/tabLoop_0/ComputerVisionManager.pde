import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

class ComputerVisionManager {

  PApplet p5;

  Capture videoIn;
  OpenCV opencv;

  PImage camImage;
  PVector imageScreenPos;
  int umbral;
  int kernelAreaSize;

  boolean enableAdaptiveBinarization;
  PVector contrastBoxCenter;
  int contrastBoxSize;
  Timer adaptiveBinarizationTimer;


  public ComputerVisionManager(PApplet _p5) {
    p5 = _p5;

    videoIn = new Capture(p5, 1280, 960); // RESOLUCION NATIVA DE Logitech C270
    videoIn.start();

    opencv = new OpenCV(p5, videoIn);


    camImage = loadImage("camView.png");
    imageScreenPos = new PVector(0, 0);
    umbral = 127;
    println("-|| UMBRAL: " + umbral);


    kernelAreaSize = 9; // IMPARES, ASI EXISTE UN PIXEL CENTRAL

    enableAdaptiveBinarization = false;
    contrastBoxCenter = new PVector(videoIn.width * 0.5, videoIn.height * 0.5);
    contrastBoxSize = int(videoIn.width * 0.25);


    adaptiveBinarizationTimer = new Timer();
    adaptiveBinarizationTimer.setDurationInSeconds(10);
    if (enableAdaptiveBinarization)adaptiveBinarizationTimer.start();
  }
  public void update() {

    //-- CADA TANTO, EJECUTAR PROCESO DE CONTRASTE ADAPTATIVO
    if (enableAdaptiveBinarization) {
      if (adaptiveBinarizationTimer.isFinished()) {
        adaptContrast(tabla.getGridPoints()); // ESTO SE PUEDE LLAMAR ASI SOLO PORQ ESTAMOS EN PROCESSING IDE
        adaptiveBinarizationTimer.start();
        controles.getController("umbralCV").setValue(cvManager.umbral / 255.0);  // ESTO SE PUEDE LLAMAR ASI SOLO PORQ ESTAMOS EN PROCESSING IDE
      }
    }
    //----

    if (videoIn.available()) {
      videoIn.read();
      opencv.loadImage(videoIn);
    }

    opencv.gray();
    opencv.threshold(umbral);
    opencv.invert();

    camImage = opencv.getOutput();
  }


  public void render() {

    float escala1 = 0.1; //0.5 // IMAGEN OPERADA
    float escala2 = 0.1; //0.25 // IMAGEN DE ENTRADA

    // IMAGEN DE ENTRADA (escala2)
    image(videoIn, camImage.width * escala1, 0, videoIn.width * escala2, videoIn.height * escala2);

    // IMAGEN OPERADA (escala1)
    image(camImage, 0, 0, camImage.width * escala1, camImage.height * escala1);

    // DIBUJAR CONTORNO DE LA IMAGEN
    noFill();
    stroke(255, 0, 0);
    rect(0, 0, camImage.width *escala1, camImage.height * escala1);

    // DIBUJAR AREA DE CONTRASTE ADAPTATIVO (SOBRE IMAGEN DE ENTRADA)
    stroke(0, 0, 255);
    float posX = (camImage.width * escala1) + ((contrastBoxCenter.x - (contrastBoxSize * 0.5)) * escala2);
    float posY = (contrastBoxCenter.y - (contrastBoxSize * 0.5)) * escala2;
    rect(posX, posY, contrastBoxSize * escala2, contrastBoxSize * escala2);

    fill(255, 0, 0);
    ellipse( (camImage.width * escala1) + contrastBoxCenter.x * escala2, contrastBoxCenter.y * escala2, 5, 5);
    noFill();
    //---
  }


  boolean isOn(float x, float y) {
    // x & y SHOULD ENTER NORMALIZED

    //println(x + " \t\t " + y);

    int imageX = (int)(x * camImage.width);
    int imageY = (int)(y * camImage.height);

    int pxBrightness = -1;

    if (kernelAreaSize == 1) {
      if (pixelIsInsideBounds(imageX, imageY)) {
        int pxSlot = imageX + (imageY * camImage.width);
        pxBrightness = camImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL
      } else {
        pxBrightness = 0;
      }
    } else {
      //println("Kernel = " + areaSize);
      pxBrightness = evaluateArea(imageX, imageY, kernelAreaSize);
    }

    return pxBrightness > umbral;
  }

  int evaluateArea(int xCenter, int yCenter, int kernelSize) {

    int brilloAcumulativo = 0;

    // FROM NEGATIVE TO POSITIVE (ES FACIL DESPUES SIMPLEMENTE SUMARLE x/y AL PIXEL CENTRAL)
    int kernelStart = 0 - floor(kernelSize * 0.5); 

    for (int y= kernelStart; y < -kernelStart; y++) {
      for (int x= kernelStart; x < -kernelStart; x++) {

        int pixelX = xCenter + x;
        int pixelY = yCenter + y;

        if (pixelIsInsideBounds(pixelX, pixelY)) {
          int pxSlot = pixelX + (pixelY * camImage.width);
          brilloAcumulativo += camImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL
        }
      }
    }

    return brilloAcumulativo / (kernelSize * kernelSize);
  }


  public void adaptContrast(PVector[][] gridPoints) {

    // SAMPLEAMOS UN AREA CUADRADA DENTRO DE LA TABLA.
    // EL AREA SE SITUA EN EL MEDIO DE LOS cornerGRidPoints, Y TIENE UN ANCHO boxSize (camWidth * 0.25)
    PVector point1 = gridPoints[0][0];
    PVector point2 = gridPoints[0][gridPoints[0].length - 1];
    PVector point3 = gridPoints[gridPoints.length - 1][0];
    PVector point4 = gridPoints[gridPoints.length - 1][gridPoints[0].length - 1];

    contrastBoxCenter = new PVector();
    contrastBoxCenter.add(point1);
    contrastBoxCenter.add(point2);
    contrastBoxCenter.add(point3);
    contrastBoxCenter.add(point4);
    contrastBoxCenter.div(4.0); // PROMEDIO
    contrastBoxCenter.x *= videoIn.width; // ESCALAR A SCREEN SPACE
    contrastBoxCenter.y *= videoIn.height;
    //println("-|| CONTRAST BOX CENTER :: X: " + contrastBoxCenter.x + " | y: " + contrastBoxCenter.y); 

    // EXTRAER CACHITO DE IMAGEN PARA ANALIZAR
    float proporcionDeArea = 0.2;
    contrastBoxSize = int(videoIn.width * proporcionDeArea);
    PImage area = videoIn.get().get(int(contrastBoxCenter.x - (contrastBoxSize * 0.5)), int(contrastBoxCenter.y - (contrastBoxSize * 0.5)), contrastBoxSize, contrastBoxSize);


    // BUSCAR BRILLO MIN/MAX
    float brilloMin = 99999;
    float brilloMax = 0;
    for (int i=0; i < area.pixels.length; i++) {
      float brillo = brightness(area.pixels[i]); 
      brilloMin = brillo < brilloMin ? brillo : brilloMin;
      brilloMax = brillo > brilloMax ? brillo : brilloMax;
    }

    // SETEAR EL UMBRAL EN EL MEDIO DE LOS EXTREMOS ACTUALES
    int correccion = 50;
    umbral = int((brilloMin + brilloMax) * 0.5) - correccion;
    println("-|| UMBRAL: " + umbral);
  }


  public void setKernelSize(int kernelSize) {
    kernelAreaSize = kernelSize;
  }

  public void setUmbral(float normValue) {
    umbral = (int)(normValue * 255);
    //println(umbral);
  }

  public void enableAdaptiveBinarization(boolean state) {
    enableAdaptiveBinarization = state;
    if (state)adaptiveBinarizationTimer.start();
    //println("AdaptiveBinarization = " + state);
  }


  private boolean pixelIsInsideBounds(int x, int y) {
    return x >= 0 && x < camImage.width && y >= 0 && y < camImage.height;
  }

  public void loadSettings(SettingsLoader config) {
    try {
      setUmbral(config.loadCvThreshold());
      kernelAreaSize = config.loadCvKernelSize();
      enableAdaptiveBinarization = config.loadAdaptiveBinarization();
    } 
    catch (Exception error) {
      println(error);
    }
  }
}
