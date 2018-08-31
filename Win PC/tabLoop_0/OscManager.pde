import netP5.*;
import oscP5.*;

class OscManager {

  OscP5 osc;
  NetAddress oscExternalAddress;

  public OscManager(PApplet p5) {
    
    // IN: PORT TO RECIEVE IN
    osc = new OscP5(p5, 12000);
    
    // OUT: NET ADDRESS,PORT TO SEND TO
    oscExternalAddress = new NetAddress("localhost", 12000);
  }



  public void sendTrack(int track) {
    OscMessage mensaje = new OscMessage("/track");
    mensaje.add(track);
    osc.send(mensaje,oscExternalAddress);
  }
}
