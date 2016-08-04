class Note {
  int barIndex;
  float beatInBar;
  String toneName;
  float duration;

  Note(int _bI, float _bIB, String _tN, float _d) {
    barIndex = _bI;
    beatInBar = _bIB;
    toneName = _tN;
    duration = _d;
  } 
}