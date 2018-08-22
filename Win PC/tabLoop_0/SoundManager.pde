import processing.sound.*;

class SoundManager {

  int atBeat, previousBeat;
  boolean enableTriggering = false;

  //SoundFile[] bombo, redo, HH, openHH, FX;

  ArrayList<SoundFile> sounds;

  //String pathBombos, pathRedos, pathHHs, pathOpenHHs, pathFXs;
  //String[] filenamesBombos, filenamesRedos, filenamesHHs, filenamesOpenHHs, filenamesFXs;

  public SoundManager(PApplet p5, String soundsFolder) {

    // soundsFolder SHOULD BE RELATIVE TO data folder

    atBeat = 1;
    previousBeat = 0;

    sounds = new ArrayList<SoundFile>();

    loadSounds(soundsFolder, p5);

    /*
    pathBombos = sketchPath()+"/data/samples/bombos";
     
     filenamesBombos = listFileNames(pathBombos);
     bombo = new SoundFile[filenamesBombos.length];
     for (int i=0; i < filenamesBombos.length; i++) {
     bombo[i] = new SoundFile(p5, pathBombos+"/"+filenamesBombos[i]);
     }
     */
  }

  private void loadSounds(String folder, PApplet p5) {
    println(folder);
    String finalPath = dataPath("") + "/" + folder +"/";
    String[] fileNames = listFileNames(finalPath);

    for (int i=0; i < fileNames.length; i++) {
      println("-|| FilePath: " + finalPath + fileNames[i]);
      SoundFile newSound = new SoundFile(p5, finalPath + fileNames[i]);
      sounds.add(newSound);
    }
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
        sounds.get(0).play();
      }
    }
  }



  private String[] listFileNames(String dir) {
    println("-|| Sound Files Folder: " + dir);

    File folder = new File(dir);

    // CREAMOS UN FILTRO PARA ACEPTAR SOLO wav, aif y mp3
    // SIRVE PARA EVITAR CARGAR ARCHIVOS OCULTOS TAMBIEN (COMO EL ".DS_store" de MacOS)

    // FileNameFilter DEFINES A FILTER INSITU
    FilenameFilter fileNameFilter = new FilenameFilter() {
      @Override
        public boolean accept(File dir, String name) {
        if (name.lastIndexOf('.')>0) {

          // get last index for '.' char
          int lastIndex = name.lastIndexOf('.');

          // get extension
          String str = name.substring(lastIndex);

          // match path name extension
          if (str.equals(".aif") || str.equals(".wav") || str.equals(".mp3")) {
            return true;
          }
        }      
        return false;
      }
    };
    // END OF FileNameFilter DEFINITION

    return folder.list(fileNameFilter);
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
}
