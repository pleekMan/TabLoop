class ComputerVisionManager {

  PImage camImage;
  PVector imageScreenPos;

  public ComputerVisionManager() {

    camImage = loadImage("BWgrid.png");

    imageScreenPos = new PVector();
  }

  public void render() {
    image(camImage, imageScreenPos.x, imageScreenPos.y);
  }


  boolean isOn(float x, float y) {
    // x & y SHOULD ENTER NORMALIZED

    int imageX = (int)(x * camImage.width);
    int imageY = (int)(y * camImage.height);

    int pxSlot = imageX + (imageY * camImage.width);

    float pxBrightness = brightness(camImage.pixels[pxSlot]);

    if (pxBrightness > 127) {
      return true;
    }
    return false;
  }
}
