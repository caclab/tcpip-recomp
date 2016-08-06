float lineDistance = 4;
float gramDistance = lineDistance*6;
float gramGroupDistance = gramDistance*2;
float titleHeight = 70;
float beatDistance = 60;
float noteSize = lineDistance*6/7;
float noteAngle = 60; 
float timeAxis = 0, gramIndex = 0;
float offsetY = 0, offsetX = 0; 
int pageOnDisplay = 0, pageIndex = 0;

float marginX;
float marginY;
float head = 60;

JSONObject js;

String songTitle;
String timeSignature;
float beatSpeed;
int barNum;

int n1, n2;
HashMap<String, Float> toneMap = new HashMap<String, Float>();
ArrayList<Note> Notes = new ArrayList<Note>();
ArrayList<Note> NotesChords = new ArrayList<Note>();
ArrayList<Bar> chapterBars = new ArrayList<Bar>();
ArrayList<Bar> chordBars = new ArrayList<Bar>();

float noteAccum;

void setup() {
  size(600, 800);
  pixelDensity(displayDensity());
  background(255);
  smooth();
  toneMapSetup();
  JSONParser("littleStar.json");


  marginX = width*0.05;
  marginY = height*0.05;

  for (Bar cpb : chordBars) {
    for (int i = 0; i<cpb.notes.size(); i++) {
      Note nt = cpb.notes.get(i);
      if (int(nt.beatInBar)==nt.beatInBar && nt.duration<1) {
        NoteGroup newNG = new NoteGroup();
        //newNG.addNote(nt);        
        noteAccum=0;
        int j = 0;        
        while (noteAccum<1) {
          noteAccum = noteAccum + cpb.notes.get(i+j).duration;
          newNG.addNote(cpb.notes.get(i+j));
          j++;
        }
        if (noteAccum == int(noteAccum)) {
          cpb.addNoteGroup(newNG);
          for(Note nttt:newNG.group){
            println(nttt.beatInBar+ "  "+ nttt.duration);
          }
        }
        println();
        //i = i+j;
      }
    }
    //println(cpb.notes.size());
    //println(cpb.noteGroups.size());
  }

  //for (Bar crb: chordBars) {

  //}
}

void draw() {
  background(255);
  pageIndex = 0;
  gramIndex = 0;
  offsetX = marginX+head;

  for (int j = 0; j < 5; j++) {
    float offset = marginY + titleHeight + j*(lineDistance*10+gramDistance + gramGroupDistance); 
    float offset2 = offset + lineDistance*4+gramDistance;
    line(marginX, offset, marginX, offset2+lineDistance*4);
    line(width-marginX, offset, width-marginX, offset2+lineDistance*4);

    for (int i = 0; i< 5; i++) {
      line(marginX, offset+lineDistance*i, width-marginX, offset+lineDistance*i);
      line(marginX, offset2+lineDistance*i, width-marginX, offset2+lineDistance*i);
    }
  }

  noteAccum = 0;
  for (int i = 0; i<Notes.size(); i++) {
    Note nt = Notes.get(i);
    Note pnt = nt;
    if (i!=0) {
      pnt = Notes.get(i-1);
      drawNote(nt, pnt);
    } else {
      drawNote(nt, new Note(1, 1, "", 0, "chapters"));
    }
  }

  if (!js.isNull("chords")) {
    pageIndex = 0;
    gramIndex = 0;
    offsetX = marginX+head;
    for (int i = 0; i<NotesChords.size(); i++) {
      Note nt = NotesChords.get(i);
      Note pnt = nt;
      if (i!=0) {
        pnt = NotesChords.get(i-1);
        drawNote(nt, pnt);
      } else {
        drawNote(nt, new Note(1, 1, "", 0, "chords"));
      }
    }
  }

  for (int i = 0; i< chordBars.size(); i++) {  
    Bar cpb = chordBars.get(i);
    for (int j = 0; j < cpb.noteGroups.size(); j++) {
      NoteGroup NG = cpb.noteGroups.get(j);
      Note nt1 = NG.group.get(0);
      Note nt2 = NG.group.get(NG.group.size()-1);
      float sx = beatDistance * (i*4+j) % (width-2*marginX-head);
      float sy = marginY+titleHeight+(gramGroupDistance+lineDistance*8+gramDistance)*int(beatDistance * (i*4+j) / (width-2*marginX-head));
      stroke(1);
      line(sx+nt1.beatInBar*beatDistance, sy, sx+nt2.beatInBar*beatDistance, sy);
      if(frameCount==1) println("sx  "+sx+"  |  sy "+sy);
    }
  }
}

