import 'package:hive/hive.dart';
import '../learning_material.dart';

class LearningMaterialAdapter extends TypeAdapter<LearningMaterial> {
  @override
  final int typeId = 1;

  @override
  LearningMaterial read(BinaryReader reader) {
    return LearningMaterial(
      id: reader.readString(),
      title: reader.readString(),
      type: MaterialType.values[reader.readByte()],
      source: MaterialSource.values[reader.readByte()],
      description: reader.readString(),
      content: reader.readString(),
      filePath: reader.readString(),
      url: reader.readString(),
      thumbnailUrl: reader.readString(),
      size: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      tags: reader.readStringList(),
      metadata: reader.readMap(),
      aiProcessed: reader.readBool(),
      aiSummary: _readAISummary(reader),
      estimatedReadTime: reader.readInt(),
      estimatedListenTime: reader.readInt(),
      courseId: reader.readString(),
      chapterId: reader.readString(),
      activityId: reader.readString(),
      progress: reader.readDouble(),
      completedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      userProgress: reader.readMap(),
    );
  }

  @override
  void write(BinaryWriter writer, LearningMaterial obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeByte(obj.type.index);
    writer.writeByte(obj.source.index);
    writer.writeString(obj.description ?? '');
    writer.writeString(obj.content ?? '');
    writer.writeString(obj.filePath ?? '');
    writer.writeString(obj.url ?? '');
    writer.writeString(obj.thumbnailUrl ?? '');
    writer.writeInt(obj.size ?? 0);
    writer.writeInt(obj.createdAt?.millisecondsSinceEpoch ?? 0);
    writer.writeInt(obj.updatedAt?.millisecondsSinceEpoch ?? 0);
    writer.writeInt(obj.lastAccessedAt?.millisecondsSinceEpoch ?? 0);
    writer.writeStringList(obj.tags ?? []);
    writer.writeMap(obj.metadata ?? {});
    writer.writeBool(obj.aiProcessed);
    _writeAISummary(writer, obj.aiSummary);
    writer.writeInt(obj.estimatedReadTime ?? 0);
    writer.writeInt(obj.estimatedListenTime ?? 0);
    writer.writeString(obj.courseId ?? '');
    writer.writeString(obj.chapterId ?? '');
    writer.writeString(obj.activityId ?? '');
    writer.writeDouble(obj.progress);
    writer.writeInt(obj.completedAt?.millisecondsSinceEpoch ?? 0);
    writer.writeMap(obj.userProgress);
  }

  AISummary? _readAISummary(BinaryReader reader) {
    if (!reader.readBool()) return null;
    
    return AISummary(
      briefSummary: reader.readString(),
      detailedSummary: reader.readString(),
      keyPoints: reader.readStringList(),
      mainTopics: reader.readStringList(),
      difficultyLevel: reader.readString(),
      prerequisites: reader.readStringList(),
      customFields: reader.readMap(),
    );
  }

  void _writeAISummary(BinaryWriter writer, AISummary? summary) {
    if (summary == null) {
      writer.writeBool(false);
      return;
    }
    
    writer.writeBool(true);
    writer.writeString(summary.briefSummary);
    writer.writeString(summary.detailedSummary ?? '');
    writer.writeStringList(summary.keyPoints ?? []);
    writer.writeStringList(summary.mainTopics ?? []);
    writer.writeString(summary.difficultyLevel ?? '');
    writer.writeStringList(summary.prerequisites ?? []);
    writer.writeMap(summary.customFields ?? {});
  }
}

class AISummaryAdapter extends TypeAdapter<AISummary> {
  @override
  final int typeId = 2;

  @override
  AISummary read(BinaryReader reader) {
    return AISummary(
      briefSummary: reader.readString(),
      detailedSummary: reader.readString(),
      keyPoints: reader.readStringList(),
      mainTopics: reader.readStringList(),
      difficultyLevel: reader.readString(),
      prerequisites: reader.readStringList(),
      customFields: reader.readMap(),
    );
  }

  @override
  void write(BinaryWriter writer, AISummary obj) {
    writer.writeString(obj.briefSummary);
    writer.writeString(obj.detailedSummary ?? '');
    writer.writeStringList(obj.keyPoints ?? []);
    writer.writeStringList(obj.mainTopics ?? []);
    writer.writeString(obj.difficultyLevel ?? '');
    writer.writeStringList(obj.prerequisites ?? []);
    writer.writeMap(obj.customFields ?? {});
  }
}