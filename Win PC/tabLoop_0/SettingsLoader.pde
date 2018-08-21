class SettingsLoader { //<>// //<>//

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

  public float loadCvThreshold() {
    return config.getChild("computerVision/binaryThreshold").getFloat("value");
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

  public PVector[][] loadPointOffset(int tracks, int beats) {

    PVector [][] offsets = new PVector[tracks][beats];
    XML offsetTag = config.getChild("grid/pointsOffset");
    XML[] tagChildren = offsetTag.getChildren("point");
    
    println("tagChildren.length: " + tagChildren.length);


    for (int track=0; track < offsets.length; track++) {
      for (int beat=0; beat < offsets[0].length; beat++) {
        int index = beat + (track * beats);
        println("Index: " + index);
        println(tagChildren[index].getInt("id"));

        //NON-EXISTING POINTS IN XML ARE INIT AS 0,0
        if (index < tagChildren.length) {
          float x = tagChildren[index].getFloat("x");
          float y = tagChildren[index].getFloat("y");
          offsets[track][beat] = new PVector(x, y);
        } else {
          offsets[track][beat] = new PVector(0, 0);
        }
      }
    }

    return offsets;
  }

  public void savePointsOffset(PVector[][] pointsOffset) {

    XML offsetTag = config.getChild("grid/pointsOffset");

    // CLEAR ALL CHILDS
    offsetTag.setContent("");

    for (int track=0; track < pointsOffset.length; track++) {
      for (int beat=0; beat < pointsOffset[0].length; beat++) {
        int index = beat + (track * pointsOffset[0].length);
        XML newChild = offsetTag.addChild("point");
        newChild.setInt("id", index);
        newChild.setFloat("x", pointsOffset[track][beat].x);
        newChild.setFloat("y", pointsOffset[track][beat].y);
      }
    }
  }

  public void guardar() {
    saveXML(config, "data/configuracion.xml");
  }
}