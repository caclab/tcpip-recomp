class Note {
  int barIndex;
  float beatInBar;
  String toneName;
  float duration;
  String type;

  Note(int _bI, float _bIB, String _tN, float _d, String _tp) {
    barIndex = _bI;
    beatInBar = _bIB;
    toneName = _tN;
    duration = _d;
    type = _tp;
  } 
}