void drawNote(Note NT, Note prevNT) {

  //float beatNumber, float previousBeatNumber, float lineNumber, float duration, boolean flag) {
  float beatNumber = NT.beatInBar;
  float previousBeatNumber = prevNT.beatInBar;
  float lineNumber = toneToLineIndex(NT.toneName);
  float duration = NT.duration;
  float prevDuration = prevNT.duration;
  boolean flag = (prevNT.barIndex != NT.barIndex);


  if (!flag) {
    offsetX = offsetX + (beatNumber - previousBeatNumber) * beatDistance;
  } else {
    String[] ts = timeSignature.split("/");
    int ts1 = Integer.parseInt(ts[0]);
    offsetX = offsetX + (beatNumber - previousBeatNumber) * beatDistance + ts1*beatDistance;
  }
  if ((offsetX+beatDistance) > width-marginX) {
    offsetX = offsetX -(width-2*marginX-head);
    if (gramIndex+1 >= 5) {
      gramIndex = 0;
      pageIndex ++;
    } else {
      gramIndex = gramIndex+1;
    }
  } 


  if (pageOnDisplay == pageIndex) {
    offsetY = marginY + titleHeight + gramIndex*(lineDistance*10+gramDistance + gramGroupDistance); 
    if (flag) line(offsetX-0.5*beatDistance, offsetY, offsetX-0.5*beatDistance, offsetY+4*lineDistance);
    pushMatrix();
    if (NT.type == "chords") {
      translate(0, gramDistance+lineDistance*5);
      lineNumber=lineNumber-6;
    }
    translate(offsetX, offsetY +lineNumber * lineDistance);

    if (lineNumber>4) {
      for (int i = 0; i < int(lineNumber-4); i++) {
        float lineY = -(i+(lineNumber-int(lineNumber)))*lineDistance;
        line(-noteSize, lineY, noteSize, lineY);
      }
    }
    if (lineNumber<0) {
      for (int i = 0; i < int(-lineNumber); i++) {
        float lineY = (i-(lineNumber-int(lineNumber)))*lineDistance;
        line(-noteSize, lineY, noteSize, lineY);
      }
    }

    float nAR = PI*noteAngle/180;
    noStroke();

    if (duration == 2.0) {
      rotate(PI*(noteAngle)/180);
      fill(0);
      ellipseMode(CENTER);
      ellipse(0, 0, noteSize, noteSize * sqrt(2));
      fill(255);
      ellipse(0, 0, noteSize*0.5, noteSize * sqrt(2)*0.9);
      rotate(-PI*(noteAngle)/180);
    } else {
      rotate(nAR);
      fill(0);
      ellipseMode(CENTER);
      ellipse(0, 0, noteSize, noteSize * sqrt(2));
      rotate(-nAR);
    } 

    translate(noteSize/2*sqrt(2)*sin(nAR)*0.9, -noteSize/2*sqrt(2)*sin(nAR)*0.5);
    stroke(0);



    //if (duration == 0.5) {
    //  strokeCap(ROUND);
    //  strokeWeight(3);
    //  line(0, -20, 8, -15);
    //  strokeWeight(1);
    //  line(0, 0, 0, -20);
    //} else if (duration == 1.5) {
    //  line(0, 0, 0, -20);
    //  ellipse(5, 0, 2, 2);
    //} else {
    //  line(0, 0, 0, -20);
    //}

    line(0, 0, 0, -20);

    popMatrix();
  }
}

void toneMapSetup() {
  toneMap.put("C", 5f);
  toneMap.put("C#", 5f);
  toneMap.put("Db", 4.5);
  toneMap.put("D", 4.5);
  toneMap.put("D#", 4.5);
  toneMap.put("Eb", 4f);
  toneMap.put("E", 4f);
  toneMap.put("F", 3.5);
  toneMap.put("F#", 3.5);
  toneMap.put("Gb", 3f);
  toneMap.put("G", 3f);
  toneMap.put("G#", 3f);
  toneMap.put("Ab", 2.5);
  toneMap.put("A", 2.5);
  toneMap.put("A#", 2.5);
  toneMap.put("Bb", 2f);
  toneMap.put("B", 2f);
}

float toneToLineIndex(String x) {
  int n1 = Integer.parseInt(x.substring(x.length()-1));
  String toneName = x.substring(0, x.length()-1);
  float n2 = toneMap.get(toneName)-(n1-4)*3.5;
  return n2;
}

void JSONParser(String fileName) {
  js = loadJSONObject(fileName);
  songTitle = js.getString("title");
  timeSignature = js.getString("timeSignature");
  beatSpeed = js.getInt("beatSpeed");

  JSONArray jsc = js.getJSONArray("chapters");

  barNum = jsc.size();
  for (int i = 0; i<jsc.size(); i++) {
    JSONArray jsb = jsc.getJSONObject(i).getJSONArray(str(i+1));
    Bar newBar = new Bar();
    for (int j= 0; j<jsb.size(); j++) {
      JSONObject tempObject = jsb.getJSONObject(j);
      String tone = tempObject.getString("tone");
      float beat = tempObject.getFloat("beat");
      float duration = tempObject.getFloat("duration");
      Note newNote = new Note(i+1, beat, tone, duration, "chapters");
      Notes.add(newNote);
      newBar.addNote(newNote);
    }
    chapterBars.add(newBar);
  }
  barNum = jsc.size();
  if (!js.isNull("chords")) {
    jsc = js.getJSONArray("chords");
    for (int i = 0; i<jsc.size(); i++) {
      JSONArray jsb = jsc.getJSONObject(i).getJSONArray(str(i+1));
      Bar newBar = new Bar();

      for (int j= 0; j<jsb.size(); j++) {
        JSONObject tempObject = jsb.getJSONObject(j);
        String tone = tempObject.getString("tone");
        float beat = tempObject.getFloat("beat");
        float duration = tempObject.getFloat("duration");
        Note newNote = new Note(i+1, beat, tone, duration, "chords");
        NotesChords.add(newNote);
        newBar.addNote(newNote);
      }
      chordBars.add(newBar);
    }
  }
  if (jsc.size()>barNum) {
    barNum = jsc.size();
  }
}

void keyReleased() {
  if (key == '=' || key =='+') {
    pageOnDisplay ++;
    background(255);
  } else if (key == '-' || key == '_' ) {
    pageOnDisplay --;
    background(255);
  }
}