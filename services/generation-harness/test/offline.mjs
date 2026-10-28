import http from "node:http";
import https from "node:https";
import net from "node:net";
import tls from "node:tls";

// Set offline flags immediately
process.env.GENERATION_HARNESS_OFFLINE = "1";
process.env.GENERATION_HARNESS_TELEMETRY = "0";
process.env.GENERATION_HARNESS_SKIP_VERSION_CHECK = "1";

// Sanitize host provider credentials from the environment to prevent live test execution
const PROVIDER_ENV_VARS = [
	"OPENAI_API_KEY",
	"OPENAI_KEY",
	"ANTHROPIC_API_KEY",
	"ANTHROPIC_KEY",
	"ANTHROPIC_AUTH_TOKEN",
	"ANTHROPIC_OAUTH_TOKEN",
	"GEMINI_API_KEY",
	"GOOGLE_API_KEY",
	"GOOGLE_CLOUD_API_KEY",
	"GOOGLE_CLOUD_PROJECT",
	"GCLOUD_PROJECT",
	"GOOGLE_APPLICATION_CREDENTIALS",
	"AWS_ACCESS_KEY_ID",
	"AWS_SECRET_ACCESS_KEY",
	"AWS_PROFILE",
	"AWS_BEARER_TOKEN_BEDROCK",
	"AWS_SHARED_CREDENTIALS_FILE",
	"AWS_CONFIG_FILE",
	"AZURE_OPENAI_API_KEY",
	"AZURE_OPENAI_BASE_URL",
	"CLOUDFLARE_API_KEY",
	"CLOUDFLARE_ACCOUNT_ID",
	"CLOUDFLARE_GATEWAY_ID",
	"DEEPSEEK_API_KEY",
	"XAI_API_KEY",
	"GROQ_API_KEY",
	"CEREBRAS_API_KEY",
	"HF_TOKEN",
	"TOGETHER_API_KEY",
	"BASETEN_API_KEY",
	"NVIDIA_API_KEY",
	"OPENROUTER_API_KEY",
	"AI_GATEWAY_API_KEY",
	"ZAI_API_KEY",
	"ZAI_CODING_CN_API_KEY",
	"ZAI_CODING_API_KEY",
	"MISTRAL_API_KEY",
	"MINIMAX_API_KEY",
	"MINIMAX_CN_API_KEY",
	"KIMI_API_KEY",
	"MOONSHOT_API_KEY",
	"META_API_KEY",
	"XIAOMI_API_KEY",
	"XIAOMI_TOKEN_PLAN_CN_API_KEY",
	"XIAOMI_TOKEN_PLAN_AMS_API_KEY",
	"XIAOMI_TOKEN_PLAN_SGP_API_KEY",
	"QWEN_TOKEN_PLAN_API_KEY",
	"QWEN_TOKEN_PLAN_CN_API_KEY",
	"OPENCODE_API_KEY",
	"COPILOT_GITHUB_TOKEN",
	"GH_TOKEN",
	"GITHUB_TOKEN",
];

for (const key of PROVIDER_ENV_VARS) {
	delete process.env[key];
}

/**
 * Check if host is loopback/local.
 * Only numeric loopback (127.0.0.0/8, ::1, ::ffff:127.0.0.1, 0.0.0.0)
 * and localhost domains (*.localhost) are permitted.
 * No arbitrary hostname DNS fallback allowed.
 */
export function isAllowedHost(host) {
	if (!host) return true; // Default localhost in node connect
	let str = String(host).trim().toLowerCase();

	// Bracketed IPv6: e.g. "[::1]" or "[::1]:8080" or "[::ffff:127.0.0.1]:80"
	if (str.startsWith("[")) {
		const closingBracket = str.indexOf("]");
		if (closingBracket !== -1) {
			str = str.slice(1, closingBracket);
		}
	} else if (str.includes(":")) {
		// IPv6 contains 2 or more colons; host:port contains exactly one colon
		const colonCount = (str.match(/:/g) || []).length;
		if (colonCount === 1) {
			str = str.split(":")[0];
		}
	}

	// Exact loopback checks
	if (
		str === "localhost" ||
		str === "127.0.0.1" ||
		str === "0.0.0.0" ||
		str === "::1" ||
		str === "::ffff:127.0.0.1" ||
		str.endsWith(".localhost")
	) {
		return true;
	}

	// Any 127.0.0.0/8 IPv4 loopback
	const ipv4Match = str.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
	if (ipv4Match) {
		const first = Number(ipv4Match[1]);
		const second = Number(ipv4Match[2]);
		const third = Number(ipv4Match[3]);
		const fourth = Number(ipv4Match[4]);
		if (
			first === 127 &&
			second >= 0 && second <= 255 &&
			third >= 0 && third <= 255 &&
			fourth >= 0 && fourth <= 255
		) {
			return true;
		}
	}

	return false;
}

function getHostFromFetchInput(input) {
	if (typeof input === "string" || input instanceof URL) {
		try {
			return new URL(String(input)).hostname;
		} catch {
			return String(input);
		}
	}
	if (input && typeof input === "object" && "url" in input) {
		try {
			return new URL(input.url).hostname;
		} catch {
			return input.url;
		}
	}
	return "";
}

function getHostFromHttpArgs(args) {
	while (Array.isArray(args[0])) {
		args = args[0];
	}
	const first = args[0];
	if (typeof first === "string" || first instanceof URL) {
		try {
			return new URL(String(first)).hostname;
		} catch {
			return String(first);
		}
	}
	if (first && typeof first === "object") {
		return first.hostname || first.host || "localhost";
	}
	return "localhost";
}

