import "./offline.mjs";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import test from "node:test";
import { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } from "generation-harness-core";
import { InMemoryCredentialStore, fauxAssistantMessage, fauxProvider, fauxToolCall } from "generation-ai";
import { discoverAgents, executeSubagent } from "generation-subagents";
import { runtimeLaunch } from "../scripts/runtime.mjs";
import { completeExam, correctAnswer, exam, group, passageMd, question, types } from "../.generation/fixtures/reading.mjs";

const root = resolve(fileURLToPath(new URL("..", import.meta.url)));
const names = ["get_question_spec", "validate_question", "validate_group", "validate_exam", "verify_evidence", "check_grading_parity", "inspect_delivery_projection"];
const clone = x => structuredClone(x);
const codes = r => r.diagnostics.map(d => d.code);
async function fixture(t) {
  const temp = mkdtempSync(join(tmpdir(), "reading-native-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const agentDir = join(temp, "agent");
  const runtime = await ModelRuntime.create({ credentials: new InMemoryCredentialStore(), modelsPath: null, refreshOnCreate: false });
  const faux = fauxProvider({ models: [{ id: "reading" }] });
  runtime.registerNativeProvider(faux.provider);
  const loader = new DefaultResourceLoader({ cwd: root, agentDir, settingsManager: SettingsManager.create(root, agentDir) });
  await loader.reload();
  assert.deepEqual(loader.getExtensions().errors, []);
  const { session } = await createAgentSession({ cwd: root, agentDir, modelRuntime: runtime, model: faux.getModel("reading"), resourceLoader: loader, sessionManager: SessionManager.inMemory() });
  t.after(() => session.dispose());
  await session.bindExtensions({ mode: "rpc" });
  const agents = discoverAgents(root, agentDir);
  const context = { cwd: root, agentDir, sessionDir: join(temp, "sessions"), parentSessionId: "test-parent", modelRuntime: runtime, parentModel: faux.getModel("reading"), agents };
  let sequence = 0;
  // This helper drives actual model tool calls through the native session, not direct domain calls.
  async function tools(calls) {
    const prefix = `batch-${sequence++}-`;
    let results;
    faux.setResponses([
      fauxAssistantMessage(calls.map(([name, args], i) => fauxToolCall(name, args, { id: prefix + i })), { stopReason: "toolUse" }),
      ctx => {
        results = ctx.messages.filter(m => m.role === "toolResult" && m.toolCallId.startsWith(prefix));
        assert.equal(results.length, calls.length);
        return fauxAssistantMessage("complete");
      },
    ]);
    await session.prompt("Run the offline fixture tools.");
    return results.map(r => {
      if (r.isError) return { nativeError: true, text: JSON.stringify(r.content) };
      const report = JSON.parse(r.content[0].text);
      assert.deepEqual(r.details, report, `Structured details differ for ${r.toolName}`);
      assert.ok(["PASS", "FAIL"].includes(report.status));
      assert.ok(Array.isArray(report.diagnostics));
      for (const d of report.diagnostics) {
        assert.match(d.code, /^[A-Z][A-Z_]+$/);
        assert.ok(["error", "warning"].includes(d.severity));
        assert.equal(typeof d.path, "string");
        assert.equal(typeof d.message, "string");
      }
      return report;
    });
  }
  return { temp, agentDir, faux, session, agents, context, tools };
}
function evidenceInput(g = group()) {
  const start = passageMd.indexOf("two days"), quote = "two days";
  return { passageMd, group: g, evidence: g.questions.map(q => ({ questionId: q.id, start, end: start + quote.length, quote })), blindSolverId: "blind-session", semanticReviews: [{ reviewerId: "independent-review-session", questionIds: g.questions.map(q => q.id), verdict: "PASS", rationale: "Mocked approval to exercise plumbing, not real IELTS evidence.", mocked: true }] };
}

test("actual launcher cwd discovers seven tools and four native specialist definitions", async t => {
  const { temp, agentDir, session, agents } = await fixture(t);
  const env = { GENERATION_HARNESS_RUNTIME_DIR: join(temp, "runtime") };
  const defaultLaunch = runtimeLaunch([], env), projectLaunch = runtimeLaunch(["--cwd", root], env);
  assert.notEqual(defaultLaunch.cwd, root);
  assert.equal(projectLaunch.cwd, root);
  const isolated = new DefaultResourceLoader({ cwd: defaultLaunch.cwd, agentDir, settingsManager: SettingsManager.create(defaultLaunch.cwd, agentDir) });
  await isolated.reload();
  assert.ok(!isolated.getExtensions().extensions.some(e => e.path?.endsWith("reading.ts")));
  assert.deepEqual(session.getAllTools().filter(t => names.includes(t.name)).map(t => t.name).sort(), [...names].sort());
  assert.deepEqual(agents.map(a => a.name).sort(), ["blind-solver", "question-validator", "reading-generator", "semantic-reviewer"]);
  for (const agent of agents) {
    assert.equal(agent.subagentOnlyExtensions[0], join(root, ".generation/extensions/reading.ts"));
    assert.ok(!agent.tools.some(t => ["read", "bash", "edit", "write", "subagent"].includes(t)));
  }
  assert.deepEqual(agents.find(a => a.name === "blind-solver").tools, ["get_question_spec"]);
  assert.match(JSON.parse(readFileSync(join(root, "package.json"), "utf8")).scripts["start:reading"], /--cwd \./);
});

test("supported npm start:reading entry point discovers the extension in an actual guarded RPC process", t => {
  const temp = mkdtempSync(join(tmpdir(), "reading-entrypoint-"));
  t.after(() => rmSync(temp, { recursive: true, force: true }));
  const offline = pathToFileURL(join(root, "test/offline.mjs")).href;
  const preload = join(temp, "guard.mjs"), probe = join(temp, "probe.ts");
  // The launcher intentionally strips inherited NODE_OPTIONS. Reapply only this
  // test's guard at process spawn, without changing the application or Core.
  writeFileSync(preload, `
import ${JSON.stringify(offline)};
import cp from "node:child_process";
import { syncBuiltinESMExports } from "node:module";
const original = cp.spawn;
cp.spawn = (command, args, options = {}) => original(command, args, { ...options, env: { ...(options.env ?? process.env), NODE_OPTIONS: ${JSON.stringify(`--import=${pathToFileURL(preload).href}`)} } });
syncBuiltinESMExports();
`);
  writeFileSync(probe, `
import { resolveSubagentLaunchContract } from ${JSON.stringify(pathToFileURL(join(root, "packages/generation-subagents/dist/api/preflight.js")).href)};
export default function probe(api) {
  api.on("session_start", async (_event, ctx) => {
    const agents = await Promise.all(["reading-generator", "question-validator", "blind-solver", "semantic-reviewer"].map(agent => resolveSubagentLaunchContract({ agent, cwd: ctx.cwd, agentScope: "project", projectTrusted: ctx.isProjectTrusted(), parentModel: { provider: "faux", id: "reading" }, availableModels: [{ provider: "faux", id: "reading" }], sessionRoot: process.env.GENERATION_HARNESS_SESSION_DIR, artifacts: false })));
    process.stdout.write(JSON.stringify({ type: "reading-discovery", cwd: ctx.cwd, trusted: ctx.isProjectTrusted(), guarded: globalThis.__GENERATION_NETWORK_GUARD_INSTALLED__ === true, tools: api.getAllTools().map(t => t.name), agents }) + "\\n");
  });
}
`);
  const launch = runtimeLaunch(["--cwd", root], { ...process.env, GENERATION_HARNESS_RUNTIME_DIR: join(temp, "runtime") });
  const result = spawnSync("npm", ["run", "start:reading", "--", "--mode", "rpc", "--no-session", "--offline", "--extension", probe], {
    cwd: root, env: { ...launch.env, NODE_OPTIONS: `--import=${pathToFileURL(preload).href}` }, encoding: "utf8", timeout: 20000,
    input: JSON.stringify({ type: "get_state", id: "reading-state" }) + "\n",
  });
  assert.equal(result.status, 0, `${result.error ?? ""}\n${result.stdout}\n${result.stderr}`);
  // RPC's native output guard routes extension stdout to stderr.
  const messages = `${result.stdout}\n${result.stderr}`.split("\n").flatMap(line => { try { return [JSON.parse(line)]; } catch { return []; } });
  const discovery = messages.find(m => m.type === "reading-discovery");
  assert.ok(discovery, `${result.stdout}\n${result.stderr}`);
  assert.equal(discovery.cwd, root);
  assert.equal(discovery.guarded, true);
  assert.equal(discovery.trusted, true);
  assert.deepEqual(discovery.tools.filter(n => names.includes(n)).sort(), [...names].sort());
  assert.ok(discovery.tools.includes("subagent"));
  assert.equal(discovery.agents.length, 4);
  for (const resolved of discovery.agents) {
    assert.equal(resolved.ok, true, JSON.stringify(resolved));
    const c = resolved.contract;
    assert.equal(c.agent.source, "project");
    assert.equal(c.context, "fresh");
    assert.equal(c.systemPromptMode, "replace");
    assert.equal(c.inheritProjectContext, false);
    assert.equal(c.inheritGlobalContext, false);
    assert.equal(c.inheritSkills, false);
    assert.equal(c.tools.disableAmbientExtensions, true);
    assert.ok(c.tools.extensionArgs.includes(join(root, ".generation/extensions/reading.ts")));
    if (c.agent.name === "blind-solver") assert.deepEqual(c.tools.effectiveAllowlist, ["get_question_spec"]);
  }
  assert.equal(messages.find(m => m.id === "reading-state")?.success, true);
  assert.ok(!messages.some(m => m.type === "extension_error"), JSON.stringify(messages));
  assert.doesNotMatch(result.stderr, /NetworkBlocked|Failed to load|Extension.*error/i);
  const denied = spawnSync("npm", ["run", "start:reading", "--", "--no-approve", "--mode", "rpc", "--no-session", "--offline", "--extension", probe], {
    cwd: root, env: { ...launch.env, NODE_OPTIONS: `--import=${pathToFileURL(preload).href}` }, encoding: "utf8", timeout: 20000,
    input: JSON.stringify({ type: "get_state", id: "denied-state" }) + "\n",
  });
  assert.equal(denied.status, 0, `${denied.error ?? ""}\n${denied.stdout}\n${denied.stderr}`);
  const deniedDiscovery = `${denied.stdout}\n${denied.stderr}`.split("\n").flatMap(line => { try { return [JSON.parse(line)]; } catch { return []; } }).find(m => m.type === "reading-discovery");
  assert.ok(deniedDiscovery);
  assert.equal(deniedDiscovery.trusted, false);
  assert.equal(deniedDiscovery.guarded, true);
  assert.ok(names.every(n => !deniedDiscovery.tools.includes(n)));
  assert.ok(deniedDiscovery.agents.every(r => !r.ok));
});

test("all 19 source-derived contracts register, validate and grade through actual tools", async t => {
  const { tools } = await fixture(t);
  const shared = readFileSync(resolve(root, "../_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs"), "utf8");
  const constants = [...shared.matchAll(/public const string (\w+) = "([A-Z_]+)"/g)];
  assert.deepEqual(constants.map(m => m[2]), types);
  const registration = readFileSync(resolve(root, "../attempt-service/Features/Helpers/QuestionGraderRegistration.cs"), "utf8");
  const registrationFamilies = { SingleChoiceGraderRegistration: "single", MultipleChoiceGraderRegistration: "multiple", CompletionGraderRegistration: "completion", LabelGraderRegistration: "completion", MatchingHeadingGraderRegistration: "matching", FlowChartGraderRegistration: "flow", ShortAnswerGraderRegistration: "short" };
  const sourceFamilies = {};
  for (const block of registration.split("public class ").slice(1)) {
    const className = block.match(/^\w+/)[0];
    assert.ok(registrationFamilies[className], `Unmapped backend registration ${className}`);
    for (const [, symbol] of block.matchAll(/QuestionType\.(\w+)/g)) {
      const type = constants.find(m => m[1] === symbol)?.[2];
      assert.ok(type, `Unknown shared type ${symbol}`);
      assert.ok(!sourceFamilies[type], `Duplicate backend registration ${type}`);
      sourceFamilies[type] = registrationFamilies[className];
    }
  }
  assert.equal(Object.keys(sourceFamilies).length, 19);
  const calls = types.flatMap(type => {
    const q = question(type);
    return [["get_question_spec", { type }], ["validate_question", { question: q }], ["check_grading_parity", { question: q, cases: [{ id: "correct", answer: correctAnswer(q), expectedCorrect: true }, { id: "missing", answer: {}, expectedCorrect: false }] }]];
  });
  const results = await tools(calls);
  for (const [i, r] of results.entries()) assert.equal(r.status, "PASS", `${calls[i][0]} ${types[Math.floor(i / 3)]}: ${JSON.stringify(r)}`);
  for (const r of results.filter((_, i) => i % 3 === 2)) assert.deepEqual(r.results.map(x => x.awardedPoints), [1, 0]);
  assert.equal(results.length, 57);
  for (const [i, type] of types.entries()) {
    assert.equal(results[i * 3].family, sourceFamilies[type], `Grader family drift: ${type}`);
    const count = results[i * 3 + 1], slots = type === "FLOW_CHART" ? 3 : type === "MULTIPLE_CHOICE_MULTIPLE" ? 2 : 1;
    assert.deepEqual([count.questionCount, count.answerSlotCount, count.scoringUnitCount, count.questionGroupCount], [1, slots, 1, 0]);
  }
  assert.equal(results[54].ieltsCorrectness, "INCOMPATIBLE_STANDARD_FLOW_COMPLETION");
});

test("strict native schemas reject malformed inputs before execution", async t => {
  const { tools } = await fixture(t);
  const q = question("SUMMARY_COMPLETION");
  const results = await tools([
    ["get_question_spec", { type: "WRITING" }],
    ["validate_question", { question: { ...q, idx: "1" } }],
    ["validate_question", { question: { ...q, undeclaredKey: true } }],
    ["validate_group", { group: { ...group(), questions: null } }],
    ["validate_exam", { exam: exam(), complete: "yes" }],
    ["verify_evidence", { ...evidenceInput(), evidence: [{ questionId: q.id, start: -1, end: 5, quote: "test" }] }],
    ["check_grading_parity", { question: q, cases: [] }],
    ["inspect_delivery_projection", { exam: exam(), projectionJson: {} }],
  ]);
  for (const r of results) {
    assert.equal(r.nativeError, true, JSON.stringify(r));
    assert.ok(r.text.includes("INPUT_SCHEMA_INVALID"), r.text);
  }
});

test("ingestion, key completeness and group membership diagnostics are stable", async t => {
  const { tools } = await fixture(t);
  const cases = [];
  const add = (q, code) => cases.push(["validate_question", { question: q }, code]);
  const base = question("SUMMARY_COMPLETION");
  add({ ...base, promptMd: "No marker" }, "INGESTION_BLANK_MARKER_MISSING");
  add({ ...base, blankAcceptTexts: {}, blankAcceptRegex: { "1": ["two"] } }, "INGESTION_BLANK_KEY_REQUIRED");
  add({ ...base, promptMd: "[1] and [2]" }, "BLANK_MARKER_UNKEYED");
  add({ ...base, blankAcceptTexts: { "x": ["two"] } }, "BLANK_INDEX_INVALID");
  add({ ...base, blankAcceptTexts: { "1": [] } }, "BLANK_KEY_EMPTY");
  add({ ...base, blankAcceptTexts: { "1": [""] } }, "ACCEPTED_TEXT_EMPTY");
  add({ ...question("FLOW_CHART"), blankAcceptTexts: { "1": ["water"] } }, "INGESTION_FLOW_LABELS_FORBIDDEN");
  add({ ...question("FLOW_CHART"), orderCorrects: ["Bad node"] }, "INGESTION_FLOW_ORDER_INVALID");
  add({ ...question("MATCHING_HEADING"), matchPairs: { "1": ["A"] } }, "INGESTION_MATCH_PAIR_INVALID");
  add({ ...question("SHORT_ANSWER"), shortAnswerAcceptTexts: [] }, "INGESTION_SHORT_KEY_REQUIRED");
  add({ ...question("MULTIPLE_CHOICE_SINGLE"), blankAcceptTexts: { "1": ["two"] } }, "INGESTION_BLANK_KEY_FORBIDDEN");
  const noCorrect = question("MULTIPLE_CHOICE_SINGLE"); noCorrect.options.forEach(o => o.isCorrect = false);
  add(noCorrect, "CHOICE_KEY_COUNT");
  const badGroup = group(); badGroup.questions[0].groupId = "different";
  cases.push(["validate_group", { group: badGroup }, "QUESTION_GROUP_MEMBERSHIP"]);
  cases.push(["validate_group", { group: { ...group(), endIdx: 2 } }, "GROUP_INDEX_COVERAGE"]);
  cases.push(["validate_group", { group: group([]) }, "GROUP_EMPTY"]);
  const results = await tools(cases.map(([name, args]) => [name, args]));
  results.forEach((r, i) => { assert.equal(r.status, "FAIL"); assert.ok(codes(r).includes(cases[i][2]), JSON.stringify(r)); });
});

test("complete papers require 40 independent units, never 40 slots or section-local numbering", async t => {
  const { tools } = await fixture(t);
  const paper = completeExam();
  const fortySlots = exam(group([ { ...question("SUMMARY_COMPLETION"), promptMd: Array.from({ length: 40 }, (_, i) => `[${i + 1}]`).join(" "), blankAcceptTexts: Object.fromEntries(Array.from({ length: 40 }, (_, i) => [String(i + 1), ["two"]])) } ]));
  const local = clone(paper); local.sections[1].questionGroups[0].questions[0].idx = 1;
  const wrongMembership = clone(paper); wrongMembership.sections[1].examId = "other"; wrongMembership.sections[0].questionGroups[0].sectionId = "other";
  const duplicate = clone(paper); duplicate.sections[1].questionGroups[0].questions[0].id = duplicate.sections[0].questionGroups[0].questions[0].id;
  const results = await tools([
    ["validate_exam", { exam: paper, complete: true }],
    ["validate_exam", { exam: exam(), complete: false }],
    ["validate_exam", { exam: fortySlots, complete: true }],
    ["validate_exam", { exam: local, complete: true }],
    ["validate_exam", { exam: wrongMembership, complete: true }],
    ["validate_exam", { exam: duplicate, complete: true }],
    ["validate_group", { group: fortySlots.sections[0].questionGroups[0] }],
  ]);
  assert.equal(results[0].status, "PASS");
  assert.deepEqual([results[0].questionCount, results[0].answerSlotCount, results[0].scoringUnitCount, results[0].questionGroupCount], [40, 40, 40, 3]);
  assert.equal(results[1].status, "PASS");
  assert.equal(results[2].answerSlotCount, 40); assert.equal(results[2].scoringUnitCount, 1);
  assert.ok(codes(results[2]).includes("PAPER_SCORING_UNIT_COUNT"));
  assert.ok(codes(results[3]).includes("PAPER_INDEX_COVERAGE"));
  assert.ok(codes(results[4]).includes("SECTION_EXAM_MEMBERSHIP"));
  assert.ok(codes(results[4]).includes("GROUP_SECTION_MEMBERSHIP"));
  assert.ok(codes(results[5]).includes("QUESTION_DUPLICATE"));
  assert.equal(results[6].status, "PASS");
  assert.equal(results[6].scoringUnitCount, 1);
});

test("completion numeric order, matching formats, choice sets, legacy fallbacks and FLOW casing mirror backend", async t => {
  const { tools } = await fixture(t);
  const completion = { ...question("TABLE_COMPLETION"), promptMd: "[10] [2]", blankAcceptTexts: { "10": ["ten"], "2": ["two"] } };
  const matching = { ...question("MATCHING_HEADING"), matchPairs: { "2": ["B", "Harvest"], "1": ["A", "Watering"] } };
  const single = question("MULTIPLE_CHOICE_SINGLE"), multiple = question("MULTIPLE_CHOICE_MULTIPLE"), flow = question("FLOW_CHART");
  single.options[0].id = "abcdefab-1234-4567-abcd-abcdef123456";
  const inputs = [
    [completion, [
      ["json", { textAnswer: '{"10":"10","2":"TWO"}' }, true],
      ["extra-null-property", { textAnswer: '{"10":"10","2":"two","extra":null}' }, true],
      ["positional-numeric", { textAnswer: "two\nten" }, true],
      ["partial", { textAnswer: '{"2":"two"}' }, false],
      ["reversed", { textAnswer: "ten\ntwo" }, false],
      ["extra-parts-ignored", { textAnswer: "two\nten\nextra" }, true],
      ["malformed", { textAnswer: "{oops}" }, false],
    ]],
    [matching, [
      ["json", { textAnswer: '{"1":"a","2":"b"}' }, true],
      ["display-labels-accepted", { textAnswer: '{"1":"Watering","2":"Harvest"}' }, true],
      ["no-trim-json", { textAnswer: '{"1":" A ","2":"B"}' }, false],
      ["partial", { textAnswer: '{"1":"A"}' }, false],
      ["no-newline-fallback", { textAnswer: "A\nB" }, false],
    ]],
    [single, [
      ["content-fallback", { textAnswer: " two DAYS " }, true],
      ["uuid-fallback", { textAnswer: single.options[0].id }, true],
      ["uuid-case-and-dedup", { selectedOptionIds: [single.options[0].id.toUpperCase(), single.options[0].id] }, true],
      ["duplicate-set", { selectedOptionIds: [single.options[0].id, single.options[0].id] }, true],
      ["wrong", { selectedOptionIds: [single.options[1].id] }, false],
      ["text-overrides-wrong-selection", { selectedOptionIds: [single.options[1].id], textAnswer: "Two days" }, true],
    ]],
    [multiple, [
      ["reverse-duplicate", { selectedOptionIds: [multiple.options[1].id, multiple.options[0].id, multiple.options[0].id] }, true],
      ["partial", { selectedOptionIds: [multiple.options[0].id] }, false],
      ["extra", { selectedOptionIds: multiple.options.map(o => o.id) }, false],
      ["text-ignored", { textAnswer: "Two days" }, false],
    ]],
    [flow, [
      ["array", { textAnswer: '["PLANT","water","harvest"]' }, true],
      ["lowercase-object-rejected", { textAnswer: '{"steps":["plant","water","harvest"]}' }, false],
      ["uppercase-object", { textAnswer: '{"Steps":["plant","water","harvest"]}' }, true],
      ["malformed-labels", { textAnswer: '{"Steps":["plant","water","harvest"],"Labels":[]}' }, false],
      ["wrong-order", { textAnswer: '["water","plant","harvest"]' }, false],
    ]],
    [{ ...question("SHORT_ANSWER"), shortAnswerAcceptTexts: ["café two"] }, [["normalization", { textAnswer: " CAFE  2 " }, true]]],
  ];
  const results = await tools(inputs.map(([question, cases]) => ["check_grading_parity", { question, cases: cases.map(([id, answer, expectedCorrect]) => ({ id, answer, expectedCorrect })) }]));
  for (const r of results) { assert.equal(r.status, "PASS", JSON.stringify(r)); assert.ok(r.results.every(x => x.awardedPoints === 0 || x.awardedPoints === 1)); }
  assert.ok(codes(results[0]).includes("MULTI_SLOT_ALL_OR_NOTHING"));
  assert.ok(codes(results[1]).includes("MATCHING_DISPLAY_TEXT_ACCEPTED"));
  assert.ok(codes(results[4]).includes("FLOW_OBJECT_CASE_MISMATCH"));
  const [divergence, invalidSelection, unsupported] = await tools([
    ["check_grading_parity", { question: single, cases: [{ id: "ielts-expects-no", answer: { textAnswer: "Two days" }, expectedCorrect: false }] }],
    ["check_grading_parity", { question: single, cases: [{ id: "bad-id", answer: { selectedOptionIds: ["not-an-option"] }, expectedCorrect: false }] }],
    ["check_grading_parity", { question: { ...question("SHORT_ANSWER"), shortAnswerAcceptRegex: ["(?i)two"] }, cases: [{ id: "regex", answer: { textAnswer: "TWO" }, expectedCorrect: true }] }],
  ]);
  assert.ok(codes(divergence).includes("GRADING_IELTS_DIVERGENCE"));
  assert.ok(codes(invalidSelection).includes("ANSWER_SELECTION_INVALID"));
  assert.ok(codes(unsupported).includes("PARITY_REGEX_UNSUPPORTED"));
  assert.equal(unsupported.status, "FAIL");
});

test("backend parity covers Guid text forms, null FLOW steps and dictionary prototype keys", async t => {
  const { tools } = await fixture(t);
  const single = question("MULTIPLE_CHOICE_SINGLE"), flow = question("FLOW_CHART");
  single.options[0].id = "abcdefab-1234-4567-abcd-abcdef123456";
  const guid = single.options[0].id;
  const matching = { ...question("MATCHING_HEADING"), matchPairs: { constructor: ["A", "Watering", ""] } };
  const results = await tools([
    ["check_grading_parity", { question: single, cases: [...[guid.replaceAll("-", ""), `{${guid}}`, `(${guid})`, "{0xabcdefab,0x1234,0x4567,{0xab,0xcd,0xab,0xcd,0xef,0x12,0x34,0x56}}"].map((textAnswer, i) => ({ id: `guid-${i}`, answer: { textAnswer }, expectedCorrect: true })), { id: "invalid-braced-N", answer: { textAnswer: `{${guid.replaceAll("-", "")}}` }, expectedCorrect: false }] }],
    ["check_grading_parity", { question: flow, cases: [{ id: "null-step-filtered", answer: { textAnswer: '["plant",null,"water","harvest"]' }, expectedCorrect: true }] }],
    ["check_grading_parity", { question: matching, cases: [{ id: "missing-dictionary-key", answer: { textAnswer: '{}' }, expectedCorrect: false }, { id: "null-is-not-empty", answer: { textAnswer: '{"constructor":null}' }, expectedCorrect: false }, { id: "explicit-empty-is-accepted-by-backend", answer: { textAnswer: '{"constructor":""}' }, expectedCorrect: true }, { id: "present-key", answer: { textAnswer: '{"constructor":"A"}' }, expectedCorrect: true }] }],
  ]);
  assert.deepEqual(results.map(r => r.status ?? r), ["PASS", "PASS", "PASS"], JSON.stringify(results));
});

test("normalization follows .NET whitespace and exact Int64 blank ordering", async t => {
  const { tools } = await fixture(t);
  const q = { ...question("SHORT_ANSWER"), shortAnswerAcceptTexts: ["two days"] };
  const completion = { ...question("TABLE_COMPLETION"), promptMd: "[10000000000000000] [9999999999999999]", blankAcceptTexts: { "10000000000000000": ["ten"], "9999999999999999": ["nine"] } };
  const results = await tools([
    ["check_grading_parity", { question: q, cases: [{ id: "next-line-is-whitespace", answer: { textAnswer: "two\u0085days" }, expectedCorrect: true }, { id: "bom-is-not-whitespace", answer: { textAnswer: "\ufefftwo days\ufeff" }, expectedCorrect: false }] }],
    ["check_grading_parity", { question: completion, cases: [{ id: "int64-order", answer: { textAnswer: "nine\nten" }, expectedCorrect: true }] }],
  ]);
  assert.deepEqual(results.map(r => r.status), ["PASS", "PASS"], JSON.stringify(results));
});

test("evidence checks fail closed on bad spans, coverage and non-independent review", async t => {
  const { tools } = await fixture(t);
  const good = evidenceInput();
  const bad = clone(good); bad.evidence[0].quote = "not in passage";
  const coverage = clone(good); coverage.evidence = []; coverage.semanticReviews[0].questionIds = [];
  const dependent = clone(good); dependent.semanticReviews[0].reviewerId = good.blindSolverId;
  const rejected = clone(good); rejected.semanticReviews[0].verdict = "FAIL";
  const results = await tools([good, bad, coverage, dependent, rejected].map(args => ["verify_evidence", args]));
  assert.equal(results[0].status, "PASS"); assert.equal(results[0].ieltsQualityEstablished, false); assert.equal(results[0].mocked, true);
  for (const [i, code] of ["EVIDENCE_SPAN_MISMATCH", "EVIDENCE_MISSING", "REVIEW_NOT_INDEPENDENT", "SEMANTIC_REVIEW_REJECTED"].entries()) assert.ok(codes(results[i + 1]).includes(code));
  assert.ok(codes(results[2]).includes("SEMANTIC_REVIEW_COVERAGE"));
});

test("delivery redacts private fields in every section and normalizes paper order without changing source", async t => {
  const { tools } = await fixture(t);
  const allTypes = exam(group(types.map((type, i) => question(type, i + 1))));
  const [typedDelivery] = await tools([["inspect_delivery_projection", { exam: allTypes }]]);
  assert.equal(typedDelivery.status, "PASS");
  const visibleQuestions = typedDelivery.projection.sections[0].questionGroups[0].questions;
  assert.equal(visibleQuestions.length, 19);
  const visibleJson = JSON.stringify(visibleQuestions);
  for (const privateKey of ["isCorrect", "explanationMd", "blankAcceptTexts", "blankAcceptRegex", "matchPairs", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex", "modelAnswers", "PRIVATE-"]) assert.ok(!visibleJson.includes(privateKey), privateKey);
  assert.ok(visibleQuestions[0].options.length > 0, "Choice redaction must not be tested only on empty options.");
  assert.deepEqual(visibleQuestions[0].options[0], { id: allTypes.sections[0].questionGroups[0].questions[0].options[0].id, idx: 1, contentMd: "Two days" });
  const flow = visibleQuestions.find(q => q.type === "FLOW_CHART");
  assert.deepEqual(flow.flowChartNodes.map(n => n.key), ["harvest", "plant", "water"]);
  const paper = completeExam(), before = JSON.stringify(paper);
  // Unsorted arrays must project in canonical delivery order.
  paper.sections.reverse();
  const [safe] = await tools([["inspect_delivery_projection", { exam: paper }]]);
  assert.equal(safe.status, "PASS");
  const serialized = JSON.stringify(safe.projection);
  for (const privateKey of ["isCorrect", "explanationMd", "blankAcceptTexts", "modelAnswers", "PRIVATE-"]) assert.ok(!serialized.includes(privateKey));
  assert.deepEqual(safe.projection.sections.flatMap(s => s.questionGroups.flatMap(g => g.questions.map(q => q.idx))), Array.from({ length: 40 }, (_, i) => i + 1));
  paper.sections.reverse(); assert.equal(JSON.stringify(paper), before);
  const leaked = clone(safe.projection); leaked.sections[1].questionGroups[0].questions[0].explanationMd = "PRIVATE-EXPLANATION-SENTINEL";
  const altered = clone(safe.projection); altered.sections[0].questionGroups[0].questions[0].idx = 99;
  const [match, leak, mismatch, invalid] = await tools([
    ["inspect_delivery_projection", { exam: paper, projectionJson: serialized }],
    ["inspect_delivery_projection", { exam: paper, projectionJson: JSON.stringify(leaked) }],
    ["inspect_delivery_projection", { exam: paper, projectionJson: JSON.stringify(altered) }],
    ["inspect_delivery_projection", { exam: paper, projectionJson: "{" }],
  ]);
  assert.equal(match.status, "PASS");
  assert.ok(codes(leak).includes("DELIVERY_PRIVATE_FIELD"));
  assert.ok(codes(mismatch).includes("DELIVERY_PROJECTION_MISMATCH"));
  assert.ok(codes(invalid).includes("DELIVERY_JSON_INVALID"));
});

test("blind child cannot invoke private-validation or filesystem tools outside its allowlist", async t => {
  const { temp, faux, context } = await fixture(t);
  const secret = join(temp, "private-key.json");
  writeFileSync(secret, JSON.stringify({ answer: "PRIVATE-UNREADABLE-SENTINEL" }));
  faux.setResponses([
    fauxAssistantMessage([fauxToolCall("read", { path: secret }), fauxToolCall("validate_question", { question: question("SUMMARY_COMPLETION") })], { stopReason: "toolUse" }),
    ctx => {
      const results = ctx.messages.filter(m => m.role === "toolResult");
      assert.equal(results.length, 2);
      assert.ok(results.every(r => r.isError), JSON.stringify(results));
      assert.ok(!JSON.stringify(ctx.messages).includes("PRIVATE-UNREADABLE-SENTINEL"));
      return fauxAssistantMessage("BLIND_TOOL_ACCESS_DENIED");
    },
  ]);
  const blind = await executeSubagent({ agent: "blind-solver", task: "Offline adversarial allowlist check; no private input supplied." }, context);
  assert.equal(blind.status, "completed", JSON.stringify(blind));
  assert.equal(blind.results[0].output, "BLIND_TOOL_ACCESS_DENIED");
  assert.ok(!readFileSync(blind.results[0].sessionFile, "utf8").includes("PRIVATE-UNREADABLE-SENTINEL"));
});

test("mocked end-to-end slice uses real isolated generator, validator, blind and review children", async t => {
  const { faux, context, tools } = await fixture(t);
  const generated = group();
  // This is a test script, not a production coordinator or replacement agent loop.
  faux.setResponses([
    fauxAssistantMessage([
      fauxToolCall("get_question_spec", { type: generated.questions[0].type }),
      fauxToolCall("validate_group", { group: generated }),
    ], { stopReason: "toolUse" }),
    ctx => {
      const reports = ctx.messages.filter(m => m.role === "toolResult").map(m => JSON.parse(m.content[0].text));
      assert.equal(reports.length, 2);
      assert.ok(reports.every(r => r.status === "PASS"));
      return fauxAssistantMessage(JSON.stringify(generated));
    },
  ]);
  const generator = await executeSubagent({ agent: "reading-generator", task: `Generate a mocked completion group for this passage: ${passageMd}` }, context);
  assert.equal(generator.status, "completed", JSON.stringify(generator));
  const g = JSON.parse(generator.results[0].output), paper = exam(g);
  const validatorTask = JSON.stringify(paper);
  faux.setResponses([
    ctx => {
      const users = ctx.messages.filter(m => m.role === "user");
      assert.equal(users.length, 1);
      assert.equal(users[0].content[0].text, validatorTask);
      // Consume the actual generator handoff, not a separately reconstructed group.
      const suppliedPaper = JSON.parse(users[0].content[0].text);
      const suppliedGroup = suppliedPaper.sections[0].questionGroups[0];
      assert.equal(JSON.stringify(suppliedGroup), generator.results[0].output);
      return fauxAssistantMessage([
        fauxToolCall("validate_group", { group: suppliedGroup }),
        fauxToolCall("check_grading_parity", { question: suppliedGroup.questions[0], cases: [{ id: "correct", answer: { textAnswer: "two" }, expectedCorrect: true }, { id: "wrong", answer: { textAnswer: "three" }, expectedCorrect: false }] }),
        fauxToolCall("inspect_delivery_projection", { exam: suppliedPaper }),
      ], { stopReason: "toolUse" });
    },
    ctx => {
      const reports = ctx.messages.filter(m => m.role === "toolResult").map(m => JSON.parse(m.content[0].text));
      assert.equal(reports.length, 3);
      assert.ok(reports.every(r => r.status === "PASS"));
      return fauxAssistantMessage(JSON.stringify({ status: "PASS", reports }));
    },
  ]);
  const validator = await executeSubagent({ agent: "question-validator", task: validatorTask }, context);
  assert.equal(validator.status, "completed", JSON.stringify(validator));
  const validated = JSON.parse(validator.results[0].output);
  assert.equal(validated.status, "PASS");
  // Only the native projection returned by the validator reaches the blind child.
  const delivery = validated.reports.find(r => r.projection);
  assert.equal(delivery.status, "PASS");
  const blindTask = JSON.stringify(delivery.projection);
  const assertBlind = ctx => {
    const serialized = JSON.stringify(ctx.messages.filter(m => m.role === "user"));
    for (const privateKey of ["blankAcceptTexts", "explanationMd", "modelAnswers", "isCorrect", "PRIVATE-", "semanticReviews", '"evidence":']) assert.ok(!serialized.includes(privateKey), privateKey);
    assert.ok(!JSON.stringify(ctx.messages).includes("PRIVATE-"));
    assert.deepEqual(ctx.messages.filter(m => m.role === "system").flatMap(m => m.toolsAdded ?? []).map(t => t.name), ["get_question_spec"]);
    assert.equal(ctx.messages.filter(m => m.role === "user").length, 1);
    assert.equal(ctx.messages.find(m => m.role === "user").content[0].text, blindTask);
  };
  faux.setResponses([
    ctx => { assertBlind(ctx); return fauxAssistantMessage(fauxToolCall("get_question_spec", { type: "SUMMARY_COMPLETION" }), { stopReason: "toolUse" }); },
    ctx => { assertBlind(ctx); return fauxAssistantMessage(JSON.stringify({ questionId: g.questions[0].id, answer: { textAnswer: "two" }, confidence: 1, mocked: true })); },
  ]);
  const blind = await executeSubagent({ agent: "blind-solver", task: blindTask }, context);
  assert.equal(blind.status, "completed", JSON.stringify(blind));
  const solved = JSON.parse(blind.results[0].output);
  const solvedQuestion = g.questions.find(q => q.id === solved.questionId);
  assert.ok(solvedQuestion, "Blind answer must correlate to a question in the generated group.");
  const input = evidenceInput(g);
  input.blindSolverId = blind.results[0].sessionId;
  const reviewTask = JSON.stringify({ passageMd, group: g, evidence: input.evidence, mocked: true });
  const reviews = [];
  for (const i of [1, 2]) {
    faux.setResponses([
      ctx => {
        const users = ctx.messages.filter(m => m.role === "user");
        assert.equal(users.length, 1);
        assert.equal(users[0].content[0].text, reviewTask);
        const supplied = JSON.parse(users[0].content[0].text);
        assert.equal(JSON.stringify(supplied.group), generator.results[0].output);
        for (const forbidden of ['"confidence"', "MOCK-REVIEW-", "blind-answer", "grading-parity"]) assert.ok(!JSON.stringify(ctx.messages).includes(forbidden));
        return fauxAssistantMessage(fauxToolCall("get_question_spec", { type: supplied.group.questions[0].type }), { stopReason: "toolUse" });
      },
      ctx => {
        const r = JSON.parse(ctx.messages.find(m => m.role === "toolResult").content[0].text);
        assert.equal(r.status, "PASS");
        const supplied = JSON.parse(ctx.messages.find(m => m.role === "user").content[0].text);
        return fauxAssistantMessage(JSON.stringify({ reviewerId: `claimed-reviewer-${i}`, questionIds: supplied.group.questions.map(q => q.id), verdict: "PASS", rationale: `MOCK-REVIEW-${i}: independent mocked approval; not semantic quality evidence.`, mocked: true }));
      },
    ]);
    const review = await executeSubagent({ agent: "semantic-reviewer", task: reviewTask }, context);
    assert.equal(review.status, "completed", JSON.stringify(review));
    reviews.push(review);
  }
  // Bind identity from the native lifecycle result, never trust the model's claim.
  input.semanticReviews = reviews.map(review => ({ ...JSON.parse(review.results[0].output), reviewerId: review.results[0].sessionId }));
  const final = await tools([
    ["validate_group", { group: g }],
    ["check_grading_parity", { question: solvedQuestion, cases: [{ id: "blind-answer", answer: solved.answer, expectedCorrect: true }] }],
    ["verify_evidence", input],
    ["inspect_delivery_projection", { exam: paper, projectionJson: blindTask }],
  ]);
  for (const r of final) assert.equal(r.status, "PASS", JSON.stringify(r));
  assert.equal(final[2].ieltsQualityEstablished, false);
  assert.equal(final[2].semanticReviewCount, 2);
  const children = [generator, validator, blind, ...reviews].map(r => r.results[0]);
  assert.equal(new Set(children.map(c => c.sessionId)).size, 5);
  const expectedTasks = [null, validatorTask, blindTask, reviewTask, reviewTask];
  for (const [i, c] of children.entries()) {
    assert.notEqual(c.sessionId, context.parentSessionId);
    assert.ok(c.sessionFile.startsWith(context.sessionDir));
    const messages = readFileSync(c.sessionFile, "utf8").trim().split("\n").map(line => JSON.parse(line)).filter(e => e.type === "message").map(e => e.message);
    assert.ok(messages.some(m => m.role === "toolResult" && names.includes(m.toolName)), `No native IELTS result in ${c.agent}`);
    const users = messages.filter(m => m.role === "user");
    assert.equal(users.length, 1);
    if (expectedTasks[i]) assert.equal(users[0].content[0].text, expectedTasks[i]);
  }
  t.diagnostic(JSON.stringify({ status: "PASS", diagnostics: final.flatMap(r => r.diagnostics), mocked: true, ieltsQualityEstablished: false, nativeChildSessionCount: children.length, checks: final.map(r => r.status), counts: { questionCount: final[0].questionCount, answerSlotCount: final[0].answerSlotCount, scoringUnitCount: final[0].scoringUnitCount, questionGroupCount: final[0].questionGroupCount } }));
  const blindLog = readFileSync(blind.results[0].sessionFile, "utf8");
  assert.ok(!blindLog.includes("PRIVATE-"));
  // Public specifications mention key field names, but never include this item's key values.
  assert.ok(!blindLog.includes('\\"blankAcceptTexts\\":{'));
});
