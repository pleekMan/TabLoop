import processing.serial.*;

Serial myPort; 
int val; 

void setup() 
{
  size(200, 200);
  frameRate(30);

  printArray(Serial.list());
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);

  val = 0;
}

void draw() {

  if (frameCount % 15 == 0) {
    val = (val + 1) % 16;
    myPort.write(val);
    //myPort.clear();
  }

  if (mousePressed) {
    myPort.write(0);
  }
  
  myPort.clear();
}


void keyPressed() {
  if (key == '1') {
    myPort.write(1);
  }
  if (key == '2') {
    myPort.write(2);
  }
}

void serialEvent(Serial s) {
  println(myPort.read());
}


/*
  // Wiring/Arduino code:
 // Read data from the serial and turn ON or OFF a light depending on the value
 
 char val; // Data received from the serial port
 int ledPin = 4; // Set the pin to digital I/O 4
 
 void setup() {
 pinMode(ledPin, OUTPUT); // Set pin as OUTPUT
 Serial.begin(9600); // Start serial communication at 9600 bps
 }
 
 void loop() {
 while (Serial.available()) { // If data is available to read,
 val = Serial.read(); // read it and store it in val
 }
 if (val == 'H') { // If H was received
 digitalWrite(ledPin, HIGH); // turn the LED on
 } else {
 digitalWrite(ledPin, LOW); // Otherwise turn it OFF
 }
 delay(100); // Wait 100 milliseconds for next reading
 }
 
 */
