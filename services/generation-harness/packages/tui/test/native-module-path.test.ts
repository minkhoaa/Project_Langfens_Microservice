import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { getNativeModuleCandidates } from "../src/native-module-path.ts";

describe("getNativeModuleCandidates", () => {
	it("never searches package, bundle, or executable directories for native addons", () => {
		assert.deepEqual(getNativeModuleCandidates("native/platform.node"), []);
	});
});
