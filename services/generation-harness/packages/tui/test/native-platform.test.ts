import assert from "node:assert/strict";
import { test } from "node:test";
import { getNativeClipboard, getNativePlatformHelper } from "../src/native-platform.ts";

test("native clipboard helpers are unavailable and callers can use platform fallbacks", () => {
	assert.equal(getNativePlatformHelper(), undefined);
	assert.equal(getNativeClipboard(), undefined);
});
