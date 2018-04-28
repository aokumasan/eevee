import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;
import std.string;
import std.path;
import std.file;

class HTTPResponse {
  private:
  string[string] header_;
  ubyte[] body_;

  public:
  void setHeader(string key, string value) {
    header_[key] = value;
  }

  int calcContentLength() {
    return cast(int)(body_.length);
  }

  string generateHeader() {
    header_["Content-Length"] = to!string(calcContentLength());
    string header = "";
    foreach (key; header_.keys()) {
      header ~= (key ~ ": " ~ header_[key]);
      header ~= "\r\n";
    }
    return header;
  }

  string generateStatusLine() {
    return "HTTP/1.0 200 OK\r\n";
  }

  void deleteHeader(string key) {
    header_.remove(key);
  }

  void setBody(ubyte[] body) {
    body_ = body;
  }

  string getContentType(string filepath) {
    string ext = toLower(extension(filepath));
    // TODO: Fix it
    string[string] contentTypes = [
      ".html": "text/html; charset=utf-8",
      ".css": "text/css",
      ".png": "text/png",
      ".gif": "text/gif",
      ".jpeg": "text/jpeg",
      ".jpg": "text/jpeg",
      ".js": "text/javascript"
    ];
    // default content type is text/plain
    return contentTypes.get(ext, "text/plain");
  }

  void setBodyFromPath(string filepath) {
    string contentType = getContentType(filepath);
    setHeader("Content-Type", contentType);
    setBody(cast(ubyte[])read(filepath));
  }

  string generateData() {
    string data = "";
    data ~= generateStatusLine();
    data ~= generateHeader();
    data ~= "\r\n";
    data ~= cast(string)body_;
    return data;
  }

}
