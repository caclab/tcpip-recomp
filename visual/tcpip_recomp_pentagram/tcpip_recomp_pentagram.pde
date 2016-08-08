float lineDistance = 5;
float gramDistance = lineDistance*6;
float gramGroupDistance = gramDistance*2;
float gramGroupHeight = lineDistance*8+gramDistance+gramGroupDistance;
float titleHeight = 70;
float beatDistance;
float noteSize = lineDistance*6/7;
float noteAngle = 60; 
float timeAxis = 0, gramIndex = 0;
float offsetY = 0, offsetX = 0; 
int pageOnDisplay = 1, pageIndex = 0, gramGroupCount = 5;

float marginX;
float marginY;
float head = 60;

JSONObject js;

String songTitle;
String timeSignature;
float beatSpeed;
int barNum, beatNumInBar, beatLength;

int n1, n2;
HashMap<String, Float> toneMap = new HashMap<String, Float>();
ArrayList<Note> Notes = new ArrayList<Note>();
ArrayList<Note> NotesChords = new ArrayList<Note>();
ArrayList<Bar> chapterBars = new ArrayList<Bar>();
ArrayList<Bar> chordBars = new ArrayList<Bar>();

float noteAccum;


PShape GClef, FClef;
PFont font;

void setup() {
  size(600, 800);
  pixelDensity(displayDensity());
  background(255);
  smooth();
  toneMapSetup();
  JSONParser("littleStar.json");
  GClef = loadShape("GClef.svg");
  FClef = loadShape("FClef.svg");
  font = loadFont("TimesNewRomanPS-BoldMT-20.vlw");


  marginX = width*0.05;
  marginY = height*0.05;
  beatDistance = (width-head-2*marginX)/9;

  for (Bar mb : chordBars) {
    barAnalyse(mb);
    //println(mb.notes.size(), mb.noteGroups.size(), mb.singleNotes.size());
  }

  for (Bar mb : chapterBars) {
    barAnalyse(mb);
    println(mb.notes.size(), mb.noteGroups.size(), mb.singleNotes.size());
    //for(Note nttt:mb.singleNotes){
    //  println(nttt.toneName);
    //}
  }
  frameRate(10);
}

void draw() {
  background(255);
  //pageIndex = 0;
  //gramIndex = 0;
  //offsetX = marginX+head;

  if (pageOnDisplay == 1) {
    textFont(font,20);
    textAlign(CENTER, TOP);
    //textSize(20);
    text(songTitle, width/2, marginY);
    
    textFont(font,lineDistance*3);
    textAlign(CENTER, TOP);
    text(str(beatNumInBar), marginX+30, marginY+titleHeight+lineDistance*2);
    textAlign(CENTER, BOTTOM);
    text(str(beatLength), marginX+30, marginY+titleHeight+lineDistance*2+3);
  }

  int tempGramGroupCount;
  if (pageOnDisplay == 1) tempGramGroupCount = gramGroupCount;
  else tempGramGroupCount = gramGroupCount + 1;

  for (int j = 0; j < tempGramGroupCount; j++) {    
    float offset, offset2;
    if (pageOnDisplay == 1) offset = titleHeight + marginY+gramGroupHeight*j;
    else offset = marginY+gramGroupHeight*j;
    offset2 = offset + lineDistance*4+gramDistance;

    shape(GClef, marginX+3, offset-10);
    shape(FClef, marginX+3, offset2);


    line(marginX, offset, marginX, offset2+lineDistance*4);
    line(width-marginX, offset, width-marginX, offset2+lineDistance*4);



    for (int i = 0; i< 5; i++) {
      line(marginX, offset+lineDistance*i, width-marginX, offset+lineDistance*i);
      line(marginX, offset2+lineDistance*i, width-marginX, offset2+lineDistance*i);
    }
  }

  pageIndex = 1;
  gramIndex = 1;
  offsetX = marginX+head;
  for (int i = 0; i< chapterBars.size(); i++) { 
    Bar mb = chapterBars.get(i);
    drawBar(mb);

    if (i< chordBars.size()) {
      mb = chordBars.get(i);
      drawBar(mb);
    }

    offsetX = offsetX + beatNumInBar*beatDistance;
    if (pageOnDisplay == pageIndex) {
      float offsetY = (gramIndex-1)*gramGroupHeight+(1/pageOnDisplay)*titleHeight+marginY;
      line(offsetX+10, offsetY, offsetX+10, offsetY+4*lineDistance);
      if (i< chordBars.size()) {
        float offsetY2 = offsetY + gramDistance + lineDistance * 4;
        line(offsetX+10, offsetY2, offsetX+10, offsetY2+4*lineDistance);
      }
    }
    if ((offsetX+ beatNumInBar*beatDistance) >= width-marginX) {
      //offsetX = offsetX - (width-2*marginX-head)-beatDistance;
      offsetX =marginX+head;
      gramIndex ++;
    }

    if (pageIndex == 1) {
      if (gramIndex > gramGroupCount) {
        gramIndex = 1;
        pageIndex ++;
      }
    } else {
      if (gramIndex > gramGroupCount+1) {
        gramIndex = 1;
        pageIndex ++;
      }
    }
  }
}

