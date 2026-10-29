import { createHash, randomUUID } from "node:crypto";
import { existsSync, lstatSync, mkdirSync, readFileSync, realpathSync, readdirSync, symlinkSync, writeFileSync } from "node:fs";
import { basename, dirname, extname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { validateBlindTaskInput } from "./projection.ts";

export const specialistNames = ["reading-generator", "question-validator", "blind-solver", "semantic-reviewer"] as const;
export type Profile = "authoring" | "strict-blind" | "debug";
export const policyError = (message: string): never => { throw new Error(`READING_POLICY: ${message}`); };
export const within = (root: string, path: string) => path === root || path.startsWith(root + sep);
export const digest = (text: string) => createHash("sha256").update(text).digest("hex");
export const uuid = (value: unknown): value is string => typeof value === "string" && /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(value);
export function object(value: unknown, label: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) || ![Object.prototype, null].includes(Object.getPrototypeOf(value))) policyError(`${label} must be a plain object`);
  return value as Record<string, unknown>;
}
export function fields(value: Record<string, unknown>, allowed: readonly string[], label: string) {
  if (Object.keys(value).some(key => !allowed.includes(key))) policyError(`${label} contains unsupported controls`);
}

const nativeSpaces = /[\u00a0\u2000-\u200a\u202f\u205f\u3000]/u;
export function pathSpelling(raw: unknown): asserts raw is string {
  if (typeof raw !== "string" || !raw || /[\\\x00-\x1f\x7f@~]/u.test(raw) || raw.split("/").includes("..")) policyError("Invalid path or traversal");
  if (nativeSpaces.test(raw as string)) policyError("Ambiguous Unicode-space paths are unsupported by native tool normalization");
}
/** Exact paths only: no shell expansion, native spelling fallbacks, links or devices. */
export function checkedPath(root: string, raw: unknown, mustExist = false, hidden = false): string {
  pathSpelling(raw);
  if (nativeSpaces.test(root)) policyError("Ambiguous Unicode-space workspace root");
  if (realpathSync(root) !== root || !lstatSync(root).isDirectory()) policyError("Workspace root changed");
  const path = resolve(root, raw);
  if (!within(root, path)) policyError("Path is outside the assigned workspace");
  const parts = relative(root, path).split(sep).filter(Boolean);
  if (!hidden && parts.some(part => part.startsWith("."))) policyError("Hidden resources are not authoring artifacts");
  let current = root;
  for (const part of parts) {
    current = join(current, part);
    let stat;
    try { stat = lstatSync(current); }
    catch (error) {
      if (!mustExist && (error as NodeJS.ErrnoException).code === "ENOENT") continue;
      throw error;
    }
    if (stat.isSymbolicLink() || realpathSync(current) !== current) policyError("Symlink escape or alias");
    if (!stat.isDirectory() && (!stat.isFile() || stat.nlink !== 1)) policyError("Special files and hardlinks are forbidden");
  }
  return path;
}
export function readJson<T = Record<string, unknown>>(root: string, path: string): T {
  return JSON.parse(readFileSync(checkedPath(root, path, true, true), "utf8")) as T;
}
export function exclusiveJson(root: string, path: string, value: unknown) {
  const target = checkedPath(root, path, false, true);
  mkdirSync(dirname(target), { recursive: true, mode: 0o700 });
  checkedPath(root, dirname(target), true, true);
  writeFileSync(target, JSON.stringify(value, null, 2), { flag: "wx", mode: 0o600 });
}
export interface InputSnapshot { name: string; sha256: string; source: string }
export interface ChildScope {
  version: 1; id: string; run: string; parentSessionId: string; root: string; cwd: string;
  agent: string; profile: Profile; inputs: InputSnapshot[]; taskHash: string; task: string; previous: boolean;
  debugOf?: string; recheckOf?: string; output: string;
}
export interface SolveReceipt {
  version: 1; id: string; agent: string; profile: Profile; nativeSessionId: string;
  completed: boolean; answer: string; inputHashes: string[]; debugOf?: string; recheckOf?: string;
  blindness: "UNVERIFIED" | "STRUCTURAL_ONLY" | "NON_BLIND";
  independentBlindEvidence: boolean; ieltsQualityEstablished: false; accepted: false; published: false;
}
interface Grant { id: string; attemptId: string; parentSessionId: string; keys: Array<{ name: string; content: string; sha256: string }> }
export interface TaskRequest {
  agent: string; task: string; profile: Profile; inputs: string[]; model?: string;
  output?: string; cwd?: string; debugGrant?: string; recheckOf?: string; previous: boolean;
}

