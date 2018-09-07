import netP5.*;
import oscP5.*;

class OscManager {

  OscP5 osc;
  NetAddress oscExternalAddress;

  int atBeat, previousBeat;
  boolean enableTriggering = false;

  public OscManager(PApplet p5) {

    // IN: PORT TO RECIEVE IN
    osc = new OscP5(p5, 12000);

    // OUT: NET ADDRESS,PORT TO SEND TO
    oscExternalAddress = new NetAddress("localhost", 12001);

    atBeat = 1;
    previousBeat = 0;
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

  public void reportBeat(int beat) {
    atBeat = beat;
  }



  public void sendTrack(int track) {
    if (enableTriggering) {
      OscMessage mensaje = new OscMessage("/track");
      mensaje.add(track);
      osc.send(mensaje, oscExternalAddress);
    }
  }
}
