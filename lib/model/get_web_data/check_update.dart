import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sachet/constants/url_constants.dart';

/// 获取 Github Release 最新版本的信息
///
/// Return [latestTagName,releaseNote,downloadLink,latestTagUrl];
///
/// [latestTagName]：最新版本的 tag (版本号)
///
/// [releaseNote]：releaseNote (更新内容)
///
/// [downloadLink]：下载直链
///
/// [apkSize]：安装包大小
///
/// [latestTagUrl]：最新一个 tag 的网页链接
Future<GithubLatestReleaseApiResponse> getGithubReleaseLatest() async {
  try {
    var response = await Dio().get(checkAppUpdateAPI);

    GithubLatestReleaseApiResponse githubLatestReleaseApiResponse =
        GithubLatestReleaseApiResponse.fromJson(response.data);

    return githubLatestReleaseApiResponse;
  } on DioException catch (e) {
    if (kDebugMode) {
      print("error : ${e.response?.data}");
      print(e.type);
    }
    throw '';
  }
}

class GithubLatestReleaseApiResponse {
  String? url;
  String? assetsUrl;
  String? uploadUrl;
  String? htmlUrl;
  String? tagName;
  String? targetCommitish;
  String? name;
  String? createdAt;
  String? publishedAt;
  List<Assets>? assets;
  String? body;

  GithubLatestReleaseApiResponse(
      {this.url,
      this.assetsUrl,
      this.uploadUrl,
      this.htmlUrl,
      this.tagName,
      this.targetCommitish,
      this.name,
      this.createdAt,
      this.publishedAt,
      this.assets,
      this.body});

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
        assets!.add(new Assets.fromJson(v));
      });
    }
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['assets_url'] = this.assetsUrl;
    data['upload_url'] = this.uploadUrl;
    data['html_url'] = this.htmlUrl;
    data['tag_name'] = this.tagName;
    data['target_commitish'] = this.targetCommitish;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['published_at'] = this.publishedAt;
    if (this.assets != null) {
      data['assets'] = this.assets!.map((v) => v.toJson()).toList();
    }
    data['body'] = this.body;
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

  Assets(
      {this.url,
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
      this.browserDownloadUrl});

  Assets.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    nodeId = json['node_id'];
    name = json['name'];
    label = json['label'];
    uploader = json['uploader'] != null
        ? new Uploader.fromJson(json['uploader'])
        : null;
    contentType = json['content_type'];
    state = json['state'];
    size = json['size'];
    downloadCount = json['download_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    browserDownloadUrl = json['browser_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['name'] = this.name;
    data['label'] = this.label;
    if (this.uploader != null) {
      data['uploader'] = this.uploader!.toJson();
    }
    data['content_type'] = this.contentType;
    data['state'] = this.state;
    data['size'] = this.size;
    data['download_count'] = this.downloadCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['browser_download_url'] = this.browserDownloadUrl;
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

  Uploader(
      {this.login,
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
      this.siteAdmin});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login'] = this.login;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['avatar_url'] = this.avatarUrl;
    data['gravatar_id'] = this.gravatarId;
    data['url'] = this.url;
    data['html_url'] = this.htmlUrl;
    data['followers_url'] = this.followersUrl;
    data['following_url'] = this.followingUrl;
    data['gists_url'] = this.gistsUrl;
    data['starred_url'] = this.starredUrl;
    data['subscriptions_url'] = this.subscriptionsUrl;
    data['organizations_url'] = this.organizationsUrl;
    data['repos_url'] = this.reposUrl;
    data['events_url'] = this.eventsUrl;
    data['received_events_url'] = this.receivedEventsUrl;
    data['type'] = this.type;
    data['user_view_type'] = this.userViewType;
    data['site_admin'] = this.siteAdmin;
    return data;
  }
}
