class ComputerVisionManager { //<>//

  PImage camImage;
  PVector imageScreenPos;
  int umbral;
  int areaSize;

  public ComputerVisionManager() {

    camImage = loadImage("camView.png");
    imageScreenPos = new PVector();
    umbral = 127;

    areaSize = 9; // IMPARES, ASI EXISTE UN PIXEL CENTRAL
  }

  public void render() {
    image(camImage, imageScreenPos.x, imageScreenPos.y);
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
      println("Kernel = " + areaSize);
      pxBrightness = evaluateArea(imageX, imageY, areaSize);
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


  public void setKernelSize(int kernelSize) {
    areaSize = kernelSize;
  }


  private boolean pixelIsInsideBounds(int x, int y) {
    return x >= 0 && x < camImage.width && y >= 0 && y < camImage.height;
  }
}
