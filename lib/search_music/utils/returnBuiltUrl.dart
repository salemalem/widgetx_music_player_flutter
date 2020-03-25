returnBuildUrl(query) {
  return Uri.http("hotmo.org", "/search", { "q" : query });
}