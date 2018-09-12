import ddf.minim.*;

class SoundManager {

  Minim minim;

  int atBeat, previousBeat;
  boolean enableTriggering = false;

  ArrayList<AudioSample> sounds;
  float[] volumes;
  ArrayList<String> soundsFileName;
  int[] channelToSound; // CHANNEL MAPPINGS (LINK sounds LIST TO CHANNELS)


  public SoundManager(PApplet p5) {

    // soundsFolder SHOULD BE RELATIVE TO data folder
    minim = new Minim(p5);

    atBeat = 1;
    previousBeat = 0;

    sounds = new ArrayList<AudioSample>();

    soundsFileName = new ArrayList<String>();

    channelToSound = new int[sounds.size()];
  }

  public void update() {

    // PARA SOLO TRIGGEREAR 1 VEZ CUANDO CAMBIA EL BEAT
    if (atBeat != previousBeat) {
      previousBeat = atBeat;
      enableTriggering = true;
    } else {
      enableTriggering = false;
    }
  }

  public void triggerSound(int track) {

    if (enableTriggering) {
      if (track < sounds.size()) { // TEMP, POR SI SE CARGARON MENOS sounds QUE tracks EXISTENTES
        //if (track == 0) { // TESTING
        getSoundAtTrack(track).trigger();
        //}
      }
    }
  }

  private AudioSample getSoundAtTrack(int track) {
    return sounds.get(channelToSound[track]);
  }

  public void reportBeat(int beat) {
    atBeat = beat;
  }

  //
  /*
  private void loadSounds(String folder, PApplet p5) {
   //println(folder);
   
   String finalPath = dataPath("") + "/" + folder +"/";
   String[] fileNames = listFileNames(finalPath);
   
   for (int i=0; i < fileNames.length; i++) {
   //println("-|| FilePath: " + finalPath + fileNames[i]);
   SoundFile newSound = new SoundFile(p5, finalPath + fileNames[i]);
   newSound.amp(0.2);
   sounds.add(newSound);
   
   soundsFileName.add(fileNames[i]);
   }
   }
   */

  private void loadSounds(String folder, String[] fileNames, float[] _volumes, PApplet p5) {
    //println(folder);

    volumes =_volumes;

    //String finalPath = dataPath("") + "/" + folder +"/"; // MAC OS
    String finalPath = dataPath("") + "\\" + folder +"\\"; // WINDOWS OS
    //String[] fileNames = listFileNames(finalPath);

    for (int i=0; i < fileNames.length; i++) {
      println("-|| OPENING > FilePath: " + finalPath + fileNames[i]);
      AudioSample newSound = minim.loadSample(finalPath + fileNames[i]);
      newSound.setGain(volumes[i]);
      sounds.add(newSound);

      soundsFileName.add(fileNames[i]);
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
          if (str.equals(".aif") || str.equals(".aiff") || str.equals(".wav") || str.equals(".mp3")) {
            return true;
          }
        }      
        return false;
      }
    };
    // END OF FileNameFilter DEFINITION

    return folder.list(fileNameFilter);
  }

  public void loadSettings(SettingsLoader config, String soundFolder, PApplet p5) {
    // ESTA FUNCION ES MEDIO QUILOMBO PORQUE SoundFile INICIALIZA CON un PApplet(this).
    int[] ca = config.loadSoundChannelAssignments();
    if (ca.length != 0)channelToSound = ca;

    // NEED TO CODE A DEFAULT TO CATCH ERROR ON FILENAME LOADING
    String[] fNames = config.loadSoundFileNames();
    float[] fileVolumes = config.loadSoundVolumes();
    //printArray(fileVolumes);

    loadSounds(soundFolder, fNames, fileVolumes, p5);

    //printChannelMappings();

    /*
    println("-||");
     println("-|| SOUND FILE NAMES:");
     printArray(fNames);
     */
  }

  public int[] getChannelAssignment() {
    return channelToSound;
  }

  public float[] getChannelVolumes() {
    return volumes;
  }

  public String[] getFileNamesOrdered() {
    // ALWAYS RETURN FILENAMES ORDERED BY TRACK/CHANNEL
    String[] orderedFileNames = new String[channelToSound.length];
    for (int i=0; i < channelToSound.length; i++) {
      orderedFileNames[i] = soundsFileName.get(channelToSound[i]);
    }
    return orderedFileNames;
    //String[] fNames = new String[soundsFileName.size()];
    //fNames = soundsFileName.toArray(fNames);
    //return fNames;
  }

  public void printChannelMappings() {
    for (int i=0; i < channelToSound.length; i++) {
      println("-|| Channel |" + i +"| => \t (" + channelToSound[i] + ") :: " + soundsFileName.get(channelToSound[i]));
    }
  }

  public void onKeyPressed(char k) {

    // SWAP CHANNELS
    /*
    if (k == 'c') {
     channelToSound[0] = 2;
     channelToSound[2] = 0;
     printChannelMappings();
     }
     */
  }
}
