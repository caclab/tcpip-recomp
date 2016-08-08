class Bar {
  ArrayList<Note> notes;
  ArrayList<NoteGroup> noteGroups;
  ArrayList<Note> singleNotes;
  Bar() {
    notes = new ArrayList<Note>();
    noteGroups = new ArrayList<NoteGroup>();
    singleNotes = new ArrayList<Note>();
  }

  void addNote(Note nt) {
    notes.add(nt);
  }
  void addNoteGroup(NoteGroup NG){
    noteGroups.add(NG);
    //notes.delete();
  }
}