function extractTargetFromNetConnectArgs(rawArgs) {
	let args = rawArgs;
	while (Array.isArray(args[0])) {
		args = args[0];
	}
	const first = args[0];

	// Form 1: Unix domain socket / named pipe
	if (typeof first === "string" && (first.startsWith("/") || first.startsWith("\\\\") || first.includes(".sock"))) {
		return { type: "pipe", path: first };
	}

	// Form 2: options object
	if (first && typeof first === "object") {
		if (first.path) {
			return { type: "pipe", path: first.path };
		}
		const host = first.host || first.hostname;
		return { type: "tcp", host: host || "localhost", port: first.port };
	}

	// Form 3: port[, host][, options]
	if (typeof first === "number" || (typeof first === "string" && !isNaN(Number(first)))) {
		const port = Number(first);
		let host = "localhost";
		if (typeof args[1] === "string") {
			host = args[1];
			if (args[2] && typeof args[2] === "object") {
				const optHost = args[2].host || args[2].hostname;
				if (optHost) {
					host = optHost;
				}
			}
		} else if (args[1] && typeof args[1] === "object") {
			const optHost = args[1].host || args[1].hostname;
			if (optHost) {
				host = optHost;
			}
		}
		return { type: "tcp", host, port };
	}

	// Unrecognized target: fail closed
	return { type: "unknown", raw: first };
}

export function installNetworkGuard() {
	if (globalThis.__GENERATION_NETWORK_GUARD_INSTALLED__) return;
	globalThis.__GENERATION_NETWORK_GUARD_INSTALLED__ = true;

	// 1. Intercept globalThis.fetch
	const originalFetch = globalThis.fetch;
	if (typeof originalFetch === "function") {
		globalThis.fetch = async function guardedFetch(input, init) {
			const host = getHostFromFetchInput(input);
			if (!isAllowedHost(host)) {
				throw new Error(`[NetworkBlocked] External fetch to ${host} is prohibited in offline test execution.`);
			}
			return originalFetch.call(this, input, init);
		};
	}

	// 2. Intercept http.request and http.get
	const originalHttpRequest = http.request;
	http.request = function guardedHttpRequest(...args) {
		const host = getHostFromHttpArgs(args);
		if (!isAllowedHost(host)) {
			throw new Error(`[NetworkBlocked] External HTTP request to ${host} is prohibited in offline test execution.`);
		}
		return originalHttpRequest.apply(this, args);
	};

	const originalHttpGet = http.get;
	http.get = function guardedHttpGet(...args) {
		const host = getHostFromHttpArgs(args);
		if (!isAllowedHost(host)) {
			throw new Error(`[NetworkBlocked] External HTTP request to ${host} is prohibited in offline test execution.`);
		}
		return originalHttpGet.apply(this, args);
	};

	// 3. Intercept https.request and https.get
	const originalHttpsRequest = https.request;
	https.request = function guardedHttpsRequest(...args) {
		const host = getHostFromHttpArgs(args);
		if (!isAllowedHost(host)) {
			throw new Error(`[NetworkBlocked] External HTTPS request to ${host} is prohibited in offline test execution.`);
		}
		return originalHttpsRequest.apply(this, args);
	};

	const originalHttpsGet = https.get;
	https.get = function guardedHttpsGet(...args) {
		const host = getHostFromHttpArgs(args);
		if (!isAllowedHost(host)) {
			throw new Error(`[NetworkBlocked] External HTTPS request to ${host} is prohibited in offline test execution.`);
		}
		return originalHttpsGet.apply(this, args);
	};

	// 4. Intercept net.Socket.prototype.connect
	const originalSocketConnect = net.Socket.prototype.connect;
	net.Socket.prototype.connect = function guardedSocketConnect(...rawArgs) {
		const target = extractTargetFromNetConnectArgs(rawArgs);
		if (target.type === "pipe") {
			return originalSocketConnect.apply(this, rawArgs);
		}
		if (target.type === "tcp") {
			if (!isAllowedHost(target.host)) {
				throw new Error(`[NetworkBlocked] External TCP connection to ${target.host}${target.port ? `:${target.port}` : ""} is prohibited in offline test execution.`);
			}
			return originalSocketConnect.apply(this, rawArgs);
		}
		throw new Error(`[NetworkBlocked] Unrecognized connection target prohibited in offline test execution: ${String(target.raw)}`);
	};

	// 5. Intercept tls.connect
	const originalTlsConnect = tls.connect;
	tls.connect = function guardedTlsConnect(...rawArgs) {
		const target = extractTargetFromNetConnectArgs(rawArgs);
		if (target.type === "pipe") {
			return originalTlsConnect.apply(this, rawArgs);
		}
		if (target.type === "tcp") {
			if (!isAllowedHost(target.host)) {
				throw new Error(`[NetworkBlocked] External TLS connection to ${target.host}${target.port ? `:${target.port}` : ""} is prohibited in offline test execution.`);
			}
			return originalTlsConnect.apply(this, rawArgs);
		}
		throw new Error(`[NetworkBlocked] Unrecognized TLS connection target prohibited in offline test execution.`);
	};

	// 6. Intercept globalThis.WebSocket if present
	if (typeof globalThis.WebSocket !== "undefined") {
		const OriginalWebSocket = globalThis.WebSocket;
		globalThis.WebSocket = class GuardedWebSocket extends OriginalWebSocket {
			constructor(url, ...rest) {
				const host = getHostFromFetchInput(url);
				if (!isAllowedHost(host)) {
					throw new Error(`[NetworkBlocked] External WebSocket connection to ${host} is prohibited in offline test execution.`);
				}
				super(url, ...rest);
			}
		};
	}
}

// Automatically install network guard when offline.mjs is imported
installNetworkGuard();
