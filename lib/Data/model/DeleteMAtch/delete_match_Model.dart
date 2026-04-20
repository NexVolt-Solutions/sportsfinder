class DeleteMatchModel {
  final String matchId;
  final bool deleted;

  const DeleteMatchModel({
    required this.matchId,
    this.deleted = true,
  });
}
