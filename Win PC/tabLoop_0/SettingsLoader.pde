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
    //println(" LOADER " + config.getChild("grid/perspectiveCorrection").getFloat("vadfsgvdfglueg"));
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

  public int loadCvBrightness() {
    return int(config.getChild("computerVision/brightness").getFloat("value") * 255);
  }

  public void saveCvBrightness(float value) {
    config.getChild("computerVision/brightness").setFloat("value", value / 255.0);
  }

  public float loadCvContrast() {
    return config.getChild("computerVision/contrast").getFloat("value");
  }

  public void saveCvContrast(float value) {
    config.getChild("computerVision/contrast").setFloat("value", value);
  }

  public int loadCvDilate() {
    return config.getChild("computerVision/dilatePasses").getInt("value");
  }

  public void saveCvDilate(int value) {
    config.getChild("computerVision/dilatePasses").setInt("value", value);
  }
  
  public int loadCvErode() {
    return config.getChild("computerVision/erodePasses").getInt("value");
  }
  
  public void saveCvErode(int value) {
    config.getChild("computerVision/erodePasses").setInt("value", value);
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

    //println("tagChildren.length: " + tagChildren.length);


    for (int track=0; track < offsets.length; track++) {
      for (int beat=0; beat < offsets[0].length; beat++) {
        int index = beat + (track * beats);
        //println("Index: " + index);
        //println(tagChildren[index].getInt("id"));

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

  public void saveKernelMode(boolean state) {
    XML kernelTag = config.getChild("computerVision/kernelMode");
    kernelTag.setContent("");
    kernelTag.setInt("value", int(state));
  }

  public int loadKernelMode() {
    return int(config.getChild("computerVision/kernelMode").getInt("value"));
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

  public void saveStepwiseOffsets(float[] stepOffsets) {
    XML offsetTag = config.getChild("grid/stepwiseOffset");
    offsetTag.setContent("");


    for (int i=0; i < stepOffsets.length; i++) {
      XML newChild = offsetTag.addChild("point");
      newChild.setFloat("offset", stepOffsets[i]);
    }
  }

  public float[] loadStepwiseOffsets() {
    XML offsetTag = config.getChild("grid/stepwiseOffset");
    XML[] tagChildren = offsetTag.getChildren("point");

    float [] stepOffsets = new float[tagChildren.length];

    for (int i=0; i < stepOffsets.length; i++) {
      stepOffsets[i] = tagChildren[i].getFloat("offset");
    }
    return stepOffsets;
  }

  public void saveAdaptiveBinarization(boolean state) {
    config.getChild("computerVision/enableAdaptiveBinarization").setInt("value", state ? 1 : 0);
  }

  public boolean loadAdaptiveBinarization() {
    return config.getChild("computerVision/enableAdaptiveBinarization").getInt("value") > 0.5 ? true : false;
  }

  public void saveSoundChannelFiles(String[] fileNames) {
    // BECAUSE THE fileNames ARE RECIEVED ALREADY ORDERED BY THE CHANNELS THEY BELONG TO,
    // THE channelsToSound MAPPINGS DO NOT NEED TO BE SAVED (IT' THE SAME AS i)
    XML channelsTag = config.getChild("sound/channels");

    // CLEAR ALL CHILDS
    channelsTag.setContent("");

    for (int i=0; i < fileNames.length; i++) {
      XML newChannel = channelsTag.addChild("channel");
      newChannel.setInt("id", i);
      newChannel.setString("fileName", fileNames[i]);
      //newChannel.setInt("channel", channels[i]);
      newChannel.setInt("channel", i);
    }
  }

  public int[] loadSoundChannelAssignments() {
    XML channelTag = config.getChild("sound/channels");
    XML[] channelsInTag = channelTag.getChildren("channel");

    int[] assignments = new int[channelsInTag.length];

    for (int i=0; i < channelsInTag.length; i++) {
      assignments[i] = channelsInTag[i].getInt("channel");
    }
    return assignments;
  }

  public String[] loadSoundFileNames() {
    XML channelTag = config.getChild("sound/channels");
    XML[] channelsInTag = channelTag.getChildren("channel");

    String[] fileName = new String[channelsInTag.length];

    for (int i=0; i < channelsInTag.length; i++) {
      fileName[i] = channelsInTag[i].getString("fileName");
      //println("-|| Sound FileName from XML" + fileName[i]);
    }
    return fileName;
  }

  public void saveSoundVolumes(float[] volumes) {
    XML soundTag = config.getChild("sound/channels");
    //soundTag.setContent("");

    for (int i=0; i < volumes.length; i++) {
      XML newChild = soundTag.getChild(i);
      newChild.setFloat("volume", volumes[i]);
    }
  }

  public float[] loadSoundVolumes() {
    XML soundTag = config.getChild("sound/channels");
    XML[] tagChildren = soundTag.getChildren("channel");

    float [] soundVolumes = new float[tagChildren.length];

    for (int i=0; i < soundVolumes.length; i++) {
      soundVolumes[i] = tagChildren[i].getFloat("volume");
    }
    return soundVolumes;
  }

  public void saveTempo(int tempo) {
    config.getChild("grid/tempo").setInt("value", tempo);
  }

  public int getTempo() {
    return config.getChild("grid/tempo").getInt("value");
  }


  public void guardar() {
    saveXML(config, "data/configuracion.xml");
  }
}
