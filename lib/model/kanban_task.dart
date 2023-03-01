class KanbanTask {
  String title;
  String description;
  DateTime? createdDate;
  DateTime? startDate;
  DateTime? endDate;
  Duration? duration = Duration.zero;
  bool isRunning = false;

  KanbanTask({
    required this.title,
    required this.description,
    required this.createdDate,
    this.startDate,
    this.endDate,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'createdDate': createdDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'duration': duration?.toString(),
    };
  }

  factory KanbanTask.fromJson(Map<String, dynamic> json) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    if (json['duration'] != null) {
      List<String> parts = json['duration'].split(':');
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
      seconds = int.parse(parts[2].split('.')[0]);
    }

    return KanbanTask(
      title: json['title'],
      description: json['description'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] ?? "") : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] ?? "") : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] ?? "") : null,
      duration: json['duration'] != null ? Duration(hours: hours, minutes: minutes, seconds: seconds) : null,
    );
  }
}
