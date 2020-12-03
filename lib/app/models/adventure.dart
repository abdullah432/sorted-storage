
class AdventureComment {
  String user;
  String comment;

  AdventureComment({this.user = "", this.comment = ""});

  static AdventureComment fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new AdventureComment();
    }

    String user = "";
    String comment = "";
    Map<String, int> emoji = Map();
    if (json.containsKey('u')) {
      user = json['u'];
    }
    if (json.containsKey('c')) {
      comment = json['c'];
    }

    return new AdventureComment(user: user, comment: comment);
  }

  Map<String, dynamic> toJson() {
    return {
      'u': user,
      'c': comment
    };
  }

}

class AdventureComments {
  List<AdventureComment> comments;

  AdventureComments({this.comments});

  AdventureComments.clone(AdventureComments comment)
      : this(comments: List.from(comment.comments));

  static AdventureComments fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new AdventureComments(comments: List());
    }
    List<AdventureComment> comments = List();
    if (json.containsKey('c')) {
      for (dynamic comment in json['c']) {
        comments.add(AdventureComment.fromJson(comment));
      }
    }

    return new AdventureComments(comments: comments);
  }

  Map<String, dynamic> toJson() {
    return {
      'c': comments,
    };
  }
}

class AdventureSettings {
  String title;
  String description;

  AdventureSettings({this.title = "", this.description = ""});

  static AdventureSettings fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new AdventureSettings();
    }

    String title = "";
    String description = "";
    if (json.containsKey('t')) {
      title = json['t'];
    }
    if (json.containsKey('d')) {
      description = json['d'];
    }

    return new AdventureSettings(title: title, description: description);
  }

  Map<String, dynamic> toJson() {
    return {
      't': title,
      'd': description,
    };
  }
}