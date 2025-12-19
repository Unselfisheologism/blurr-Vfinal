import 'package:hive/hive.dart';
import '../learning_activity.dart';

class LearningActivityAdapter extends TypeAdapter<LearningActivity> {
  @override
  final int typeId = 3;

  @override
  LearningActivity read(BinaryReader reader) {
    return LearningActivity(
      id: reader.readString(),
      title: reader.readString(),
      type: reader.readString(),
      chapterId: reader.readString(),
      description: reader.readString(),
      content: reader.readString(),
      metadata: reader.readMap(),
      isCompleted: reader.readBool(),
      completedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, LearningActivity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.type);
    writer.writeString(obj.chapterId);
    writer.writeString(obj.description ?? '');
    writer.writeString(obj.content ?? '');
    writer.writeMap(obj.metadata);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.completedAt?.millisecondsSinceEpoch ?? 0);
    writer.writeInt(obj.createdAt?.millisecondsSinceEpoch ?? 0);
  }
}

// Additional adapters for nested objects
class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 5;

  @override
  QuizQuestion read(BinaryReader reader) {
    return QuizQuestion(
      id: reader.readString(),
      question: reader.readString(),
      type: reader.readString(),
      options: reader.readStringList(),
      correctAnswers: reader.readStringList(),
      explanation: reader.readString(),
      points: reader.readInt(),
      tags: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.question);
    writer.writeString(obj.type);
    writer.writeStringList(obj.options ?? []);
    writer.writeStringList(obj.correctAnswers ?? []);
    writer.writeString(obj.explanation ?? '');
    writer.writeInt(obj.points ?? 1);
    writer.writeStringList(obj.tags ?? []);
  }
}

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 6;

  @override
  Flashcard read(BinaryReader reader) {
    return Flashcard(
      id: reader.readString(),
      front: reader.readString(),
      back: reader.readString(),
      hint: reader.readString(),
      tags: reader.readStringList(),
      interval: reader.readInt(),
      repetitions: reader.readInt(),
      easeFactor: reader.readDouble(),
      nextReview: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isLearned: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.front);
    writer.writeString(obj.back);
    writer.writeString(obj.hint ?? '');
    writer.writeStringList(obj.tags ?? []);
    writer.writeInt(obj.interval ?? 1);
    writer.writeInt(obj.repetitions ?? 1);
    writer.writeDouble(obj.easeFactor ?? 2.5);
    writer.writeInt(obj.nextReview?.millisecondsSinceEpoch ?? 0);
    writer.writeBool(obj.isLearned ?? false);
  }
}