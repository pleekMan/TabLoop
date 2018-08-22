import processing.sound.*;

class SoundManager {

  int atBeat, previousBeat;
  boolean enableTriggering = false;

  //SoundFile[] bombo, redo, HH, openHH, FX;
  
  ArrayList<SoundFile> sounds;

  //String pathBombos, pathRedos, pathHHs, pathOpenHHs, pathFXs;
  //String[] filenamesBombos, filenamesRedos, filenamesHHs, filenamesOpenHHs, filenamesFXs;

  public SoundManager(PApplet p5) {

    atBeat = 1;
    previousBeat = 0;
    
    
    /*
    pathBombos = sketchPath()+"/data/samples/bombos";
    pathRedos = sketchPath()+"/data/samples/redos";
    pathHHs = sketchPath()+"/data/samples/HHs";
    pathOpenHHs = sketchPath()+"/data/samples/openHHs";
    pathFXs = sketchPath()+"/data/samples/FXs";

    filenamesBombos = listFileNames(pathBombos);

    bombo = new SoundFile[filenamesBombos.length];
    for (int i=0; i < filenamesBombos.length; i++) {
      bombo[i] = new SoundFile(p5, pathBombos+"/"+filenamesBombos[i]);
    }

    filenamesRedos = listFileNames(pathRedos);
    redo = new SoundFile[filenamesRedos.length];
    for (int i=0; i < filenamesRedos.length; i++) {
      redo[i] = new SoundFile(p5, pathRedos+"/"+filenamesRedos[i]);
    }

    filenamesHHs = listFileNames(pathHHs);
    HH = new SoundFile[filenamesHHs.length];
    for (int i=0; i < filenamesHHs.length; i++) {
      HH[i] = new SoundFile(p5, pathHHs+"/"+filenamesHHs[i]);
    }

    filenamesOpenHHs = listFileNames(pathOpenHHs);
    openHH = new SoundFile[filenamesOpenHHs.length];
    for (int i=0; i < filenamesOpenHHs.length; i++) {
      openHH[i] = new SoundFile(p5, pathOpenHHs+"/"+filenamesOpenHHs[i]);
    }

    filenamesFXs = listFileNames(pathFXs);
    FX = new SoundFile[filenamesFXs.length];
    for (int i=0; i < filenamesFXs.length; i++) {
      FX[i] = new SoundFile(p5, pathFXs+"/"+filenamesFXs[i]);
    }
    */
  }

  public void update() {
    
    // PARA SOLO TRIGGEAR 1 VEZ CUANDO CAMBIA EL BEAT
    if (atBeat != previousBeat) {
      previousBeat = atBeat;
      enableTriggering = true;
    } else {
      enableTriggering = false;
    }
  }

  public void triggerSound(int track) {
    if (enableTriggering) {
      if (track == 0) {
        bombo[1].play();
      }
    }
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

  public void reportBeat(int beat) {
    atBeat = beat;
  }


  public void onKeyPressed(char _k) {
    
    /*
    char k = _k;
    int j;

    if (k == '1') {
      j =int(random(bombo.length));
      bombo[j].play();
    }

    if (k == '2') {
      j =int(random(redo.length));
      redo[j].play();
    }

    if (k == '3') {
      j =int(random(HH.length));
      HH[j].play();
    }

    if (k == '4') {
      j =int(random(openHH.length));
      openHH[j].play();
    }

    if (k == '5') {
      j =int(random(FX.length));
      FX[j].play();
    }
  }
  */
}
