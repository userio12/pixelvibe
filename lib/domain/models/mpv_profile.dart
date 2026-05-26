class MpvProfile {
  final String name;
  final Map<String, String> properties;
  final bool isBuiltIn;

  const MpvProfile({
    required this.name,
    required this.properties,
    this.isBuiltIn = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'properties': properties,
      };

  factory MpvProfile.fromJson(Map<String, dynamic> json) => MpvProfile(
        name: json['name'] as String,
        properties: Map<String, String>.from(json['properties'] as Map),
      );
}
