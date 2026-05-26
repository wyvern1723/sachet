class GithubLatestReleaseApiResponse {
  String? url;
  String? assetsUrl;
  String? uploadUrl;

  /// 最新一个 tag 的网页链接
  String? htmlUrl;

  /// 最新版本的 tag (版本号)
  String? tagName;
  String? targetCommitish;
  String? name;
  String? createdAt;

  /// 发布日期
  String? publishedAt;
  List<Assets>? assets;

  /// releaseNote (更新内容)
  String? body;

  GithubLatestReleaseApiResponse({
    this.url,
    this.assetsUrl,
    this.uploadUrl,
    this.htmlUrl,
    this.tagName,
    this.targetCommitish,
    this.name,
    this.createdAt,
    this.publishedAt,
    this.assets,
    this.body,
  });

  GithubLatestReleaseApiResponse.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    assetsUrl = json['assets_url'];
    uploadUrl = json['upload_url'];
    htmlUrl = json['html_url'];
    tagName = json['tag_name'];
    targetCommitish = json['target_commitish'];
    name = json['name'];
    createdAt = json['created_at'];
    publishedAt = json['published_at'];
    if (json['assets'] != null) {
      assets = <Assets>[];
      json['assets'].forEach((v) {
        assets!.add(Assets.fromJson(v));
      });
    }
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['assets_url'] = assetsUrl;
    data['upload_url'] = uploadUrl;
    data['html_url'] = htmlUrl;
    data['tag_name'] = tagName;
    data['target_commitish'] = targetCommitish;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['published_at'] = publishedAt;
    if (assets != null) {
      data['assets'] = assets!.map((v) => v.toJson()).toList();
    }
    data['body'] = body;
    return data;
  }
}

class Assets {
  String? url;
  int? id;
  String? nodeId;
  String? name;
  String? label;
  Uploader? uploader;
  String? contentType;
  String? state;
  int? size;
  int? downloadCount;
  String? createdAt;
  String? updatedAt;
  String? browserDownloadUrl;

  Assets({
    this.url,
    this.id,
    this.nodeId,
    this.name,
    this.label,
    this.uploader,
    this.contentType,
    this.state,
    this.size,
    this.downloadCount,
    this.createdAt,
    this.updatedAt,
    this.browserDownloadUrl,
  });

  Assets.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    nodeId = json['node_id'];
    name = json['name'];
    label = json['label'];
    uploader =
        json['uploader'] != null ? Uploader.fromJson(json['uploader']) : null;
    contentType = json['content_type'];
    state = json['state'];
    size = json['size'];
    downloadCount = json['download_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    browserDownloadUrl = json['browser_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['id'] = id;
    data['node_id'] = nodeId;
    data['name'] = name;
    data['label'] = label;
    if (uploader != null) {
      data['uploader'] = uploader!.toJson();
    }
    data['content_type'] = contentType;
    data['state'] = state;
    data['size'] = size;
    data['download_count'] = downloadCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['browser_download_url'] = browserDownloadUrl;
    return data;
  }
}

class Uploader {
  String? login;
  int? id;
  String? nodeId;
  String? avatarUrl;
  String? gravatarId;
  String? url;
  String? htmlUrl;
  String? followersUrl;
  String? followingUrl;
  String? gistsUrl;
  String? starredUrl;
  String? subscriptionsUrl;
  String? organizationsUrl;
  String? reposUrl;
  String? eventsUrl;
  String? receivedEventsUrl;
  String? type;
  String? userViewType;
  bool? siteAdmin;

  Uploader({
    this.login,
    this.id,
    this.nodeId,
    this.avatarUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.followersUrl,
    this.followingUrl,
    this.gistsUrl,
    this.starredUrl,
    this.subscriptionsUrl,
    this.organizationsUrl,
    this.reposUrl,
    this.eventsUrl,
    this.receivedEventsUrl,
    this.type,
    this.userViewType,
    this.siteAdmin,
  });

  Uploader.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    id = json['id'];
    nodeId = json['node_id'];
    avatarUrl = json['avatar_url'];
    gravatarId = json['gravatar_id'];
    url = json['url'];
    htmlUrl = json['html_url'];
    followersUrl = json['followers_url'];
    followingUrl = json['following_url'];
    gistsUrl = json['gists_url'];
    starredUrl = json['starred_url'];
    subscriptionsUrl = json['subscriptions_url'];
    organizationsUrl = json['organizations_url'];
    reposUrl = json['repos_url'];
    eventsUrl = json['events_url'];
    receivedEventsUrl = json['received_events_url'];
    type = json['type'];
    userViewType = json['user_view_type'];
    siteAdmin = json['site_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['login'] = login;
    data['id'] = id;
    data['node_id'] = nodeId;
    data['avatar_url'] = avatarUrl;
    data['gravatar_id'] = gravatarId;
    data['url'] = url;
    data['html_url'] = htmlUrl;
    data['followers_url'] = followersUrl;
    data['following_url'] = followingUrl;
    data['gists_url'] = gistsUrl;
    data['starred_url'] = starredUrl;
    data['subscriptions_url'] = subscriptionsUrl;
    data['organizations_url'] = organizationsUrl;
    data['repos_url'] = reposUrl;
    data['events_url'] = eventsUrl;
    data['received_events_url'] = receivedEventsUrl;
    data['type'] = type;
    data['user_view_type'] = userViewType;
    data['site_admin'] = siteAdmin;
    return data;
  }
}
