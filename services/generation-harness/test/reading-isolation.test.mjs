import "./offline.mjs";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmodSync, existsSync, linkSync, mkdtempSync, readdirSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test, { after } from "node:test";
import { runtimeLaunch, harnessRoot, ownedSubagentEntry } from "../scripts/runtime.mjs";
import { studentProjection } from "../.generation/reading/projection.ts";
import { exam } from "../.generation/fixtures/reading.mjs";
import { checkedPath, latestAnswer } from "../.generation/reading/scopes.ts";
import { AgentSessionRuntime, createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } from "generation-harness-core";
import { InMemoryCredentialStore, fauxAssistantMessage, fauxProvider, fauxToolCall } from "generation-ai";
// Native Subagents snapshots its temporary root at module load. Isolate it
// before import so workflow receipts/retention never touch shared runtime state.
const priorSubagentTemp = process.env.GENERATION_SUBAGENTS_TEMP_ROOT;
const subagentTemp = mkdtempSync(join(tmpdir(), "reading-subagents-"));
process.env.GENERATION_SUBAGENTS_TEMP_ROOT = subagentTemp;
const { discoverAgents, executeSubagent } = await import("generation-subagents");
after(() => {
  rmSync(subagentTemp, { recursive: true, force: true });
  if (priorSubagentTemp === undefined) delete process.env.GENERATION_SUBAGENTS_TEMP_ROOT;
  else process.env.GENERATION_SUBAGENTS_TEMP_ROOT = priorSubagentTemp;
});

async function legacyPolicy(action) {
  const assigned = process.env.GENERATION_HARNESS_READING_WORKSPACE;
  delete process.env.GENERATION_HARNESS_READING_WORKSPACE;
  try { return await action(); }
  finally { if (assigned === undefined) delete process.env.GENERATION_HARNESS_READING_WORKSPACE; else process.env.GENERATION_HARNESS_READING_WORKSPACE = assigned; }
}

