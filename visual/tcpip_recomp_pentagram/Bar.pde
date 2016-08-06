class Bar {
  ArrayList<Note> notes;
  ArrayList<NoteGroup> noteGroups;
  Bar() {
    notes = new ArrayList<Note>();
    noteGroups = new ArrayList<NoteGroup>();
  }

  void addNote(Note nt) {
    notes.add(nt);
  }
  void addNoteGroup(NoteGroup NG){
    noteGroups.add(NG);
  }
}