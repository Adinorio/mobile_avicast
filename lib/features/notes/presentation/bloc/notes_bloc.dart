import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';
import '../../data/repositories/notes_repository_impl.dart';

// Events
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {}

class CreateNote extends NotesEvent {
  final String title;
  final String content;
  final List<String> tags;
  final String? siteId;

  const CreateNote({
    required this.title,
    required this.content,
    this.tags = const [],
    this.siteId,
  });

  @override
  List<Object?> get props => [title, content, tags, siteId];
}

class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

class GetNotesBySite extends NotesEvent {
  final String siteId;

  const GetNotesBySite(this.siteId);

  @override
  List<Object?> get props => [siteId];
}

// States
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final String? searchQuery;
  final String? siteFilter;

  const NotesLoaded({
    required this.notes,
    this.searchQuery,
    this.siteFilter,
  });

  @override
  List<Object?> get props => [notes, searchQuery, siteFilter];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteOperationSuccess extends NotesState {
  final String message;
  final List<Note> notes;

  const NoteOperationSuccess({
    required this.message,
    required this.notes,
  });

  @override
  List<Object?> get props => [message, notes];
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepositoryImpl _notesRepository;

  NotesBloc(this._notesRepository) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<SearchNotes>(_onSearchNotes);
    on<GetNotesBySite>(_onGetNotesBySite);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final notes = await _notesRepository.getAllNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError('Failed to load notes: $e'));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final success = await _notesRepository.createNote(
        title: event.title,
        content: event.content,
        tags: event.tags,
        siteId: event.siteId,
      );

      if (success) {
        final notes = await _notesRepository.getAllNotes();
        emit(NoteOperationSuccess(
          message: 'Note created successfully',
          notes: notes,
        ));
        emit(NotesLoaded(notes: notes));
      } else {
        emit(NotesError('Failed to create note'));
      }
    } catch (e) {
      emit(NotesError('Failed to create note: $e'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final success = await _notesRepository.updateNote(event.note);

      if (success) {
        final notes = await _notesRepository.getAllNotes();
        emit(NoteOperationSuccess(
          message: 'Note updated successfully',
          notes: notes,
        ));
        emit(NotesLoaded(notes: notes));
      } else {
        emit(NotesError('Failed to update note'));
      }
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final success = await _notesRepository.deleteNote(event.noteId);

      if (success) {
        final notes = await _notesRepository.getAllNotes();
        emit(NoteOperationSuccess(
          message: 'Note deleted successfully',
          notes: notes,
        ));
        emit(NotesLoaded(notes: notes));
      } else {
        emit(NotesError('Failed to delete note'));
      }
    } catch (e) {
      emit(NotesError('Failed to delete note: $e'));
    }
  }

  Future<void> _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final notes = await _notesRepository.searchNotes(event.query);
      emit(NotesLoaded(notes: notes, searchQuery: event.query));
    } catch (e) {
      emit(NotesError('Failed to search notes: $e'));
    }
  }

  Future<void> _onGetNotesBySite(GetNotesBySite event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final notes = await _notesRepository.getNotesBySite(event.siteId);
      emit(NotesLoaded(notes: notes, siteFilter: event.siteId));
    } catch (e) {
      emit(NotesError('Failed to load site notes: $e'));
    }
  }
} 