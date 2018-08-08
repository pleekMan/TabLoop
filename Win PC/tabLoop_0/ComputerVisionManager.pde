class ComputerVisionManager {

  PImage camImage;
  PVector imageScreenPos;
  int umbral;

  public ComputerVisionManager() {

    camImage = loadImage("BWgrid.png");
    imageScreenPos = new PVector();
    umbral = 127;
  }

  public void render() {
    image(camImage, imageScreenPos.x, imageScreenPos.y);
  }


  boolean isOn(float x, float y) {
    // x & y SHOULD ENTER NORMALIZED

    int imageX = (int)(x * camImage.width);
    int imageY = (int)(y * camImage.height);

    int pxSlot = imageX + (imageY * camImage.width);

    //float pxBrightness = brightness(camImage.pixels[pxSlot]); // NO USAR ESTA FUNCION, HACERLO CON BITWISE OPERATION
    int pxBrightness = camImage.pixels[pxSlot] & 0xFF; // SOBRE EL CANAL AZUL
    
    if (pxBrightness > umbral) {
      return true;
    }
    return false;
  }
}
