
int ledPins[16];
int selectedPin = 1;

void setup() {
  Serial.begin(9600);

  for (int i = 0; i < 16; i++) {
    ledPins[i] = 10 + i;
    pinMode(ledPins[i], OUTPUT);
    Serial.println(ledPins[i]);
  }
  Serial.flush();
}

void loop() {
  while (Serial.available() > 0) {
    //selectedPin = (int)Serial.read();
    //selectedPin = (selectedPin + 1) % 16;
    /*
      int val = Serial.read();
      if (val == 1) {
      selectedPin = 1;
      } else {
      selectedPin = 0;
      }
    */

    for (int i = 0; i < 16; i++) {
      digitalWrite(ledPins[i], LOW);
    }

    int selectedPin = (int)Serial.read();
    digitalWrite(ledPins[selectedPin], HIGH);
    Serial.write(selectedPin);

  }


  //delay(100);
  //selectedPin = (selectedPin + 1) % 16;
}

