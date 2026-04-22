class GoogleAuthRequestModel {
  const GoogleAuthRequestModel({required this.idToken});

  final String idToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id_token': idToken};
  }
}