async function nativeFixture(t, afterGuard, environment = {}) {
  const temp = mkdtempSync(join(tmpdir(), "reading-native-isolation-"));
  writeFileSync(join(temp, "passage.md"), "Approved input passage");
  const launch = runtimeLaunch(["--reading", "--reading-input", join(temp, "passage.md")], { GENERATION_HARNESS_RUNTIME_DIR: temp, ...environment });
  const previous = new Map(Object.keys(launch.env).map(key => [key, process.env[key]]));
  let host;
  Object.assign(process.env, launch.env);
  t.after(async () => {
    try { await host?.session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" }); }
    finally { host?.dispose(); }
    for (const [key, value] of previous) {
      if (value === undefined) delete process.env[key]; else process.env[key] = value;
    }
    rmSync(temp, { recursive: true, force: true });
  });
  const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
  const faux = fauxProvider({ models: [{ id: "reading" }] }); runtime.registerNativeProvider(faux.provider);
  const agentDir = launch.env.GENERATION_HARNESS_AGENT_DIR;
  async function createRuntime({ cwd, sessionManager, sessionStartEvent }) {
    const settingsManager = SettingsManager.create(cwd, agentDir);
    const loader = new DefaultResourceLoader({ cwd, agentDir, settingsManager, noContextFiles: true,
      systemPrompt: launch.args[launch.args.indexOf("--system-prompt") + 1],
      additionalExtensionPaths: [ownedSubagentEntry(), join(harnessRoot, ".generation/reading/workspace-guard.ts")], extensionFactories: afterGuard ? [afterGuard] : [] });
    await loader.reload(); assert.deepEqual(loader.getExtensions().errors, []);
    const created = await createAgentSession({ cwd, agentDir, modelRuntime: runtime, model: faux.getModel("reading"), resourceLoader: loader, sessionManager, sessionStartEvent });
    return { ...created, services: { cwd, agentDir, settingsManager, modelRuntime: runtime, resourceLoader: loader, diagnostics: [] }, diagnostics: [] };
  }
  const initial = await createRuntime({ cwd: launch.cwd, sessionManager: SessionManager.inMemory(launch.cwd) });
  host = new AgentSessionRuntime(initial.session, initial.services, createRuntime);
  const bindings = { mode: "rpc", commandContextActions: {
    waitForIdle: () => host.session.waitForIdle(),
    newSession: options => host.newSession(options),
    switchSession: (path, options) => host.switchSession(path, options),
  } };
  host.setRebindSession(session => session.bindExtensions(bindings));
  await host.session.bindExtensions(bindings);
  let sequence = 0;
  async function call(name, args) {
    const id = `isolation-${sequence++}`; let result;
    faux.setResponses([ctx => {
      const system = JSON.stringify(ctx.messages.filter(m => m.role === "system"));
      assert.match(system, /IELTS Academic Reading author and editor/);
      assert.doesNotMatch(system, /You are an expert coding assistant/);
      return fauxAssistantMessage(fauxToolCall(name, args, { id }), { stopReason: "toolUse" });
    }, ctx => {
      result = ctx.messages.find(m => m.role === "toolResult" && m.toolCallId === id);
      return fauxAssistantMessage("offline done");
    }]);
    await host.session.prompt("Revise the IELTS artifact offline."); assert.ok(result); return result;
  }
  return { temp, launch, call, faux, session: host.session, runtime, host };
}

test("native parent can revise artifacts but cannot cross the workspace boundary", async t => {
  const { launch, call, session, temp } = await nativeFixture(t);
  for (const name of ["read", "bash", "edit", "write"]) assert.ok(session.getActiveToolNames().includes(name), JSON.stringify({ active: session.getActiveToolNames(), all: session.getAllTools().map(t => t.name) }));
  assert.equal((await call("write", { path: "drafts/exam.json", content: '{"passage":"v1","key":"one"}' })).isError, false);
  assert.equal((await call("edit", { path: "drafts/exam.json", edits: [{ oldText: "v1", newText: "v2" }] })).isError, false);
  assert.equal((await call("edit", { path: "drafts/exam.json", edits: [{ oldText: "one", newText: "two" }] })).isError, false);
  assert.match(JSON.stringify((await call("read", { path: "drafts/exam.json" })).content), /v2/);
  assert.match(readFileSync(join(launch.cwd, "drafts/exam.json"), "utf8"), /"key":"two"/);
  assert.match(JSON.stringify((await call("read", { path: "input/0-passage.md" })).content), /Approved input passage/);
  assert.equal((await call("write", { path: "input/0-passage.md", content: "overwritten" })).isError, true);
  assert.equal((await call("write", { path: "reviews/semantic.json", content: '{"verdict":"UNCERTAIN","requiresHumanAdjudication":true}' })).isError, false);
  assert.equal(JSON.parse(readFileSync(join(launch.cwd, "reviews/semantic.json"), "utf8")).verdict, "UNCERTAIN");
  const outside = join(temp, "secret.txt"); writeFileSync(outside, "PROTECTED-SENTINEL");
  symlinkSync(outside, join(launch.cwd, "drafts/escape"));
  linkSync(outside, join(launch.cwd, "drafts/hardlink.txt"));
  symlinkSync(temp, join(launch.cwd, "drafts/directory-escape"));
  const protectedSource = join(harnessRoot, "package.json");
  const originalSource = readFileSync(protectedSource, "utf8");
  const forbidden = ["drafts/hardlink.txt", outside, "../secret.txt", ".generation/settings.json", protectedSource, "drafts/escape", "drafts/directory-escape/secret.txt", "drafts/directory-escape/new.json"];
  for (const path of forbidden) {
    for (const name of ["read", "write", "edit"]) {
      // Repository-target probes are non-destructive even if a guard regresses.
      const unchanged = path === protectedSource ? originalSource : path === ".generation/settings.json" ? readFileSync(join(launch.cwd, path), "utf8") : undefined;
      const result = await call(name, { path, content: unchanged ?? "OVERWRITTEN", edits: [{ oldText: unchanged ?? "PROTECTED", newText: unchanged ?? "OVERWRITTEN" }] });
      assert.equal(result.isError, true, `${name}: ${path}`);
      assert.doesNotMatch(JSON.stringify(result.content), /PROTECTED-SENTINEL/);
    }
  }
  for (const path of ["input/new.json", ".history/run.json", "drafts/../reviews/x", "drafts/code.ts", "drafts/.generation/config.json"]) {
    assert.equal((await call("write", { path, content: "denied" })).isError, true, path);
  }
  for (const command of [`echo hacked > ${outside}`, `printf hacked > drafts/exam.json`, "ls; touch drafts/evil", "ls $(cat /etc/passwd)", "python -c 'open(\"x\",\"w\")'", "env", "cat /etc/passwd", "ls ../", "ls .generation"]) {
    assert.equal((await call("bash", { command })).isError, true, command);
  }
  const directShell = await session.extensionRunner.emitUserBash({ type: "user_bash", command: `echo hacked > ${outside}`, cwd: launch.cwd, excludeFromContext: false });
  assert.equal(directShell.result.exitCode, 1);
  assert.equal(readFileSync(outside, "utf8"), "PROTECTED-SENTINEL");
  assert.equal(readFileSync(protectedSource, "utf8"), originalSource);
  const history = readdirSync(join(launch.cwd, ".history")).filter(f => f.endsWith(".json"));
  assert.ok(history.some(f => readFileSync(join(launch.cwd, ".history", f), "utf8").includes("v1")));
  assert.ok(history.some(f => readFileSync(join(launch.cwd, ".history", f), "utf8").includes("v2")));
  const spec = await call("get_question_spec", { type: "SUMMARY_COMPLETION" }); assert.ok(!spec.isError);
  const diagnostics = readdirSync(join(launch.cwd, "reviews")).filter(f => f.startsWith("validation-"));
  assert.ok(diagnostics.length);
  const review = JSON.parse(readFileSync(join(launch.cwd, "reviews", diagnostics[0]), "utf8"));
  assert.equal(review.details.status, "PASS");
  assert.equal(review.accepted, false); assert.equal(review.published, false);
  assert.equal(review.next, "REVIEW_OR_HUMAN_ADJUDICATION");
  assert.equal((await call("write", { path: `reviews/${diagnostics[0]}`, content: "tampered" })).isError, true);
});

test("/reading-new creates a distinct native session cwd without importing previous artifacts", async t => {
  const { host, launch, call, faux } = await nativeFixture(t);
  await call("write", { path: "drafts/previous.md", content: "PREVIOUS_SESSION_SENTINEL" });
  const previousId = host.session.sessionId, previousCwd = host.cwd, count = faux.state.callCount;
  faux.setResponses([fauxAssistantMessage("NOT_A_COMMAND")]);
  await host.session.prompt("/reading-new");
  assert.equal(faux.state.callCount, count, "Session rotation is an operator command, not inference");
  assert.notEqual(host.session.sessionId, previousId); assert.notEqual(host.cwd, previousCwd);
  assert.ok(host.cwd.startsWith(join(launch.runtime, "reading-runs") + "/"));
  assert.equal(host.session.sessionManager.getCwd(), host.cwd);
  assert.deepEqual(host.session.messages, []);
  assert.equal(existsSync(join(host.cwd, "drafts/previous.md")), false);
  assert.equal(readFileSync(join(previousCwd, "drafts/previous.md"), "utf8"), "PREVIOUS_SESSION_SENTINEL");
  assert.equal((await call("read", { path: join(previousCwd, "drafts/previous.md") })).isError, true);
  assert.equal((await call("write", { path: "drafts/new.md", content: "New session" })).isError, false);
  assert.equal((await call("read", { path: join(harnessRoot, "package.json") })).isError, true);
});

test("native /new cannot silently reuse a Reading folder and foreign resumes/forks stay blocked", async t => {
  const { host, launch, call } = await nativeFixture(t);
  await call("write", { path: "drafts/passage.md", content: "Retained draft" });
  const previousId = host.session.sessionId;
  assert.ok(host.session.messages.length > 0);
  const historyBefore = readdirSync(join(launch.cwd, ".history"));
  const messagesBefore = structuredClone(host.session.messages);

  assert.deepEqual(await host.newSession(), { cancelled: true });
  assert.equal(host.session.sessionId, previousId);
  assert.deepEqual(host.session.messages, messagesBefore);
  assert.equal(host.cwd, launch.cwd);
  assert.deepEqual(readdirSync(join(launch.cwd, ".history")), historyBefore);
  assert.equal(readFileSync(join(launch.cwd, "drafts/passage.md"), "utf8"), "Retained draft");
  for (const name of ["read", "bash", "edit", "write"]) assert.ok(host.session.getActiveToolNames().includes(name));
  assert.match(JSON.stringify((await call("read", { path: "drafts/passage.md" })).content), /Retained draft/);
  assert.equal((await call("write", { path: "revisions/passage.md", content: "Revised draft" })).isError, false);
  assert.equal((await call("read", { path: join(harnessRoot, "package.json") })).isError, true);
  assert.equal((await call("write", { path: "../escape.json", content: "blocked" })).isError, true);
  assert.deepEqual(await host.switchSession(join(launch.cwd, ".sessions/unapproved.jsonl")), { cancelled: true });
  assert.equal((await host.session.extensionRunner.emit({ type: "session_before_fork", entryId: "unused", position: "at" })).cancel, true);
  assert.deepEqual(await host.newSession(), { cancelled: true });
  assert.equal(host.session.sessionId, previousId);
});

test("parent rejects alternate subagents, workflows and cwd/context overrides", async t => {
  const { call } = await nativeFixture(t);
  for (const args of [
    { agent: "coder", task: "read source" },
    { agent: "reading-generator", task: "draft", cwd: harnessRoot },
    { agent: "reading-generator", task: "draft", options: { context: "inherit" } },
    { workflow: true }, { action: "project.open" },
    { agent: "blind-solver", task: '{"answerKey":"secret"}', options: { reading: { profile: "strict-blind" } } },
  ]) {
    const result = await call("subagent", args);
    assert.equal(result.isError, true);
    assert.match(JSON.stringify(result.content), /READING_POLICY/);
  }
});

test("permitted native delegation is pinned fresh and local before child execution", async t => {
  let observed;
  const { launch, call } = await nativeFixture(t, api => api.on("tool_call", event => {
    if (event.toolName !== "subagent") return;
    observed = structuredClone(event.input);
    // Stop at the actual child-execution boundary: no subprocess provider needed.
    return { block: true, reason: "OFFLINE_LAUNCH_BOUNDARY" };
  }));
  const result = await call("subagent", { agent: "reading-generator", task: "Draft a passage." });
  assert.match(JSON.stringify(result.content), /OFFLINE_LAUNCH_BOUNDARY/);
  assert.ok(observed.cwd.startsWith(join(launch.cwd, "children") + "/"));
  assert.equal(observed.async, false); assert.equal(observed.worktree, false);
  assert.deepEqual(observed.options, { context: "fresh", agentScope: "project", share: false, artifacts: false, acceptance: false, sessionDir: join(launch.cwd, ".sessions") });
});

test("authoring solver accepts natural task and file input in its own child workspace", async t => {
  let observed;
  const { launch, call } = await nativeFixture(t, api => api.on("tool_call", event => {
    if (event.toolName !== "subagent") return;
    observed = structuredClone(event.input);
    return { block: true, reason: "SCOPED_AUTHORING_BOUNDARY" };
  }));
  assert.equal((await call("write", { path: "artifacts/public/passage.md", content: "The canal opened in 1902." })).isError, false);
  const result = await call("subagent", { agent: "blind-solver", task: "Read the provided passage and answer the questions.",
    options: { reading: { inputs: ["artifacts/public/passage.md"] } } });
  assert.match(JSON.stringify(result.content), /SCOPED_AUTHORING_BOUNDARY/);
  assert.ok(observed.cwd.startsWith(join(launch.cwd, "children") + "/"));
  const childRoot = dirname(dirname(observed.output));
  assert.equal(readFileSync(join(childRoot, "inputs/0-passage.md"), "utf8"), "The canal opened in 1902.");
  assert.equal(observed.cwd, join(childRoot, "workspace"));
  assert.ok(existsSync(join(childRoot, "outputs")));
});

test("scoped authoring solver reads its inputs, writes answers and cannot read keys or siblings", { timeout: 15000 }, async t => {
  const { launch, call, session, faux } = await nativeFixture(t);
  await call("write", { path: "artifacts/public/passage.md", content: "The canal opened in 1902." });
  await call("write", { path: "artifacts/private/key.json", content: '{"answer":"PRIVATE-KEY-1903"}' });
  const sibling = join(launch.cwd, "children/sibling/workspace");
  (await import("node:fs")).mkdirSync(sibling, { recursive: true }); writeFileSync(join(sibling, "secret.md"), "SIBLING-SECRET");
  let result, childRoot;
  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === "user").at(-1)?.content[0]?.text;
    if (prompt === "Exercise scoped solver.") {
      result = ctx.messages.find(m => m.role === "toolResult" && m.toolName === "subagent");
      return result ? fauxAssistantMessage("DONE") : fauxAssistantMessage(fauxToolCall("subagent", { agent: "blind-solver", task: "Read the assigned passage and solve independently.", options: { reading: { inputs: ["artifacts/public/passage.md"] } } }), { stopReason: "toolUse" });
    }
    const serialized = JSON.stringify(ctx.messages);
    assert.doesNotMatch(serialized, /PRIVATE-KEY-1903|SIBLING-SECRET/);
    const results = ctx.messages.filter(m => m.role === "toolResult");
    if (!results.length) {
      const system = ctx.messages.filter(m => m.role === "system").map(m => JSON.stringify(m)).join("\n");
      const scope = readdirSync(join(launch.cwd, "children")).find(name => name !== "sibling");
      childRoot = join(launch.cwd, "children", scope);
      assert.ok(system.includes("UNVERIFIED"));
      symlinkSync(join(launch.cwd, "artifacts/private/key.json"), join(childRoot, "workspace/escape.json"));
      linkSync(join(launch.cwd, "artifacts/private/key.json"), join(childRoot, "workspace/hardlink.json"));
      return fauxAssistantMessage([
        fauxToolCall("read", { path: "inputs/0-passage.md" }, { id: "public" }),
        fauxToolCall("read", { path: join(launch.cwd, "artifacts/private/key.json") }, { id: "key" }),
        fauxToolCall("read", { path: join(sibling, "secret.md") }, { id: "sibling" }),
        fauxToolCall("read", { path: "../artifacts/private/key.json" }, { id: "traversal" }),
        fauxToolCall("read", { path: "workspace/escape.json" }, { id: "symlink" }),
        fauxToolCall("read", { path: "workspace/hardlink.json" }, { id: "hardlink" }),
        fauxToolCall("read", { path: join(harnessRoot, "package.json") }, { id: "source" }),
        fauxToolCall("write", { path: "inputs/new.md", content: "tamper" }, { id: "input-write" }),
        fauxToolCall("write", { path: "outputs/answer.json", content: '{"answer":"1902"}' }, { id: "answer" }),
        fauxToolCall("write", { path: "draft.md", content: "Relative to my working directory" }, { id: "relative-write" }),
      ], { stopReason: "toolUse" });
    }
    assert.match(JSON.stringify(results.find(r => r.toolCallId === "public").content), /1902/);
    assert.equal(results.find(r => r.toolCallId === "answer").isError, false);
    assert.equal(results.find(r => r.toolCallId === "relative-write").isError, false);
    for (const id of ["key", "sibling", "traversal", "symlink", "hardlink", "source", "input-write"]) assert.equal(results.find(r => r.toolCallId === id).isError, true, id);
    return fauxAssistantMessage('{"answer":"1902","mocked":true}');
  };
  faux.setResponses(Array(6).fill(respond));
  await session.prompt("Exercise scoped solver.");
  assert.ok(result, JSON.stringify(session.messages.at(-1)));
  assert.equal(result.isError, false, JSON.stringify(result));
  const attempt = result.details.reading.attempts[0];
  assert.equal(attempt.blindness, "UNVERIFIED"); assert.equal(attempt.independentBlindEvidence, false); assert.equal(attempt.frozen, true);
  const receipt = JSON.parse(readFileSync(join(launch.cwd, ".history/attempts", `${attempt.id}.json`), "utf8"));
  assert.match(receipt.answer, /1902/); assert.equal(receipt.accepted, false);
  assert.equal(JSON.parse(readFileSync(join(childRoot, "outputs/answer.json"), "utf8")).answer, "1902");
});

