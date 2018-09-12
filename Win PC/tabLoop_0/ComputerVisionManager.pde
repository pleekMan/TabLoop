import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

class ComputerVisionManager {

  PApplet p5;

  Capture videoIn;
  OpenCV opencv;

  PImage binaryImage;
  PImage contrastBrightnessImage;
  PVector imageScreenPos;
  int umbral;
  int brillo;
  float contraste;
  int dilatePasses;
  int erodePasses;
  int kernelAreaSize;
  boolean kernelModeAverage = false; // AVERAGE: RETURNS AVERAGE BRIGHTNESS IN KERNEL. !AVERAGE: RETURNS (TRUE) WHEN AT LEAST 1 BRIGHT PX IS DETECTED

  boolean enableAdaptiveBinarization;
  PVector contrastBoxCenter;
  int contrastBoxSize;
  //Timer adaptiveBinarizationTimer;  

  boolean isCamImageMinimized = false;


  public ComputerVisionManager(PApplet _p5) {
    p5 = _p5;

    String[] cameras = Capture.list();
    //videoIn = new Capture(p5, 1280, 960); // RESOLUCION NATIVA DE Logitech C270
    //videoIn = new Capture(p5, 640, 480); // DEFAULT CAMERA
    videoIn = new Capture(p5, 1280, 960, cameras[61]); // WORKING WEB-CAM ON LAPTOP

    videoIn.start();

    opencv = new OpenCV(p5, videoIn);


    //binaryImage = loadImage("camView.png");
    binaryImage = createImage(videoIn.width, videoIn.height, RGB);
    contrastBrightnessImage = createImage(videoIn.width, videoIn.height, RGB);

    imageScreenPos = new PVector(0, 0);
    umbral = 127;
    brillo = 0; // -255 -> 255
    contraste = 0.5; // 0.0 -> 1.0
    dilatePasses = 0; // 0 -> 5 INT
    erodePasses = 0; // 0 -> 5 INT

    kernelAreaSize = 9; // IMPARES, ASI EXISTE UN PIXEL CENTRAL

    enableAdaptiveBinarization = false;
    contrastBoxCenter = new PVector(videoIn.width * 0.5, videoIn.height * 0.5);
    contrastBoxSize = int(videoIn.width * 0.25);


    //adaptiveBinarizationTimer = new Timer();
    //adaptiveBinarizationTimer.setDurationInSeconds(10);
    //if (enableAdaptiveBinarization)adaptiveBinarizationTimer.start();
  }
  public void update() {

    //-- CADA TANTO, EJECUTAR PROCESO DE CONTRASTE ADAPTATIVO
    /*
    if (enableAdaptiveBinarization) {
     if (adaptiveBinarizationTimer.isFinished()) {
     adaptContrast(tabla.getGridPoints()); // ESTO SE PUEDE LLAMAR ASI, SOLO PORQ ESTAMOS EN PROCESSING IDE
     adaptiveBinarizationTimer.start();
     controles.getController("umbralCV").setValue(cvManager.umbral / 255.0);  // ESTO SE PUEDE LLAMAR ASI SOLO PORQ ESTAMOS EN PROCESSING IDE
     }
     }
     */
    //----

    // OPENCV MANIPULATION --- 
    if (videoIn.available()) {
      videoIn.read();
      opencv.loadImage(videoIn);
    }

    opencv.gray();

    opencv.brightness(brillo);
    opencv.contrast(contraste);
    //contrastBrightnessImage = opencv.getOutput().copy();

    opencv.threshold(umbral);
    opencv.invert();

    for (int i=0; i < dilatePasses; i++) {
      opencv.dilate();
    }
    for (int i=0; i < erodePasses; i++) {
      opencv.erode();
    }

    binaryImage = opencv.getOutput();

    // END OPENCV MANIPULATION ---
  }