export function taskRequest(raw: unknown): TaskRequest {
  const item = object(raw, "task");
  fields(item, ["agent", "task", "model", "output", "cwd", "options"], "task");
  if (typeof item.agent !== "string" || !(specialistNames as readonly string[]).includes(item.agent) || typeof item.task !== "string" || !item.task.trim()) policyError("A task needs an IELTS specialist and nonempty task text");
  const options = item.options === undefined ? {} : object(item.options, "options");
  fields(options, ["reading", "context"], "options");
  if (options.context !== undefined && options.context !== "fresh") policyError("Children must start fresh, never fork or resume");
  const reading = options.reading === undefined ? {} : object(options.reading, "options.reading");
  fields(reading, ["profile", "inputs", "debugGrant", "recheckOf", "previous"], "options.reading");
  const profile = reading.profile ?? "authoring";
  if (!["authoring", "strict-blind", "debug"].includes(profile as string)) policyError("Unknown Reading profile");
  if (profile !== "authoring" && item.agent !== "blind-solver") policyError("Solver profiles require blind-solver");
  if (reading.previous !== undefined && typeof reading.previous !== "boolean") policyError("previous must be boolean");
  if (reading.previous && item.agent === "blind-solver") policyError("A solver never receives sibling output; export a public handoff explicitly");
  const inputs = reading.inputs ?? [];
  if (!Array.isArray(inputs) || inputs.length > 32 || inputs.some(value => typeof value !== "string" || !value)) policyError("inputs must list at most 32 exact file paths");
  for (const key of ["model", "output", "cwd"] as const) if (item[key] !== undefined && (typeof item[key] !== "string" || !item[key] || /[\x00-\x1f]/u.test(item[key] as string))) policyError(`Invalid ${key}`);
  if (profile === "debug" && !uuid(reading.debugGrant)) policyError("NON_BLIND debug requires an operator-issued debugGrant");
  if (profile !== "debug" && reading.debugGrant !== undefined) policyError("A debug grant cannot be relabeled as blind");
  if (reading.recheckOf !== undefined && (!uuid(reading.recheckOf) || item.agent !== "blind-solver" || profile === "debug")) policyError("recheckOf is only for a fresh authoring/strict solver after a frozen NON_BLIND attempt");
  if (item.cwd && (isAbsolute(item.cwd as string) || (item.cwd as string).split(/[\\/]/u).some(part => part === ".." || (part.startsWith(".") && part !== ".")))) policyError("cwd must be a non-hidden subdirectory of this child's workspace");
  return { agent: item.agent as string, task: item.task as string, profile: profile as Profile, inputs: inputs as string[], previous: reading.previous === true,
    ...(item.model ? { model: item.model as string } : {}), ...(item.output ? { output: item.output as string } : {}),
    ...(item.cwd ? { cwd: item.cwd as string } : {}), ...(reading.debugGrant ? { debugGrant: reading.debugGrant as string } : {}),
    ...(reading.recheckOf ? { recheckOf: reading.recheckOf as string } : {}) };
}
function inputFiles(run: string, request: TaskRequest) {
  return request.inputs.map(source => {
    const path = checkedPath(run, source, true);
    if (!lstatSync(path).isFile() || ![".json", ".md", ".txt", ".csv"].includes(extname(path))) policyError("Input resources must be regular authoring files");
    const rel = relative(run, path).split(sep).join("/");
    if (request.agent === "blind-solver" && !rel.startsWith("artifacts/public/") && !rel.startsWith("inputs/public/")) policyError("Solver inputs must be explicitly exported into artifacts/public or inputs/public; private keys are not solver inputs");
    if (rel.startsWith("children/") || rel.startsWith("workflows/")) policyError("Export handoffs as artifacts, not sibling workspaces or executable workflows");
    return { path, content: readFileSync(path, "utf8") };
  });
}
export function validateRequest(run: string, parentSessionId: string, request: TaskRequest) {
  const inputs = inputFiles(run, request);
  if (request.profile === "strict-blind") {
    const text = inputs.length === 1 ? inputs[0].content : request.task;
    if (inputs.length > 1 || !validateBlindTaskInput(text).ok) policyError("Strict blind requires exactly a canonical student projection, inline or in one public JSON file");
  }
  if (request.recheckOf) {
    const receipt = readJson<SolveReceipt>(run, `.history/attempts/${request.recheckOf}.json`);
    if (receipt.profile !== "debug" || !receipt.completed) policyError("recheckOf requires a completed NON_BLIND debug attempt");
  }
  if (request.debugGrant) {
    const grant = readJson<Grant>(run, `.history/debug-grants/${request.debugGrant}.json`);
    if (grant.parentSessionId !== parentSessionId || existsSync(join(run, `.history/debug-used/${grant.id}.json`))) policyError("Debug grant is spent or belongs to another parent session");
  }
  if (request.output && (isAbsolute(request.output) || request.output.split(/[\\/]/u).some(part => part === ".." || part.startsWith(".")) || ![".md", ".txt", ".json", ".csv"].includes(extname(request.output)))) policyError("output must be an artifact filename beneath this child's outputs");
}