test("specialist bash stays in the child Bubblewrap mount and cannot traverse to the parent", { timeout: 15000 }, async t => {
  const { launch, call, session, faux } = await nativeFixture(t);
  await call("write", { path: "artifacts/public/passage.md", content: "Public child passage" });
  await call("write", { path: "artifacts/private/key.json", content: "PARENT_KEY_NOT_MOUNTED" });
  const bwrap = launch.env.GENERATION_HARNESS_READING_BWRAP;
  const baseline = bwrap && existsSync(bwrap) ? spawnSync(bwrap, ["--unshare-all", ...["/usr", "/bin", "/lib", "/lib64"].filter(existsSync).flatMap(path => ["--ro-bind", path, path]), "--", "/bin/true"], { timeout: 3000 }) : { status: null };
  let result;
  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === "user").at(-1)?.content[0]?.text;
    if (prompt === "Exercise specialist shell scope.") {
      result = ctx.messages.find(m => m.role === "toolResult" && m.toolName === "subagent");
      return result ? fauxAssistantMessage("DONE") : fauxAssistantMessage(fauxToolCall("subagent", { agent: "reading-generator", task: "Inspect the public files in your own sandbox.", options: { reading: { inputs: ["artifacts/public/passage.md"] } } }), { stopReason: "toolUse" });
    }
    const results = ctx.messages.filter(m => m.role === "toolResult");
    if (!results.length) return fauxAssistantMessage([
      fauxToolCall("bash", { command: "pwd" }, { id: "pwd" }),
      fauxToolCall("bash", { command: "ls inputs" }, { id: "inputs" }),
      fauxToolCall("bash", { command: `ls ${launch.cwd}/artifacts/private` }, { id: "parent" }),
      fauxToolCall("bash", { command: "ls ../" }, { id: "up" }),
      fauxToolCall("bash", { command: "printf changed > workspace/file.md" }, { id: "write" }),
    ], { stopReason: "toolUse" });
    if (baseline.status === 0) {
      assert.equal(results.find(r => r.toolCallId === "pwd").isError, false);
      assert.match(JSON.stringify(results.find(r => r.toolCallId === "pwd").content), /\/work/);
      assert.match(JSON.stringify(results.find(r => r.toolCallId === "inputs").content), /0-passage.md/);
    } else assert.equal(results.find(r => r.toolCallId === "pwd").isError, true);
    for (const id of ["parent", "up", "write"]) assert.equal(results.find(r => r.toolCallId === id).isError, true);
    assert.doesNotMatch(JSON.stringify(ctx.messages), /PARENT_KEY_NOT_MOUNTED/);
    return fauxAssistantMessage("Scoped inspection complete");
  };
  faux.setResponses(Array(6).fill(respond)); await session.prompt("Exercise specialist shell scope.");
  assert.ok(result); assert.equal(result.isError, false, JSON.stringify(result));
});

