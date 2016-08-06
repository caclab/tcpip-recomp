class NoteGroup {
  ArrayList<Note> group;
  
  NoteGroup(){
    group = new ArrayList<Note>();
  }
  
  void addNote(Note nt){
    group.add(nt);
  }
  
}