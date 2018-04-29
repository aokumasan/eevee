import server;
import dyaml;
import std.getopt;

string configPath = "config.yml";

void main(string[] args)
{
  getopt(args, "config|c", &configPath);
  auto config = Loader(configPath).load();

  Server srv = new Server(config);
  srv.run();
}
