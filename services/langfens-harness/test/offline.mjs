// Test-process guard: fail rather than contact model providers or other HTTP services.
import http from "node:http";
import https from "node:https";
import http2 from "node:http2";
import net from "node:net";
import { syncBuiltinESMExports } from "node:module";

process.env.PI_OFFLINE = "1";
process.env.PI_SKIP_VERSION_CHECK = "1";

const deny = () => {
	throw new Error("Network access is forbidden in runtime smoke tests");
};

globalThis.fetch = deny;
http.request = http.get = deny;
https.request = https.get = deny;
http2.connect = deny;
net.connect = net.createConnection = net.Socket.prototype.connect = deny;
syncBuiltinESMExports();