test("scope guards reject Unicode-space aliases before native tools normalize them", async t => {
  const { mkdirSync } = await import("node:fs");
  const temp = mkdtempSync(join(tmpdir(), "reading-path-normalization-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const root = join(temp, "child"), outside = join(temp, "private");
  mkdirSync(join(root, "workspace"), { recursive: true }); mkdirSync(outside);
  symlinkSync(outside, join(root, "workspace/alias "));
  assert.throws(() => checkedPath(root, "workspace/alias\u00a0/escape.md"), /READING_POLICY/);
});

test("tool-use, truncated and aborted responses cannot authorize answer-key exposure", () => {
  for (const stopReason of ["toolUse", "length", "error", "aborted"]) {
    const result = latestAnswer([{ type: "message", message: { role: "assistant", stopReason, content: [{ type: "text", text: "Unfinished draft answer" }] } }]);
    assert.equal(result.completed, false, stopReason);
  }
  assert.equal(latestAnswer([{ type: "message", message: { role: "assistant", stopReason: "stop", content: [{ type: "text", text: "Completed answer" }] } }]).completed, true);
});

test("key debugging requires operator approval, freezes NON_BLIND evidence and rechecks in a fresh strict scope", { timeout: 20000 }, async t => {
  const { launch, call, session, faux } = await nativeFixture(t);
  await call("write", { path: "artifacts/public/projection.json", content: JSON.stringify(studentProjection(exam())) });
  await call("write", { path: "artifacts/private/key.json", content: '{"answer":"three","mocked":true}' });
  async function leaf(request, answer, inspect) {
    let result;
    const respond = ctx => {
      const prompt = ctx.messages.filter(m => m.role === "user").at(-1)?.content[0]?.text;
      if (prompt === "Execute scoped leaf.") {
        const current = ctx.messages.slice(ctx.messages.findLastIndex(m => m.role === "user"));
        result = current.find(m => m.role === "toolResult" && m.toolName === "subagent");
        return result ? fauxAssistantMessage("DONE") : fauxAssistantMessage(fauxToolCall("subagent", request), { stopReason: "toolUse" });
      }
      inspect?.(ctx);
      return fauxAssistantMessage(answer);
    };
    faux.setResponses(Array(5).fill(respond)); await session.prompt("Execute scoped leaf.");
    assert.ok(result); assert.equal(result.isError, false, JSON.stringify(result));
    return result.details.reading.attempts[0];
  }
  const original = await leaf({ agent: "blind-solver", task: "Solve from the assigned public projection without the key.", options: { reading: { inputs: ["artifacts/public/projection.json"] } } }, '{"answer":"two","mocked":true}', ctx => {
    assert.doesNotMatch(JSON.stringify(ctx.messages), /\"answer\":\"three\"/);
  });
  assert.equal(original.frozen, true); assert.equal(original.blindness, "UNVERIFIED");
  const frozenPath = join(launch.cwd, ".history/attempts", `${original.id}.json`), frozen = readFileSync(frozenPath, "utf8");
  const noGrant = await call("subagent", { agent: "blind-solver", task: "Compare with a key", options: { reading: { profile: "debug" } } });
  assert.equal(noGrant.isError, true);
  const count = faux.state.callCount;
  await session.prompt(`/reading-debug ${JSON.stringify({ attemptId: original.id, keys: ["artifacts/private/key.json"] })}`);
  assert.equal(faux.state.callCount, count, "Approving a debug grant is an operator command, not inference");
  const grant = readdirSync(join(launch.cwd, ".history/debug-grants"))[0].replace(".json", "");
  await call("write", { path: "artifacts/private/key.json", content: '{"answer":"changed-after-approval"}' });
  await call("write", { path: join(original.workspace, "outputs/result.md"), content: "REWRITTEN_OUTPUT_NOT_FROZEN_EVIDENCE" });
  const debug = await leaf({ agent: "blind-solver", task: "Compare the frozen solve, passage and selected key; propose a correction or UNCERTAIN. Do not assume the key is right.", options: { reading: { profile: "debug", debugGrant: grant } } }, '{"verdict":"UNCERTAIN","proposedKey":"two","mocked":true}', ctx => {
    assert.match(JSON.stringify(ctx.messages), /NON_BLIND/);
  });
  assert.equal(debug.blindness, "NON_BLIND"); assert.equal(debug.independentBlindEvidence, false); assert.equal(debug.debugOf, original.id);
  assert.notEqual(debug.id, original.id); assert.notEqual(debug.workspace, original.workspace);
  assert.match(readFileSync(join(debug.workspace, "inputs/key-0-key.json"), "utf8"), /three/);
  assert.doesNotMatch(readFileSync(join(debug.workspace, "inputs/key-0-key.json"), "utf8"), /changed-after-approval/);
  assert.equal(JSON.parse(readFileSync(join(debug.workspace, "inputs/original-solve.json"), "utf8")).answer, '{"answer":"two","mocked":true}');
  assert.equal(readFileSync(frozenPath, "utf8"), frozen);
  const debugReceipt = JSON.parse(readFileSync(join(launch.cwd, ".history/attempts", `${debug.id}.json`), "utf8"));
  assert.match(debugReceipt.answer, /UNCERTAIN/); assert.equal(debugReceipt.accepted, false); assert.equal(debugReceipt.published, false);
  for (const request of [
    { agent: "blind-solver", task: "Reuse grant", options: { reading: { profile: "debug", debugGrant: grant } } },
    { agent: "blind-solver", task: JSON.stringify(studentProjection(exam())), options: { reading: { profile: "strict-blind", debugGrant: grant } } },
    { agent: "blind-solver", task: "Read keys as input", options: { reading: { inputs: ["artifacts/private/key.json"] } } },
  ]) assert.equal((await call("subagent", request)).isError, true);
  const recheck = await leaf({ agent: "blind-solver", task: "Recheck the selected public exam version.", options: { reading: { profile: "strict-blind", inputs: ["artifacts/public/projection.json"], recheckOf: debug.id } } }, '{"answer":"two","mocked":true}', ctx => {
    const users = ctx.messages.filter(m => m.role === "user");
    assert.equal(users.length, 1); assert.equal(users[0].content[0].text, JSON.stringify(studentProjection(exam())));
    assert.doesNotMatch(JSON.stringify(ctx.messages), /proposedKey|answer\\\":\\\"three/);
  });
  assert.equal(recheck.blindness, "STRUCTURAL_ONLY"); assert.equal(recheck.independentBlindEvidence, true);
  assert.equal(recheck.recheckOf, debug.id); assert.notEqual(recheck.id, original.id); assert.notEqual(recheck.id, debug.id);
  assert.equal(readdirSync(join(recheck.workspace, "inputs")).some(name => name.startsWith("key-")), false);
  const recheckReceipt = JSON.parse(readFileSync(join(launch.cwd, ".history/attempts", `${recheck.id}.json`), "utf8"));
  assert.notEqual(recheckReceipt.nativeSessionId, debugReceipt.nativeSessionId);
  assert.equal(recheckReceipt.ieltsQualityEstablished, false);
});

test("Reading allows the native parallel resource with pinned child permissions", async t => {
  let observed;
  const { launch, call } = await nativeFixture(t, api => api.on("tool_call", event => {
    if (event.toolName !== "subagent") return;
    observed = structuredClone(event.input);
    return { block: true, reason: "OFFLINE_PARALLEL_BOUNDARY" };
  }));
  const tasks = [{ agent: "semantic-reviewer", task: "Review wording independently." }, { agent: "blind-solver", task: JSON.stringify(studentProjection(exam())) }];
  const result = await call("subagent", { workflow: "parallel", args: { tasks } });
  assert.match(JSON.stringify(result.content), /OFFLINE_PARALLEL_BOUNDARY/);
  assert.equal(observed.workflow, "reading.plan");
  const children = observed.args.stages[0];
  assert.deepEqual(children.map(({ agent, task }) => ({ agent, task })), tasks);
  assert.notEqual(children[0].cwd, children[1].cwd);
  assert.ok(children.every(child => child.cwd.startsWith(join(launch.cwd, "children") + "/")));
  assert.equal(observed.cwd, launch.cwd);
  assert.equal(observed.async, false); assert.equal(observed.worktree, false);
  assert.deepEqual(observed.options, { context: "fresh", agentScope: "project", share: false, artifacts: false, acceptance: false, sessionDir: join(launch.cwd, ".sessions") });
});

test("Reading rejects the entire parallel batch when any child or control is unsafe", async t => {
  let reachedExecutor = 0;
  const { call } = await nativeFixture(t, api => api.on("tool_call", event => {
    if (event.toolName !== "subagent") return;
    reachedExecutor++;
    return { block: true, reason: "UNEXPECTED_EXECUTION" };
  }));
  const valid = { agent: "semantic-reviewer", task: "Independent review." };
  for (const child of [
    { agent: "coder", task: "Code" }, { agent: "blind-solver", task: '{"answerKey":"secret"}', options: { reading: { profile: "strict-blind" } } },
    { ...valid, cwd: harnessRoot }, { ...valid, output: "../escape.md" }, { ...valid, tools: ["bash"] },
    { ...valid, options: { context: "fork" } }, { ...valid, task: " " },
  ]) {
    const result = await call("subagent", { workflow: "parallel", args: { tasks: [valid, child] } });
    assert.equal(result.isError, true); assert.match(JSON.stringify(result.content), /READING_POLICY/);
  }
  for (const args of [
    { workflow: "parallel", args: { tasks: [] } },
    { workflow: "parallel", args: { tasks: Array.from({ length: 9 }, () => valid) } },
    { workflow: "parallel", args: { tasks: [valid], script: "return runs.host('x',{});" } },
    { workflow: "parallel", args: { tasks: [valid] }, options: { script: "unsafe" } },
    { workflow: "parallel", args: { tasks: [valid] }, cwd: harnessRoot },
    { workflow: "run-ci", args: { command: "npm test" } },
    { workflow: "./drafts/workflow.js", args: { tasks: [valid] } },
    { workflow: true, args: { tasks: [valid] } },
  ]) {
    const result = await call("subagent", args);
    assert.equal(result.isError, true); assert.match(JSON.stringify(result.content), /READING_POLICY/);
  }
  assert.equal(reachedExecutor, 0);
});

test("Reading JSON plans sequence native stages with explicit handoffs and scoped model/output/cwd", { timeout: 15000 }, async t => {
  const { launch, call, session, faux } = await nativeFixture(t);
  const plan = { steps: [
    { agent: "reading-generator", task: "GENERATE_STAGE", model: "faux/reading", cwd: "scratch", output: "draft.md" },
    { agent: "question-validator", task: "VALIDATE_STAGE", options: { reading: { previous: true } } },
    { parallel: [{ agent: "semantic-reviewer", task: "REVIEW_A" }, { agent: "semantic-reviewer", task: "REVIEW_B" }] },
  ] };
  assert.equal((await call("write", { path: "workflows/section.json", content: JSON.stringify(plan) })).isError, false);
  const starts = [], roots = new Set(); let result;
  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === "user").at(-1)?.content[0]?.text;
    if (prompt === "Execute the saved Reading plan.") {
      result = ctx.messages.find(m => m.role === "toolResult" && m.toolName === "subagent");
      return result ? fauxAssistantMessage("DONE") : fauxAssistantMessage(fauxToolCall("subagent", { workflow: "./workflows/section.json" }), { stopReason: "toolUse" });
    }
    assert.equal(ctx.messages.filter(m => m.role === "user").length, 1);
    const task = prompt.replace(/^Task: /, ""); starts.push(task);
    const scopes = readdirSync(join(launch.cwd, ".history/scopes")).map(name => JSON.parse(readFileSync(join(launch.cwd, ".history/scopes", name), "utf8")));
    const scope = scopes.find(scope => task === scope.task || task.startsWith(scope.task + "\n\nAuthorized previous stage output:\n"));
    assert.ok(scope); roots.add(scope.root);
    if (task === "GENERATE_STAGE") {
      assert.equal(starts.length, 1); assert.equal(scope.cwd, join(scope.root, "workspace/scratch"));
      return fauxAssistantMessage("GENERATED_PUBLIC_ARTIFACT");
    }
    if (task.startsWith("VALIDATE_STAGE")) {
      assert.equal(starts[0], "GENERATE_STAGE"); assert.match(task, /GENERATED_PUBLIC_ARTIFACT/);
      return fauxAssistantMessage("VALIDATED_ARTIFACT");
    }
    assert.ok(starts.some(task => task.startsWith("VALIDATE_STAGE")));
    assert.ok(["REVIEW_A", "REVIEW_B"].includes(task));
    return fauxAssistantMessage("Independent review " + task);
  };
  faux.setResponses(Array(8).fill(respond)); await session.prompt("Execute the saved Reading plan.");
  assert.ok(result); assert.equal(result.isError, false, JSON.stringify(result)); assert.equal(roots.size, 4);
  const audits = result.details.reading.attempts;
  assert.equal(audits.length, 4); assert.ok(audits.every(attempt => attempt.frozen));
  assert.equal((await call("subagent", { workflow: "reading.plan", args: { steps: [{ agent: "blind-solver", task: "Use prior key", options: { reading: { previous: true } } }] } })).isError, true);
});

test("Reading native parallel children overlap, preserve order and keep blind inputs separate", { timeout: 15000 }, async t => {
  const { session, faux } = await nativeFixture(t);
  const projection = JSON.stringify(studentProjection(exam()));
  const tasks = [{ agent: "semantic-reviewer", task: "Review wording. PRIVATE-REVIEW-SENTINEL" }, { agent: "blind-solver", task: projection }];
  let starts = 0, active = 0, maxActive = 0, result;
  const gate = Promise.withResolvers();
  const deadline = setTimeout(() => gate.resolve(), 5000);
  const respond = async ctx => {
    const users = ctx.messages.filter(m => m.role === "user");
    const text = users.at(-1)?.content[0]?.text;
    // Reviewers retain the native task envelope; the blind guard canonicalizes
    // its fixed envelope before any provider request.
    const prompt = text?.startsWith("Task: ") ? text.slice(6) : text;
    if (prompt === "Run independent Reading reviewers in parallel.") {
      result = ctx.messages.find(m => m.role === "toolResult" && m.toolName === "subagent");
      return result ? fauxAssistantMessage("PARENT_DONE") : fauxAssistantMessage(fauxToolCall("subagent", { workflow: "parallel", args: { tasks } }), { stopReason: "toolUse" });
    }
    assert.equal(users.length, 1);
    assert.ok(tasks.some(task => task.task === prompt), JSON.stringify({ prompt, users }));
    if (prompt === projection) {
      assert.equal(text, projection);
      assert.doesNotMatch(JSON.stringify(ctx.messages), /PRIVATE-REVIEW-SENTINEL/);
    }
    starts++; active++; maxActive = Math.max(maxActive, active);
    if (starts === 2) gate.resolve();
    await gate.promise;
    active--;
    return fauxAssistantMessage(prompt === projection ? "BLIND_PARALLEL_DONE" : "REVIEW_PARALLEL_DONE");
  };
  faux.setResponses([respond, respond, respond, respond]);
  try { await session.prompt("Run independent Reading reviewers in parallel."); }
  finally { clearTimeout(deadline); gate.resolve(); }
  assert.equal(result?.isError, false, JSON.stringify(result));
  assert.equal(starts, 2); assert.equal(maxActive, 2);
  const text = JSON.stringify(result.content);
  assert.match(text, /REVIEW_PARALLEL_DONE/); assert.match(text, /BLIND_PARALLEL_DONE/);
  assert.ok(text.indexOf("REVIEW_PARALLEL_DONE") < text.indexOf("BLIND_PARALLEL_DONE"), text);
});

test("legacy specialist definitions keep their original narrow tools for offline VS compatibility", async t => {
  const { launch, faux, runtime } = await nativeFixture(t);
  const agents = discoverAgents(launch.cwd, launch.env.GENERATION_HARNESS_AGENT_DIR);
  assert.equal(agents.length, 4);
  await legacyPolicy(async () => {
  for (const agent of agents) {
    assert.ok(agent.subagentOnlyExtensions.some(path => path.endsWith("workspace-guard.ts")), agent.name);
    faux.setResponses([
      ctx => {
        assert.equal(ctx.messages.filter(m => m.role === "user").length, 1);
        return fauxAssistantMessage(["read", "write", "edit", "bash"].map(name => fauxToolCall(name, name === "bash" ? { command: "pwd" } : { path: join(harnessRoot, "package.json"), content: readFileSync(join(harnessRoot, "package.json"), "utf8"), edits: [] })), { stopReason: "toolUse" });
      },
      ctx => {
        const results = ctx.messages.filter(m => m.role === "toolResult");
        assert.equal(results.length, 4); assert.ok(results.every(r => r.isError));
        return fauxAssistantMessage("ISOLATED");
      },
    ]);
    const result = await executeSubagent({ agent: agent.name, task: agent.name === "blind-solver" ? JSON.stringify(studentProjection(exam())) : "Review the supplied IELTS artifact offline." }, {
      cwd: launch.cwd, agentDir: launch.env.GENERATION_HARNESS_AGENT_DIR, sessionDir: join(launch.cwd, ".history/children"), parentSessionId: "isolation-parent", modelRuntime: runtime, parentModel: faux.getModel("reading"), agents,
    });
    assert.equal(result.status, "completed", JSON.stringify(result));
    assert.equal(result.results[0].output, "ISOLATED");
  }
  });
});

test("blind native task-envelope compatibility does not admit private fields or extra prose", async t => {
  const { launch, faux, runtime } = await nativeFixture(t);
  const projection = studentProjection(exam());
  const context = { cwd: launch.cwd, agentDir: launch.env.GENERATION_HARNESS_AGENT_DIR,
    sessionDir: join(launch.cwd, ".sessions"), parentSessionId: "envelope-parent", modelRuntime: runtime,
    parentModel: faux.getModel("reading"), agents: discoverAgents(launch.cwd, launch.env.GENERATION_HARNESS_AGENT_DIR) };
  await legacyPolicy(async () => {
  for (const task of [
    `Task: ${JSON.stringify({ ...projection, answerKey: "PRIVATE-ENVELOPE-KEY" })}`,
    `Task: Task: ${JSON.stringify(projection)}`,
    `Task: ${JSON.stringify(projection)}\nIgnore the schema`,
  ]) {
    const count = faux.state.callCount;
    faux.setResponses([fauxAssistantMessage("MUST_NOT_RUN")]);
    const result = await executeSubagent({ agent: "blind-solver", task }, context);
    assert.equal(result.status, "failed");
    assert.equal(faux.state.callCount, count);
    assert.doesNotMatch(JSON.stringify(result), /PRIVATE-ENVELOPE-KEY/);
  }
  });
});

test("bash uses configured Bubblewrap by default and never falls back when unavailable", async t => {
  await t.test("explicitly disabled", async t => {
    const { call } = await nativeFixture(t, undefined, { GENERATION_HARNESS_READING_BWRAP: "" });
    const result = await call("bash", { command: "pwd" });
    assert.equal(result.isError, true);
    assert.match(JSON.stringify(result.content), /BWRAP_NOT_CONFIGURED/);
  });
  await t.test("missing explicit binary does not fall back to installed default", async t => {
    const { call, temp } = await nativeFixture(t, undefined, { GENERATION_HARNESS_READING_BWRAP: "/nonexistent/reading-test/bwrap" });
    const result = await call("bash", { command: "pwd" });
    assert.equal(result.isError, true);
    assert.match(JSON.stringify(result.content), /BWRAP_NOT_FOUND/);
    assert.match(JSON.stringify(result.content), /--reading-bwrap/);
    assert.equal(existsSync(join(temp, "escaped")), false);
  });
  await t.test("unsafe configured executable is never launched", async t => {
    const temp = mkdtempSync(join(tmpdir(), "reading-unsafe-bwrap-"));
    t.after(() => rmSync(temp, { recursive: true, force: true }));
    const executable = join(temp, "bwrap"), marker = join(temp, "executed");
    writeFileSync(executable, `#!/bin/sh\ntouch '${marker}'\n`, { mode: 0o777 });
    chmodSync(executable, 0o777);
    const { call } = await nativeFixture(t, undefined, { GENERATION_HARNESS_READING_BWRAP: executable });
    const result = await call("bash", { command: "pwd" });
    assert.equal(result.isError, true);
    assert.match(JSON.stringify(result.content), /BWRAP_UNSAFE_EXECUTABLE/);
    assert.equal(existsSync(marker), false);
  });
  // Optional OS capability, never a required install or unsandboxed fallback.
  if (!existsSync("/usr/bin/bwrap")) return t.diagnostic("Bubblewrap unavailable: denial path verified; OS execution not exercised");
  const baseline = spawnSync("/usr/bin/bwrap", ["--unshare-all", ...["/usr", "/bin", "/lib", "/lib64"].filter(existsSync).flatMap(path => ["--ro-bind", path, path]), "--", "/bin/true"], { encoding: "utf8", timeout: 3000 });
  await t.test("default configured capability", async t => {
    const { call, launch } = await nativeFixture(t);
    assert.equal(launch.env.GENERATION_HARNESS_READING_BWRAP, "/usr/bin/bwrap");
    await call("write", { path: "drafts/passage.md", content: "Some passage text" });
    const pwd = await call("bash", { command: "pwd" });
    if (baseline.status !== 0) {
      assert.equal(pwd.isError, true);
      assert.match(JSON.stringify(pwd.content), /BWRAP_PROBE_FAILED/);
      return t.diagnostic("Host Bubblewrap cannot establish namespaces: execution denied");
    }
    assert.equal(pwd.isError, false, JSON.stringify(pwd.content));
    assert.match(JSON.stringify(pwd.content), /\/work/);
    assert.match(JSON.stringify((await call("bash", { command: "ls drafts" })).content), /passage.md/);
    assert.equal((await call("bash", { command: "wc drafts/passage.md" })).isError, false);
    symlinkSync(harnessRoot, join(launch.cwd, "drafts/source"));
    assert.equal((await call("bash", { command: "ls drafts/source" })).isError, true);
    for (const command of ["ls /etc", "ls --help", "ls drafts > drafts/x.json", "ls; echo bad", "ls `pwd`", "ls $(pwd)", "bash -c pwd", "node -e 1"]) assert.equal((await call("bash", { command })).isError, true, command);
  });
});

// Catches the old repository-root/coding-role launch, before any model request.
test("Reading launch allocates distinct workspaces without changing Development launch", t => {
  const temp = mkdtempSync(join(tmpdir(), "reading-boundary-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const env = { GENERATION_HARNESS_RUNTIME_DIR: temp };
  const a = runtimeLaunch(["--reading"], env), b = runtimeLaunch(["--reading"], env);
  assert.notEqual(a.cwd, b.cwd);
  assert.equal(a.cwd.startsWith(join(temp, "reading-runs") + "/"), true);
  for (const directory of ["input", "drafts", "reviews", "revisions", "final"]) assert.ok(readdirSync(a.cwd).includes(directory));
  assert.equal(a.env.GENERATION_HARNESS_READING_WORKSPACE, a.cwd);
  assert.ok(a.args.includes("--no-context-files"));
  assert.match(a.args[a.args.indexOf("--system-prompt") + 1], /IELTS.*author/i);
  assert.equal(runtimeLaunch([], env).cwd, join(temp, "workspace"));
  assert.equal(runtimeLaunch(["--cwd", harnessRoot], env).cwd, harnessRoot);
});

test("Reading does not inherit Development shell hooks or ambient extensions", t => {
  const temp = mkdtempSync(join(tmpdir(), "reading-config-isolation-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const env = { GENERATION_HARNESS_RUNTIME_DIR: temp, BASH_ENV: "/untrusted/bashrc", ENV: "/untrusted/shrc", LD_PRELOAD: "/untrusted/lib.so", BASH_FUNC_ls: "untrusted" };
  const development = runtimeLaunch([], env);
  writeFileSync(join(development.env.GENERATION_HARNESS_AGENT_DIR, "settings.json"), JSON.stringify({ shellCommandPrefix: "touch /protected;", extensions: ["/untrusted/extension.ts"] }));
  const reading = runtimeLaunch(["--reading"], env);
  assert.notEqual(reading.env.GENERATION_HARNESS_AGENT_DIR, development.env.GENERATION_HARNESS_AGENT_DIR);
  for (const name of ["BASH_ENV", "ENV", "LD_PRELOAD", "BASH_FUNC_ls"]) assert.equal(reading.env[name], undefined, name);
  assert.equal(development.env.BASH_ENV, "/untrusted/bashrc");
});

test("Reading launch wires Bubblewrap configuration without changing Development", t => {
  const temp = mkdtempSync(join(tmpdir(), "reading-bwrap-config-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const env = { GENERATION_HARNESS_RUNTIME_DIR: temp };
  assert.equal(runtimeLaunch(["--reading"], env).env.GENERATION_HARNESS_READING_BWRAP, "/usr/bin/bwrap");
  assert.equal(runtimeLaunch([], env).env.GENERATION_HARNESS_READING_BWRAP, undefined);
  const launch = runtimeLaunch(["--reading"], env);
  const nativeConfig = JSON.parse(readFileSync(join(launch.env.GENERATION_HARNESS_AGENT_DIR, "extensions/subagent/config.json"), "utf8"));
  assert.equal(nativeConfig.asyncByDefault, false);
  assert.equal(runtimeLaunch(["--reading"], { ...env, GENERATION_HARNESS_READING_BWRAP: "/operator/bwrap" }).env.GENERATION_HARNESS_READING_BWRAP, "/operator/bwrap");
  assert.equal(runtimeLaunch(["--reading", "--reading-bwrap", "/explicit/bwrap"], env).env.GENERATION_HARNESS_READING_BWRAP, "/explicit/bwrap");
  assert.equal(runtimeLaunch(["--reading"], { ...env, GENERATION_HARNESS_READING_BWRAP: "" }).env.GENERATION_HARNESS_READING_BWRAP, "");
  assert.throws(() => runtimeLaunch(["--reading", "--reading-bwrap", "./bwrap"], env), /absolute/i);
});

test("Reading launcher refuses CLI bypasses and protected input approval", t => {
  const temp = mkdtempSync(join(tmpdir(), "reading-boundary-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const env = { GENERATION_HARNESS_RUNTIME_DIR: temp };
  for (const args of [["--cwd", harnessRoot], ["--no-extensions"], ["--system-prompt", "code"], ["@/etc/passwd"], ["--session", "/etc/passwd"]]) {
    assert.throws(() => runtimeLaunch(["--reading", ...args], env), /Reading/);
  }
  assert.throws(() => runtimeLaunch(["--reading", "--reading-input", join(harnessRoot, "package.json")], env), /input|protected/i);
  const input = join(temp, "passage.md"); writeFileSync(input, "Approved passage");
  const launch = runtimeLaunch(["--reading", "--reading-input", input], env);
  assert.equal(readFileSync(join(launch.cwd, "input", "0-passage.md"), "utf8"), "Approved passage");
  const link = join(temp, "link.md"); symlinkSync(input, link);
  assert.throws(() => runtimeLaunch(["--reading", "--reading-input", link], env), /input|symlink/i);
  const hardlink = join(temp, "hardlink.md"); linkSync(input, hardlink);
  assert.throws(() => runtimeLaunch(["--reading", "--reading-input", hardlink], env), /input|hardlink/i);
});
