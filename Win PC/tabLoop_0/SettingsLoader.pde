class SettingsLoader {

  String filePath;
  XML config;

  public SettingsLoader(String filePath) {

    config = loadXML(filePath);

    //XML[] boundingBox = config.getChildren("grid/boundingBox/corner");
    //printArray(boundingBox.listChildren());
    //printArray(boundingBox);
  }

  public PVector[] getBoundingBox() {
    PVector[] boxCorners = new PVector[2];
    XML[] savedBoundingBox = config.getChildren("grid/boundingBox/corner");
    boxCorners[0] = new PVector(savedBoundingBox[0].getFloat("x"), savedBoundingBox[0].getFloat("y"), 0);
    boxCorners[1] = new PVector(savedBoundingBox[1].getFloat("x"), savedBoundingBox[1].getFloat("y"), 0);
    return boxCorners;
  }

  public PVector[] getCornerPoints() {
    PVector[] cornerPoints = new PVector[4];
    XML[] savedCornerPoints = config.getChildren("grid/controlCorners/point");

    for (int i=0; i < cornerPoints.length; i++) {
      cornerPoints[i] = new PVector(savedCornerPoints[i].getFloat("x"), savedCornerPoints[i].getFloat("y"), 0);
    }
    return cornerPoints;
  }

  public float getPerspectiveCorrection() {
    return config.getChild("grid/perspectiveCorrection").getFloat("value");
  }

  public int getCvThreshold() {
    return int(config.getChild("computerVision/binaryThreshold").getFloat("value") * 255);
  }

  public int getCvKernelSize() {
    return int(config.getChild("computerVision/kernelSize").getInt("value"));
  }
}
