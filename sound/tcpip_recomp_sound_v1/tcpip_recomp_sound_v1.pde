
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave;
JSONObject js;

String songTitle;
String timeSignature;
float beatSpeed;

int n1, n2, barNum;
float barLength, beatLength;
HashMap<String, Integer> hm = new HashMap<String, Integer>();
ArrayList<Note> Notes = new ArrayList<Note>();

Table pingData;
int rowNum, colNum;
float[] delays; 
int cycleIndex;
void setup() {
  hmSetup();
  JSONParser("odeToJoy.json");


  minim = new Minim(this);
  out = minim.getLineOut();
  wave = new Oscil( 0, 0.5f, Waves.SINE );
  wave.patch(out);

  String[] ts = timeSignature.split("/");
  n1 = Integer.parseInt(ts[0]);
  n2 = Integer.parseInt(ts[1]);
  beatLength = 60.f/beatSpeed;
  barLength = beatLength*n1;

  //println(Notes.size());

  pingData = loadTable("csv_test.csv");
  rowNum = pingData.getRowCount();
  colNum = pingData.getColumnCount();
  delays = new float[colNum];

  cycleIndex = 0;

  size(100, 100);
  //pixelDensity(displayDensity());
  smooth();
}

void draw() {
  background(255);
  fill(0);
  textAlign(CENTER, CENTER);
  text(songTitle, 50, 50);

  //if (frameCount % int(barLength*barNum) == 1) {
  if (frameCount % int(3) == 1) {
    //playAllNotes(Notes);
    cycleIndex ++;
    if (cycleIndex<rowNum) {
      operationCycle(pingData.getRow(cycleIndex));
      println(cycleIndex);
    }

    if (cycleIndex == rowNum+2) {
      playAllNotes(Notes);
    }
  }
}


float toneToFreq(String x) {
  int n1 = Integer.parseInt(x.substring(x.length()-1));
  String toneName = x.substring(0, x.length()-1);
  int n2 = hm.get(toneName);
  float n = (n2+3)/12.f+n1;
  float frequency = pow(2, n)*13.75;
  return frequency;
}

void hmSetup() {
  hm.put("C", 0);
  hm.put("C#", 1);
  hm.put("Db", 1);
  hm.put("D", 2);
  hm.put("D#", 3);
  hm.put("Eb", 3);
  hm.put("E", 4);
  hm.put("F", 5);
  hm.put("F#", 6);
  hm.put("Gb", 6);
  hm.put("G", 7);
  hm.put("G#", 8);
  hm.put("Ab", 8);
  hm.put("A", 9);
  hm.put("A#", 10);
  hm.put("Bb", 10);
  hm.put("B", 11);
}

void JSONParser(String fileName) {
  js = loadJSONObject(fileName);
  songTitle = js.getString("title");
  timeSignature = js.getString("timeSignature");
  beatSpeed = js.getInt("beatSpeed");

  JSONArray jsc = js.getJSONArray("chapters");
  for (int i = 0; i<jsc.size(); i++) {
    JSONArray jsb = jsc.getJSONObject(i).getJSONArray(str(i+1));
    for (int j= 0; j<jsb.size(); j++) {
      JSONObject tempObject = jsb.getJSONObject(j);
      String tone = tempObject.getString("tone");
      float beat = tempObject.getFloat("beat");
      float duration = tempObject.getFloat("duration");
      Notes.add(new Note(i+1, beat, tone, duration));
    }
  }
  barNum = jsc.size();
  if (!js.isNull("chords")) {
    jsc = js.getJSONArray("chords");
    for (int i = 0; i<jsc.size(); i++) {
      JSONArray jsb = jsc.getJSONObject(i).getJSONArray(str(i+1));
      for (int j= 0; j<jsb.size(); j++) {
        JSONObject tempObject = jsb.getJSONObject(j);
        String tone = tempObject.getString("tone");
        float beat = tempObject.getFloat("beat");
        float duration = tempObject.getFloat("duration");
        Notes.add(new Note(i+1, beat, tone, duration));
      }
    }
  }
  if (jsc.size()>barNum) {
    barNum = jsc.size();
  }
}

void operationCycle(TableRow t) {
  float step = 0.5;
  for (int i = 0; i< colNum; i++) {
    float tempDelay = t.getFloat(i);
    if (tempDelay == 2000) {
      Notes.get(i).duration = 0;
      println("Cycle" + cycleIndex + ": Tone lose"+ i+" ");
    } else {
      delays[i] = delays[i]+t.getFloat(i);
    }
  }
  boolean isReachThres = false;
  for (int i = 0; i< colNum; i++) {
    if (delays[i] >= 0.2) {
      isReachThres = true;
      println("Cycle" + cycleIndex + ": Threshold reached! "+ i+" ");
      if ((Notes.get(i).beatInBar + step) < (n1+1)) {
        Notes.get(i).beatInBar = Notes.get(i).beatInBar + step ;
      } else {
        Notes.get(i).beatInBar = Notes.get(i).beatInBar + step - n1;
        Notes.get(i).barIndex = Notes.get(i).barIndex + 1;
      }
    }
  }
  if (isReachThres) {
    for (int i = 0; i< colNum; i++) {
      delays[i] = 0 ;
    }
  }
}

void playAllNotes(ArrayList<Note> Notes) {
  for (Note tempNote : Notes) {
    out.playNote((tempNote.barIndex-1)*barLength+tempNote.beatInBar*beatLength, tempNote.duration*0.95, new SineInstrument(toneToFreq(tempNote.toneName)));
  }
}