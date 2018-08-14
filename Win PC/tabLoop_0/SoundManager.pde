class SoundManager {

  SoundFile[] bombo;
  SoundFile[] redo;
  SoundFile[] HH;
  SoundFile[] openHH;
  SoundFile[] FX;

  String pathBombos, pathRedos, pathHHs, pathOpenHHs, pathFXs;


  public SoundManager() {

    pathBombos = sketchPath()+"/data/samples/bombos";
    pathRedos = sketchPath()+"/data/samples/redos";
    pathHHs = sketchPath()+"/data/samples/HHs";
    pathOpenHHs = sketchPath()+"/data/samples/openHHs";
    pathFXs = sketchPath()+"/data/samples/FXs";


    bombo = new SoundFile[2];

    for (int i=0; i < 2; i++) {
      bombo[i] = new SoundFile(this, "sample.mp3");
      redo[i] = new SoundFile[3];
      HH[i] = new SoundFile[3];
      openHH[i] = new SoundFile[3];
      FX[i] = new SoundFile[3];
    }
  }

  public void update() {
  }

  public void triggerSound(int track) {
  }

  private String[] listFileNames(String dir) {
    File file = new File(dir);
    if (file.isDirectory()) {
      String names[] = file.list();
      return names;
    } else {
      // If it's not a directory
      return null;
    }
  }
}
