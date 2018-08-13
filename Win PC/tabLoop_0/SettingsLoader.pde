class SettingsLoader {

  XML config;

  public SettingsLoader(String filePath) {

    config = loadXML(filePath);

    //XML[] boundingBox = config.getChildren("grid/boundingBox/corner");
    //printArray(boundingBox.listChildren());
    //printArray(boundingBox);
  }

  public boolean isLoaded() {
    return config != null;
  }

  public PVector[] loadBoundingBox() {
    PVector[] boxCorners = new PVector[2];
    XML[] savedBoundingBox = config.getChildren("grid/boundingBox/corner");
    boxCorners[0] = new PVector(savedBoundingBox[0].getFloat("x"), savedBoundingBox[0].getFloat("y"), 0);
    boxCorners[1] = new PVector(savedBoundingBox[1].getFloat("x"), savedBoundingBox[1].getFloat("y"), 0);
    return boxCorners;
  }

  public void saveBoundingBox(PVector[] boxCorners) {
    XML[] savedBoundingBox = config.getChildren("grid/boundingBox/corner");
    savedBoundingBox[0].setInt("x", (int)boxCorners[0].x);
    savedBoundingBox[0].setInt("y", (int)boxCorners[0].y);
    savedBoundingBox[1].setInt("x", (int)boxCorners[1].x);
    savedBoundingBox[1].setInt("y", (int)boxCorners[1].y);
  }

  public PVector[] loadCornerPoints() {
    PVector[] cornerPoints = new PVector[4];
    XML[] savedCornerPoints = config.getChildren("grid/controlCorners/point");

    for (int i=0; i < cornerPoints.length; i++) {
      cornerPoints[i] = new PVector(savedCornerPoints[i].getFloat("x"), savedCornerPoints[i].getFloat("y"), 0);
    }
    return cornerPoints;
  }

  public void saveCornerPoints(PVector[] cornerPoints) {

    XML[] savedCornerPoints = config.getChildren("grid/controlCorners/point");

    for (int i=0; i < cornerPoints.length; i++) {
      savedCornerPoints[i].setFloat("x", cornerPoints[i].x);
      savedCornerPoints[i].setFloat("y", cornerPoints[i].y);
    }
  }

  public float loadPerspectiveCorrection() {
    //println(" LOADER " + config.getChild("grid/perspectiveCorrection").getFloat("value"));
    return config.getChild("grid/perspectiveCorrection").getFloat("value");
  }

  public void savePerspectiveCorrection(float value) {
    config.getChild("grid/perspectiveCorrection").setFloat("value", value);
  }

  public int loadCvThreshold() {
    return int(config.getChild("computerVision/binaryThreshold").getFloat("value") * 255);
  }

  public void saveCvThreshold(int value) {
    config.getChild("computerVision/binaryThreshold").setFloat("value", (float)value / 255);
  }

  public int loadCvKernelSize() {
    return int(config.getChild("computerVision/kernelSize").getInt("value"));
  }
  
    public void saveCvKernelSize(int value) {
    config.getChild("computerVision/kernelSize").setInt("value", value);
  }

  public void guardar() {
    saveXML(config, "data/configuracion.xml");
  }
}
