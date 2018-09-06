public class TempoManager {

  float bpm;
  float beatDivision;
  Timer timer;
  boolean onBeat;

  boolean onTapTempoMode = false;
  boolean tapped = false;
  long lastTapTime = 0;
  long tapDifference = 0;

  // VIZ
  PVector beatMarkerPos;
  float beatMarkerSize;
  color beatMarkerColor;
  float beatMarkerOpacity = 1;

  public TempoManager() {
    //p5 = getP5();

    timer = new Timer();

    beatDivision = 4; // 1 = ON QUARTER NOTE (NEGRA) -> LO NORMAL
    setBPM(60);
    onBeat = false;

    beatMarkerPos = new PVector(758, 596);
    beatMarkerSize = 40;

    beatMarkerColor = colorPalette.HIGHLIGHT_GREEN;
  }

  public void update() {

    // TAP TEMPO MODE - BEGIN
    if (tapped) {
      if (!onTapTempoMode) {
        onTapTempoMode = true;
        lastTapTime = System.currentTimeMillis();
      } else {
        tapDifference = System.currentTimeMillis() - lastTapTime;
        lastTapTime = System.currentTimeMillis();
        //p5.println("-|| TAP DIFF: " + tapDifference);
        setBpmFromMillis((int) tapDifference);
      }

      tapped = false;
    }
    // IF MORE THAN 5 SECONDS WENT BY, EXIT onTapTempoMode
    if (onTapTempoMode && (System.currentTimeMillis() - lastTapTime) > 5000) {
      onTapTempoMode = false;
      //p5.println("-|| EXITING TAP TEMPO MODE");
    }

    // TAP TEMPO MODE - END

    // NORMAL TIMER
    if (timer.isFinished()) {
      onBeat = true;
      //p5.println("--------O");
      start();
    } else {
      onBeat = false;
    }

    beatMarkerOpacity -= 0.1;
  }

  public void renderTapButton() {
    renderTapButton(beatMarkerPos.x, beatMarkerPos.y);
  }

  public void renderTapButton(float posX, float posY) {

    beatMarkerPos.set(posX, posY);

    stroke(127);
    noFill();
    ellipse(beatMarkerPos.x, beatMarkerPos.y, beatMarkerSize, beatMarkerSize);

    noStroke();
    if (isOnBeat()) {
      beatMarkerOpacity = 1;
    }

    beatMarkerColor = color(191, 205, 49, (beatMarkerOpacity * 255) % 255);
    fill(beatMarkerColor);
    ellipse(beatMarkerPos.x, beatMarkerPos.y, beatMarkerSize * 0.8f, beatMarkerSize * 0.8f);


    if (onTapTempoMode) {
      fill(colorPalette.HIGHLIGHT_RED);
      text("TAPPING", beatMarkerPos.x - 25, beatMarkerPos.y + 34);
    } else {
      fill(255);
      text("TAP", beatMarkerPos.x - 10, beatMarkerPos.y + 34);
    }
  }

  public void setBPM(int _bpm) {
    bpm = _bpm;
    calculateTimerDuration();
    start();
  }

  public int getBPM() {
    return (int) bpm;
  }

  public void setBeatDivision(int division) {
    beatDivision = division * 4.0f;
    calculateTimerDuration();
  }

  public int getBeatDivision() {
    return (int) beatDivision;
  }

  private void calculateTimerDuration() {
    float millisInMinute = 60000;
    int timerDuration = (int) ((millisInMinute / bpm) / (beatDivision / 4.0));
    timer.setDuration(timerDuration);
  }

  private void setBpmFromMillis(int millisecs) {
    float toBpm = (1000.0f / millisecs) * 60;
    toBpm = constrain(toBpm, 60,250);
    setBPM((int) toBpm);
    println("-|| NEW BPM: " + toBpm);
  }

  public void start() {
    timer.start();
  }

  public boolean isOnBeat() {
    return onBeat;
  }

  // TAP TEMPO
  public void tap() {
    tapped = true;

    //controles.getController("bpmDisplay").setValue(bpm);
    controles.getController("tempo").setValue((int)bpm);
  }

  public boolean isOverTapMarker(float x, float y) {
    return dist(x, y, beatMarkerPos.x, beatMarkerPos.y) < beatMarkerSize * 0.5;
  }
  
    public void loadSettings(SettingsLoader config) {
      bpm = config.getTempo();
    }
}
