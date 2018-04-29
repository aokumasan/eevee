import server;
import std.getopt;

ushort port = 8080;
int maxConnections = 512;

void main(string[] args)
{
  getopt(args,
	 "port|p", &port,
	 "maxConnections|m", &maxConnections
	 );

  Server srv = new Server();
  srv.run(port, maxConnections);
}