void barAnalyse(Bar cpb) {
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
        //for (Note nttt : newNG.group) {
        //  println(nttt.beatInBar+ "  "+ nttt.duration);
        //}
      } else {
        for (Note snt : newNG.group) {
          cpb.singleNotes.add(snt);
        }
      }
      //println();
      i = i+j-1;
    } else {
      cpb.singleNotes.add(nt);
    }
  }
}

void drawBar(Bar mb) {
  for (int j = 0; j<mb.singleNotes.size(); j++) {
    FloatList notePos = getNotePosition(int(pageIndex), int(gramIndex), offsetX, mb.singleNotes.get(j));
    println(j);
    if (pageIndex== pageOnDisplay) {
      drawNote2(notePos.get(0), notePos.get(1), notePos.get(2), mb.singleNotes.get(j));
      line(notePos.get(0), notePos.get(1), notePos.get(0), notePos.get(1)-20);
    }
  }
  for (int j = 0; j < mb.noteGroups.size(); j++) {
    NoteGroup grp = mb.noteGroups.get(j);
    Note nt1 = grp.group.get(0);
    Note nt2 = grp.group.get(grp.group.size()-1);
    float x1, x2, y1, y2;
    FloatList notePos1 = getNotePosition(int(pageIndex), int(gramIndex), offsetX, nt1);
    FloatList notePos2 = getNotePosition(int(pageIndex), int(gramIndex), offsetX, nt2);
    x1 = notePos1.get(0);
    y1 = notePos1.get(1);
    x2 = notePos2.get(0);
    y2 = notePos2.get(1);
    if (pageIndex== pageOnDisplay) {
      for (int k = 0; k<grp.group.size(); k++) {
        float mv = grp.group.get(k).beatInBar - int(grp.group.get(k).beatInBar);
        FloatList notePos = getNotePosition(int(pageIndex), int(gramIndex), offsetX, grp.group.get(k));
        line(notePos.get(0), notePos.get(1), notePos.get(0), map(mv, 0, 1, y1-20, y2-20));
        drawNote2(notePos.get(0), notePos.get(1), notePos.get(2), mb.notes.get(j));
      }
      line(x1, y1-20, x2, y2-20);
    }
  }
}

FloatList getNotePosition(int pageIndex, int gramGroupIndex, float posX, Note nt) {
  //if (pageIndex == 1) {
  float posY; 
  if (pageIndex == 1) posY= marginY+gramGroupHeight*(gramGroupIndex-1) + titleHeight;
  else posY = marginY+gramGroupHeight*(gramGroupIndex-1);

  float lineNumber = getLineNumber(nt);

  if (nt.type=="chords") {
    posY = posY+(lineNumber+4)*lineDistance+gramDistance;
  } else {
    posY = posY+lineNumber*lineDistance;
  }
  posX = posX + beatDistance*(nt.beatInBar-0.5);
  //line(posX, 0, posX, height);

  FloatList result = new FloatList();
  result.append(posX);
  result.append(posY);
  result.append(lineNumber);
  return result;
}
void drawNote2(float posX, float posY, float lineNumber, Note nt) {
  pushMatrix();
  translate(posX, posY);

  noStroke();
  if (nt.duration == 2.0) {
    rotate(PI*(noteAngle)/180);
    fill(0);
    ellipseMode(CENTER);
    ellipse(0, 0, noteSize, noteSize * sqrt(2));
    fill(255);
    ellipse(0, 0, noteSize*0.5, noteSize * sqrt(2)*0.9);
    rotate(-PI*(noteAngle)/180);
  } else {
    rotate(PI*(noteAngle)/180);
    fill(0);
    ellipseMode(CENTER);
    ellipse(0, 0, noteSize, noteSize * sqrt(2));
    rotate(-PI*(noteAngle)/180);
  }
  stroke(0);

  if (lineNumber>4) {
    for (int i = 0; i < int(lineNumber-4); i++) {
      float lineY = -(i+(lineNumber-int(lineNumber)))*lineDistance;
      line(-noteSize*1.2, lineY, noteSize*1.2, lineY);
    }
  }
  if (lineNumber<0) {
    for (int i = 0; i < int(-lineNumber); i++) {
      float lineY = (i-(lineNumber-int(lineNumber)))*lineDistance;
      line(-noteSize*1.2, lineY, noteSize*1.2, lineY);
    }
  }
  popMatrix();
}


float getLineNumber(Note nt) {
  String x = nt.toneName;
  int n1 = Integer.parseInt(x.substring(x.length()-1));
  String toneName = x.substring(0, x.length()-1);
  float lineNumber = toneMap.get(toneName)-(n1-4)*3.5;

  if (nt.type == "chords") {
    lineNumber=lineNumber-6;
  }
  return lineNumber;
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

  String[] ts = timeSignature.split("/");
  beatNumInBar = Integer.parseInt(ts[1]);
  beatLength = Integer.parseInt(ts[0]);

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