  public void render() {

    PVector rawImagePos = new PVector();
    PVector binaryImagePos = new PVector();
    float binaryImageScale = 0.5; //0.5 // IMAGEN OPERADA
    float rawImageScale = 0.25; //0.25 // IMAGEN DE ENTRADA

    if (!isCamImageMinimized) {
      // MODO DEBUG
      rawImageScale = 0.25;
      binaryImageScale = 0.5;
      binaryImagePos.set(0, 0);
      rawImagePos.set(binaryImagePos.x + (binaryImage.width * binaryImageScale), 0);
    } else {
      // MODO PERFORMANCE
      rawImageScale = 0.1;
      binaryImageScale = 0.1;
      rawImagePos.set(width - (videoIn.width * rawImageScale), 0);
      binaryImagePos.set(rawImagePos.x - (binaryImage.width * binaryImageScale), 0);
    }



    // IMAGEN DE ENTRADA (escala2)
    image(videoIn, rawImagePos.x, rawImagePos.y, videoIn.width * rawImageScale, videoIn.height * rawImageScale);

    // IMAGEN OPERADA (escala1)
    image(binaryImage, binaryImagePos.x, binaryImagePos.y, binaryImage.width * binaryImageScale, binaryImage.height * binaryImageScale);

    // BRILLO / CONTRASTE
    //image(contrastBrightnessImage, rawImagePos.x, rawImagePos.y + (videoIn.height * rawImageScale), videoIn.width * rawImageScale, videoIn.height * rawImageScale);


    // DIBUJAR CONTORNO DE LA IMAGEN
    noFill();
    stroke(255, 0, 0);
    rect(binaryImagePos.x, binaryImagePos.y, binaryImage.width *binaryImageScale, binaryImage.height * binaryImageScale);

    // DIBUJAR AREA DE CONTRASTE ADAPTATIVO (SOBRE IMAGEN DE ENTRADA)
    stroke(0, 0, 255);
    float posX = rawImagePos.x + ((contrastBoxCenter.x - (contrastBoxSize * 0.5)) * rawImageScale);
    float posY = (contrastBoxCenter.y - (contrastBoxSize * 0.5)) * rawImageScale;
    rect(posX, posY, contrastBoxSize * rawImageScale, contrastBoxSize * rawImageScale);

    fill(255, 0, 0);
    ellipse( rawImagePos.x + contrastBoxCenter.x * rawImageScale, contrastBoxCenter.y * rawImageScale, 5, 5);
    noFill();
    //---
  }


  boolean isOn(float x, float y) {
    // x & y SHOULD ENTER NORMALIZED

    //println(x + " \t\t " + y);

    int imageX = (int)(x * binaryImage.width);
    int imageY = (int)(y * binaryImage.height);

    int pxBrightness = -1;

    if (kernelAreaSize == 1) {
      if (pixelIsInsideBounds(imageX, imageY)) {
        int pxSlot = imageX + (imageY * binaryImage.width);
        pxBrightness = binaryImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL
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
          int pxSlot = pixelX + (pixelY * binaryImage.width);
          brilloAcumulativo += binaryImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL

          // KERNEL MODE TO FIND AT LEAST 1 ACTIVE PIXEL
          if (!kernelModeAverage) {
            if (brilloAcumulativo > 0) {
              return 255;
            }
          }
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

  public void setKernelModeAverage(boolean state) {
    // TRUE: AVERAGE, FALSE: AT LEAST 1 POINT
    kernelModeAverage = state;
  }

  public void setUmbral(float normValue) {
    umbral = (int)(normValue * 255);
    //println(umbral);
  }

  public void setBrillo(float value) {
    brillo = int(value * 255);
  }

  public void setContraste(float value) {
    contraste = value;
  }

  public void setDilatePasses(int passes) {
    dilatePasses = passes;
  }
  public void setErodePasses(int passes) {
    erodePasses = passes;
  }

  /*
  public void enableAdaptiveBinarization(boolean state) {
   enableAdaptiveBinarization = state;
   if (state)adaptiveBinarizationTimer.start();
   //println("AdaptiveBinarization = " + state);
   }
   */


  private boolean pixelIsInsideBounds(int x, int y) {
    return x >= 0 && x < binaryImage.width && y >= 0 && y < binaryImage.height;
  }

  public void setImageMinimized(boolean state) {
    isCamImageMinimized = state;
  }

  public void loadSettings(SettingsLoader config) {

    setUmbral(config.loadCvThreshold());
    kernelAreaSize = config.loadCvKernelSize();
    //println(config.loadKernelMode());
    kernelModeAverage = config.loadKernelMode() > 0 ? true : false;
    enableAdaptiveBinarization = config.loadAdaptiveBinarization();
    brillo = config.loadCvBrightness();
    contraste = config.loadCvContrast();
    dilatePasses = config.loadCvDilate();
    erodePasses = config.loadCvErode();
  }

  public void onKeyPressed(char _key) {
    if (_key == 'k') {
      kernelModeAverage = !kernelModeAverage;
    }
  }
}
