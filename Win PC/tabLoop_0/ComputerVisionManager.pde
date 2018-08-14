import processing.video.*;
import gab.opencv.*;

class ComputerVisionManager {


  Capture videoIn;
  OpenCV opencv;

  PImage camImage;
  PVector imageScreenPos;
  int umbral;
  int areaSize;

  public ComputerVisionManager(PApplet p5) {

    videoIn = new Capture(p5, 1280, 720);
    videoIn.start();

    opencv = new OpenCV(p5, videoIn);


    camImage = loadImage("camView.png");
    imageScreenPos = new PVector(0, 0);
    umbral = 127;

    areaSize = 9; // IMPARES, ASI EXISTE UN PIXEL CENTRAL
  }

  public void update() {

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
    //image(camImage, imageScreenPos.x, imageScreenPos.y);
    image(camImage, 0, 0, camImage.width * 0.5, camImage.height * 0.5);

    // DIBUJAR CONTORNO DE LA IMAGEN
    noFill();
    stroke(255, 0, 0);
    rect(0, 0, camImage.width * 0.5, camImage.height * 0.5);
  }


  boolean isOn(float x, float y) {
    // x & y SHOULD ENTER NORMALIZED

    int imageX = (int)(x * camImage.width);
    int imageY = (int)(y * camImage.height);

    int pxBrightness = -1;

    if (areaSize == 1) {
      //println("Kernel = " + areaSize);
      int pxSlot = imageX + (imageY * camImage.width);
      pxBrightness = camImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL
    } else {
      //println("Kernel = " + areaSize);
      pxBrightness = evaluateArea(imageX, imageY, areaSize);
    }

    return pxBrightness > umbral;
  }

  // #### BUG: ERROR CUANDO UN PIXEL POINT ESTA EN EL BORDE DEL boundiNgBox
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


  public void setKernelSize(int kernelSize) {
    areaSize = kernelSize;
  }

  public void setUmbral(float normValue) {
    umbral = (int)(normValue * 255);
    //println(umbral);
  }


  private boolean pixelIsInsideBounds(int x, int y) {
    return x >= 0 && x < camImage.width && y >= 0 && y < camImage.height;
  }

  public void loadSettings(SettingsLoader config) {
    try {
      umbral = config.loadCvThreshold();
      areaSize = config.loadCvKernelSize();
    } 
    catch (Exception error) {
      println(error);
    }
  }
}
