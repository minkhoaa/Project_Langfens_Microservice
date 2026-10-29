import { randomUUID } from "node:crypto";
import { copyFileSync, existsSync, lstatSync, mkdirSync, readFileSync, realpathSync, symlinkSync, writeFileSync } from "node:fs";
import { basename, dirname, extname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = realpathSync(fileURLToPath(new URL("../..", import.meta.url)));
const repository = resolve(root, "../..");
const within = (parent, path) => path === parent || path.startsWith(parent + sep);

/** Application configuration only. Native Core still owns discovery and execution. */
export function readingConfiguration(args, runtime) {
  const forwarded = [], inputs = [];
  const readingConfig = JSON.parse(readFileSync(join(root, ".generation/config/reading.json"), "utf8"));
  if (!readingConfig || typeof readingConfig !== "object" || Array.isArray(readingConfig) ||
      Object.keys(readingConfig).some(key => key !== "bubblewrapPath") ||
      (readingConfig.bubblewrapPath !== null && typeof readingConfig.bubblewrapPath !== "string")) throw new Error("Reading configuration requires bubblewrapPath (absolute path or null)");
  let bubblewrapPath = runtime.env.GENERATION_HARNESS_READING_BWRAP ?? readingConfig.bubblewrapPath ?? "";
  const flags = new Set(["--approve", "--no-approve", "--offline", "--no-session", "--print", "-p", "--verbose"]);
  const values = new Set(["--mode", "--provider", "--model", "--thinking"]);
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--reading-bwrap") {
      if (!args[i + 1] || args[i + 1].startsWith("--")) throw new Error("Reading --reading-bwrap requires an absolute executable path");
      bubblewrapPath = args[++i];
    } else if (arg === "--reading-input") {
      if (!args[i + 1]) throw new Error("Reading input requires a file");
      inputs.push(args[++i]);
    } else if (flags.has(arg)) forwarded.push(arg);
    else if (values.has(arg) && args[i + 1] && !args[i + 1].startsWith("-")) forwarded.push(arg, args[++i]);
    else throw new Error(`Reading launch does not permit argument: ${arg}. Enter task text after startup; approve files with --reading-input.`);
  }
  if (bubblewrapPath && !isAbsolute(bubblewrapPath)) throw new Error("Reading Bubblewrap path must be absolute");
  runtime.env.GENERATION_HARNESS_READING_BWRAP = bubblewrapPath;
  // Approve regular input snapshots, never repository implementation/configuration.
  const approved = inputs.map(input => {
    const path = resolve(input), canonical = realpathSync(path), stat = lstatSync(path);
    if (canonical !== path || !stat.isFile() || stat.nlink !== 1 || ![".md", ".txt", ".json"].includes(extname(path)) ||
        (within(repository, canonical) && !within(join(root, ".generation/fixtures"), canonical))) {
      throw new Error(`Reading input is linked, unsupported or protected: ${input}`);
    }
    return canonical;
  });
  const runs = join(runtime.runtime, "reading-runs");
  mkdirSync(runs, { recursive: true, mode: 0o700 });
  if (realpathSync(runs) !== runs) throw new Error("Reading runs path must not contain symlinks");
  const workspace = join(runs, randomUUID());
  mkdirSync(workspace, { mode: 0o700 });
  for (const name of ["input", "drafts", "reviews", "revisions", "final", ".history", "inputs/public", "inputs/private", "artifacts/public", "artifacts/private", "workflows", "children"]) mkdirSync(join(workspace, name), { recursive: true, mode: 0o700 });
  approved.forEach((input, i) => copyFileSync(input, join(workspace, "input", `${i}-${basename(input)}`)));
  // A real project root keeps native Subagents lifecycle/schedule paths local.
  // Only immutable authoring resources are linked; model tools cannot access them.
  mkdirSync(join(workspace, ".generation"), { mode: 0o700 });
  for (const name of ["extensions", "agents", "reading"]) {
    symlinkSync(join(root, ".generation", name), join(workspace, ".generation", name), process.platform === "win32" ? "junction" : "dir");
  }
  const projectSettings = JSON.parse(readFileSync(join(root, ".generation/settings.json"), "utf8"));
  const roleTools = {
    "reading-generator": ["get_question_spec", "validate_question", "validate_group"],
    "question-validator": ["get_question_spec", "validate_question", "validate_group", "validate_exam", "check_grading_parity", "inspect_delivery_projection"],
    "semantic-reviewer": ["get_question_spec", "verify_evidence"],
    "blind-solver": ["get_question_spec"],
  };
  const agentOverrides = {};
  for (const [name, tools] of Object.entries(roleTools)) {
    agentOverrides[name] = { tools: [...tools, "read", "write", "edit", ...(name === "blind-solver" ? [] : ["bash"])],
      subagentOnlyExtensions: [join(root, ".generation/extensions/reading.ts"), join(root, ".generation/reading/child-guard.ts")],
      defaultContext: "fresh", inheritProjectContext: false, inheritGlobalContext: false, inheritSkills: false,
      ...(name === "blind-solver" ? { systemPrompt: "Solve the supplied IELTS Reading task independently using only explicitly assigned inputs. Use read for input files and write/edit for your own answers. Never access keys, sibling workspaces or parent history. Your scope's profile determines whether this is authoring, strict blind, or operator-approved NON_BLIND debugging. Never claim that matching a key proves correctness; unresolved ambiguity is UNCERTAIN. Do not publish or delegate." } : {}),
    };
  }
  projectSettings.subagents = { agentOverrides };
  writeFileSync(join(workspace, ".generation/settings.json"), JSON.stringify(projectSettings, null, 2), { flag: "wx", mode: 0o600 });
  // Fresh native agent configuration: no Development extensions, shell prefix,
  // packages or context. Only explicitly local provider configuration is copied.
  const agentDir = join(workspace, ".agent");
  mkdirSync(agentDir, { mode: 0o700 });
  // Native parallel roots do not propagate their async:false to children. Keep
  // Reading children awaited/in-process via native config, not a new runner.
  mkdirSync(join(agentDir, "extensions/subagent"), { recursive: true, mode: 0o700 });
  writeFileSync(join(agentDir, "extensions/subagent/config.json"), JSON.stringify({ asyncByDefault: false, intercomBridge: { mode: "off" } }), { flag: "wx", mode: 0o600 });
  for (const name of ["models.json", "auth.json"]) {
    const source = join(runtime.env.GENERATION_HARNESS_AGENT_DIR, name);
    if (!existsSync(source)) continue;
    if (!lstatSync(source).isFile() || realpathSync(source) !== source) throw new Error(`Reading provider configuration is not a regular local file: ${name}`);
    copyFileSync(source, join(agentDir, name));
  }
  const preferences = join(runtime.env.GENERATION_HARNESS_AGENT_DIR, "settings.json");
  const selected = {};
  if (existsSync(preferences)) {
    if (!lstatSync(preferences).isFile() || realpathSync(preferences) !== preferences) throw new Error("Reading preferences must be a regular local file");
    const settings = JSON.parse(readFileSync(preferences, "utf8"));
    for (const name of ["defaultProvider", "defaultModel", "defaultThinkingLevel"]) {
      if (settings[name] === undefined) continue;
      if (typeof settings[name] !== "string") throw new Error(`Reading preference ${name} must be a string`);
      selected[name] = settings[name];
    }
  }
  writeFileSync(join(agentDir, "settings.json"), JSON.stringify(selected), { flag: "wx", mode: 0o600 });
  runtime.env.GENERATION_HARNESS_AGENT_DIR = agentDir;
  runtime.env.GENERATION_HARNESS_SESSION_DIR = join(workspace, ".sessions");
  for (const key of Object.keys(runtime.env)) {
    if (["BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS", "CDPATH", "GLOBIGNORE", "LD_PRELOAD", "LD_LIBRARY_PATH"].includes(key) || key.startsWith("BASH_FUNC_") || key.startsWith("DYLD_")) delete runtime.env[key];
  }
  writeFileSync(join(workspace, ".history/run.json"), JSON.stringify({ workspace, approvedInputs: approved.map((_, i) => relative(workspace, join(workspace, "input", `${i}-${basename(approved[i])}`))), publication: "NEVER_AUTOMATIC", state: "DRAFT" }, null, 2), { flag: "wx", mode: 0o600 });
  return {
    workspace,
    args: ["--no-context-files", "--no-skills", "--no-prompt-templates", "--no-mcp", "--system-prompt", readingPrompt(workspace), "--extension", join(root, ".generation/reading/workspace-guard.ts"), ...forwarded],
  };
}

export function readingPrompt(workspace) {
  return `${readFileSync(join(root, ".generation/prompts/reading-system.md"), "utf8")}\nAssigned workspace: ${workspace}`;
}

/** Allocate configuration for a fresh native session; never creates an agent loop. */
export function nextReadingConfiguration(previousRun, inherited = process.env) {
  const previous = realpathSync(previousRun);
  if (basename(dirname(previous)) !== "reading-runs") throw new Error("Reading session root is invalid");
  const runtime = dirname(dirname(previous));
  const env = { ...inherited, GENERATION_HARNESS_RUNTIME_DIR: runtime, GENERATION_HARNESS_AGENT_DIR: inherited.GENERATION_HARNESS_AGENT_DIR ?? join(previous, ".agent") };
  const next = readingConfiguration([], { runtime, env });
  Object.assign(env, { GENERATION_HARNESS_READING_WORKSPACE: next.workspace, GENERATION_HARNESS_WORKING_DIR: next.workspace, GENERATION_HARNESS_WORKSPACE_DIR: next.workspace });
  return { ...next, env };
}
