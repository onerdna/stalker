class GitHub {
  static const String repoUser = "onerdna";
  static const String repoName = "stalker";
  static const String repoUrl = "https://github.com/$repoUser/$repoName";
  static const String latestRelease = "$repoUrl/releases/latest";
  static const String issueFeatureRequest =
      "$repoUrl/issues/new?template=feature_request.md";
  static const String issueAdditionalSetup =
      "$repoUrl/issues/new?template=additional-setup-bug-report.md";
  static const String issueGeneral =
      "$repoUrl/issues/new?template=general-bug-report.md";
}