export function prepareChild(run: string, parentSessionId: string, request: TaskRequest) {
  validateRequest(run, parentSessionId, request);
  const id = randomUUID(), root = join(run, "children", id);
  checkedPath(run, "children", false);
  mkdirSync(root, { recursive: true, mode: 0o700 });
  for (const name of ["inputs", "workspace", "outputs"]) mkdirSync(join(root, name), { mode: 0o700 });
  const snapshots: InputSnapshot[] = [];
  const copy = (name: string, content: string, source: string) => {
    writeFileSync(join(root, "inputs", name), content, { flag: "wx", mode: 0o600 });
    snapshots.push({ name, source, sha256: digest(content) });
  };
  const files = inputFiles(run, request);
  files.forEach((file, index) => copy(`${index}-${basename(file.path)}`, file.content, relative(run, file.path)));
  let debugOf: string | undefined;
  if (request.debugGrant) {
    const grant = readJson<Grant>(run, `.history/debug-grants/${request.debugGrant}.json`);
    exclusiveJson(run, `.history/debug-used/${grant.id}.json`, { childId: id, parentSessionId });
    const receipt = readJson<SolveReceipt>(run, `.history/attempts/${grant.attemptId}.json`);
    copy("original-solve.json", JSON.stringify(receipt, null, 2), "frozen independent solve");
    grant.keys.forEach((key, index) => copy(`key-${index}-${key.name}`, key.content, "operator-approved key snapshot"));
    debugOf = grant.attemptId;
  }
  const cwd = join(root, "workspace", request.cwd ?? ".");
  mkdirSync(cwd, { recursive: true, mode: 0o700 });
  // Native discovery at the actual child cwd, not a fake tool-only cwd.
  mkdirSync(join(cwd, ".generation"), { mode: 0o700 });
  for (const name of ["agents", "extensions", "reading"]) symlinkSync(realpathSync(join(run, ".generation", name)), join(cwd, ".generation", name), process.platform === "win32" ? "junction" : "dir");
  writeFileSync(join(cwd, ".generation/settings.json"), readFileSync(join(run, ".generation/settings.json")), { flag: "wx", mode: 0o600 });
  const task = request.profile === "strict-blind" && files.length === 1 ? files[0].content : request.task;
  const output = join(root, "outputs", request.output ?? "result.md");
  const scope: ChildScope = { version: 1, id, run, root, cwd, parentSessionId, agent: request.agent, profile: request.profile,
    inputs: snapshots, taskHash: digest(task), task, previous: request.previous, output, ...(debugOf ? { debugOf } : {}), ...(request.recheckOf ? { recheckOf: request.recheckOf } : {}) };
  exclusiveJson(run, `.history/scopes/${id}.json`, scope);
  // A pointer only, never an authority supplied by the task or workflow.
  exclusiveJson(root, ".reading-scope.json", { id, run });
  if (cwd !== root) exclusiveJson(cwd, ".reading-scope.json", { id, run });
  return { scope, launch: { agent: request.agent, task, cwd, output, ...(request.model ? { model: request.model } : {}) } };
}
export function loadChildScope(run: string, cwd: string): ChildScope {
  const checked = checkedPath(run, cwd, true);
  if (!within(join(run, "children"), checked)) policyError("Child launch has no dedicated workspace; use Reading's guarded delegation");
  const pointer = readJson<{ id: string; run: string }>(checked, ".reading-scope.json");
  if (!uuid(pointer.id) || pointer.run !== run) policyError("Invalid child scope pointer");
  const scope = readJson<ChildScope>(run, `.history/scopes/${pointer.id}.json`);
  if (scope.cwd !== checked || scope.root !== join(run, "children", scope.id) || scope.run !== run) policyError("Child scope does not match cwd");
  return scope;
}
export function grantDebug(run: string, parentSessionId: string, value: unknown): string {
  const request = object(value, "debug approval"); fields(request, ["attemptId", "keys"], "debug approval");
  if (!uuid(request.attemptId) || !Array.isArray(request.keys) || !request.keys.length || request.keys.length > 16) policyError("Supply attemptId and 1–16 exact key files");
  const receipt = readJson<SolveReceipt>(run, `.history/attempts/${request.attemptId}.json`);
  const scope = readJson<ChildScope>(run, `.history/scopes/${request.attemptId}.json`);
  if (scope.parentSessionId !== parentSessionId || receipt.agent !== "blind-solver" || receipt.profile === "debug" || !receipt.completed) policyError("Freeze a completed independent solve in this session before exposing a key");
  const keys = (request.keys as unknown[]).map(raw => {
    const path = checkedPath(run, raw, true);
    if (!lstatSync(path).isFile() || relative(run, path).startsWith("children" + sep)) policyError("Approve exact exported key artifacts, not sibling files");
    const content = readFileSync(path, "utf8");
    return { name: basename(path), content, sha256: digest(content) };
  });
  const id = randomUUID(); exclusiveJson(run, `.history/debug-grants/${id}.json`, { id, attemptId: request.attemptId, parentSessionId, keys });
  return id;
}
export function latestAnswer(branch: Array<{ type: string; message?: unknown }>): { completed: boolean; answer: string } {
  const messages = branch.filter(entry => entry.type === "message").map(entry => entry.message as { role?: string; stopReason?: string; content?: unknown });
  const last = messages.filter(message => message?.role === "assistant").at(-1);
  const answer = typeof last?.content === "string" ? last.content : Array.isArray(last?.content)
    ? last.content.filter((part): part is { type: "text"; text: string } => part?.type === "text" && typeof part.text === "string").map(part => part.text).join("\n") : "";
  const toolCalls = Array.isArray(last?.content) && last.content.some(part => part?.type === "toolCall");
  return { completed: Boolean(answer.trim()) && last?.stopReason === "stop" && !toolCalls, answer };
}
export function attemptIds(run: string) {
  const dir = checkedPath(run, ".history/attempts", false, true);
  return existsSync(dir) ? readdirSync(dir).filter(name => name.endsWith(".json")).map(name => name.slice(0, -5)) : [];
}
