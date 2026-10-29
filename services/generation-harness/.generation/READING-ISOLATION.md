# Reading authoring, scoped workflows and blind/debug evidence

## Start and new sessions

```sh
cd services/generation-harness
npm run start:reading
npm run start:reading -- --reading-input /explicitly/approved/passage.md
npm run start:reading -- --reading-bwrap /absolute/path/to/bwrap
```

Each launch allocates a UUID under `.runtime/reading-runs/` (or the explicitly
selected `GENERATION_HARNESS_RUNTIME_DIR/reading-runs/`). No run ID is hardcoded.
The native role is IELTS author/editor, not coding agent; inherited repository
context, skills, prompt templates and MCP are disabled.

Inside Reading, **`/reading-new`** creates a new folder AND a fresh native session,
with actual new session cwd/header/services, new guards and no imported artifacts
or conversation. Old folders remain intact and inaccessible to the new session's
tools. This uses public `SessionManager` and `ctx.switchSession()`, not a new
runtime. The helper persists the SDK-generated empty header and authorizes only
that exact internal transition. Credentials/provider services remain trusted,
process-scoped native configuration; the OS process startup cwd is not the
security authority—the active native session cwd and tool scope are.

**Exact SDK limitation:** native `/new`, `/reset`, `/clear` and RPC `new_session`
cannot select another cwd through the frozen public API. They are cancelled with
a notice to use `/reading-new`, rather than silently reusing an old folder.
Built-in TUI commands take precedence over extension commands; no private method
patch or fake path-only reset was introduced. Arbitrary resume/import/fork stays
blocked. RPC hosts may submit the registered `/reading-new` operator command
through their ordinary prompt/command path.

Development `npm start`, `start:tui`, `start:rpc`, `dev`, and Development `--cwd`
behavior are unchanged. `--cwd .` in Development is not isolated Reading Mode.
Source agent definitions remain backward-compatible with offline VS1–VS4; the
Reading launcher supplies scoped tools/prompts through native per-run project
agent overrides, not Core/Subagents edits.

## Folder and permission model

```text
reading-runs/<run-id>/
  input/                       # approved launch-time snapshots (read-only)
  inputs/public/               # explicitly public input staging
  inputs/private/              # operator-managed private input staging
  artifacts/public/            # parent exports student material here
  artifacts/private/           # keys and private annotations
  drafts/ reviews/ revisions/ final/
  workflows/                   # editable JSON plans, not arbitrary executable code
  children/<child-id>/
    inputs/                    # selected immutable snapshots
    workspace/                 # native child cwd, editable; cwd may select a subdir
    outputs/                   # child artifacts and native final-output binding
    .reading-scope.json        # protected pointer, not model-supplied authority
  .history/                    # protected scopes, bindings, edits, diagnostics,
                               # frozen answers and operator debug grants
  .generation/ .agent/ .sessions/ # native infrastructure, unavailable to model tools
```

- Parent can author artifacts throughout its current session, including inspecting
  child outputs. Inputs, validation receipts, hidden configuration, scope records
  and original frozen answers cannot be modified through model tools.
- Each child has an actual distinct native cwd and a protected descriptor bound
  to one native session ID. It reads only its own inputs/workspace/outputs and
  writes only its workspace/outputs. No parent/key/sibling/other-session/source
  access is allowed, even via absolute paths, `../`, symlinks, hardlinks, spelling
  aliases or special files. Unicode spaces that native tools normalize are
  rejected before native execution. Hostile external check/use races remain
  outside this application-level guarantee.
- Plain child filenames resolve against its actual native cwd. Explicit
  `inputs/`, `workspace/`, `outputs/` prefixes resolve against its child root.
- Generator/validator/reviewer can use read/write/edit and guarded bash in their
  scope, alongside their existing domain tools. Solver has read/write/edit and
  get_question_spec in authoring/debug, but no shell. Strict blind narrows to
  exactly get_question_spec at startup. The parent's four built-ins and the
  seven domain tools are preserved, not replaced.
- File sharing is explicit snapshotting, never permission to traverse a sibling
  directory. Solver files must be exported under artifacts/public or inputs/public.
  Other roles may receive selected private artifacts when their task needs them.
  Current handoffs support regular `.md`, `.txt`, `.json`, `.csv` files (at most
  32 files per child). They must exist when the plan is admitted. Image/binary
  handoff and live shared mounts are not implemented.

The public hooks enforce paths before native read/write/edit and retain revision
snapshots/validation diagnostics. A required child policy extension and native
capability ceiling follow native child launches; non-native/external runners are
rejected rather than allowed to omit the policy. Extension-loading failures stop
those child launches before model requests.

## Flexible task and file inputs

```json
{
  "agent": "blind-solver",
  "task": "Read the provided passage and answer the questions independently.",
  "output": "answers.json",
  "options": {
    "reading": {
      "inputs": ["artifacts/public/student.md"]
    }
  }
}
```

This is a normal native `subagent` call. Default profile is **authoring**:
natural text, JSON and selected files work without a canonical-projection schema.
Optional `model` uses native configured-model resolution. `cwd` selects a relative
subdirectory of the newly allocated child's workspace, not an arbitrary parent
or repository path. `output` selects a relative artifact filename inside that
child's outputs. Broader tools, fork/resume, worktrees, extensions, host gates,
and unrecognized launch controls cannot be granted by task data.

Results include `details.reading.attempts` and model-visible scope receipts:
child ID/root/cwd, profile, blindness classification, frozen status and lineage.
They always retain `accepted:false`, `published:false`, and
`ieltsQualityEstablished:false`. Child completion is not IELTS acceptance.

## Native parallel and ordered JSON plans

Independent jobs:

```json
{
  "workflow": "parallel",
  "args": {
    "tasks": [
      {"agent":"semantic-reviewer","task":"Review wording independently","options":{"reading":{"inputs":["artifacts/public/section.json"]}}},
      {"agent":"question-validator","task":"Validate canonical structure","options":{"reading":{"inputs":["artifacts/public/section.json"]}}}
    ]
  }
}
```

Ordered stages use `workflow:"reading.plan"` with `args.steps`, or a JSON file
inside workflows/ via `workflow:"./workflows/section.json"`:

```json
{
  "steps": [
    {"agent":"reading-generator","task":"Draft a section from the assigned brief","output":"section.json"},
    {"agent":"question-validator","task":"Check the preceding generated artifact","options":{"reading":{"previous":true}}},
    {"parallel":[
      {"agent":"semantic-reviewer","task":"Independent review of an already-exported version"},
      {"agent":"semantic-reviewer","task":"Check ambiguity independently on that same supplied version"}
    ]}
  ]
}
```

Only a non-solver may opt into `options.reading.previous:true`, after the first
stage. The resulting user input is hashed in its frozen receipt. A solver never
receives sibling results this way: parent must deliberately export/validate the
public handoff before a separate solve. Files for an admitted plan are immutable
snapshots; use a subsequent call to hand off newly created file artifacts.

Every task in a batch/plan is authorized before any child starts. The extension
then expands only validated data into a fixed native workflow resource using
`runs.all`; native Subagents owns execution, concurrency, cancellation, errors
and output binding. There is no new coordinator, loop, scheduler or retry engine.
Native results retain input order. Children are awaited/in-process, fresh, scoped
to the project and never detached through inherited defaults. Native attested
coding acceptance/intercom instructions are disabled for these IELTS leaf tasks.

Bounds: 1–8 tasks per parallel stage, at most 16 stages/32 children per plan,
16 KiB prepared native workflow args. Use file references or smaller batches for
large exams. These are native-resource constraints, not claims that arbitrary
workflows can be safely recognized by string filtering.

**Unsupported public capability:** arbitrary JS reply-block/file workflows remain
blocked. Although their JS sandbox has no filesystem and raw runs.host is denied,
`runs.run` can request host gates/other launch controls outside tool hooks. There
is no public per-child-launch authorization hook that can safely gate all such
controls without changing frozen Subagents. The shipped JSON plans provide the
supported sequence/parallel path; no alternate shell/runner fallback is used.

## Blindness is separate from debug usefulness and OS safety

| Profile | Input/access | Evidence classification |
| --- | --- | --- |
| authoring (default) | Natural task + public input snapshots; own read/write/edit | UNVERIFIED content blindness; not certified blind validation |
| strict-blind | Exact canonical student projection inline or one public JSON file; get_question_spec only | STRUCTURAL_ONLY isolation; independent solve, not semantic quality proof |
| debug | Fresh solver; operator-approved key snapshots plus frozen original answer | NON_BLIND; never independent blind evidence |

Strict blind retains the original input/context/result guards, fresh-history
checks and tool-result redaction. Only known native `Task: ` and exact authorized
output-binding envelopes are normalized before the unchanged projection schema.
Additional prose, private fields and poisoned tool results remain rejected.

File isolation cannot detect answer hints written into a passage or natural task.
A parent can export incorrect material as public. Thus flexible authoring is not
silently promoted into strict evidence; even strict structural isolation cannot
attest provenance or IELTS semantics.

### Freeze → approved debug → versioned correction → fresh recheck

1. Finish the initial solve. A protected receipt freezes the actual final answer,
   native session ID, input hashes and profile. Tool-use/truncated/error/aborted
   responses do not count as a completed solve and cannot authorize key exposure.
2. The **operator**, not a model tool, issues:

   ```text
   /reading-debug {"attemptId":"<original-child-id>","keys":["artifacts/private/key.json"]}
   ```

   The command snapshots only those exact files and creates a single-use grant
   scoped to that parent session. Changing a key/output afterward cannot change
   the frozen approved snapshots/original answer.
3. Launch a NEW solver using `options.reading:{profile:"debug",debugGrant:"<grant-id>"}`.
   It receives inputs/original-solve.json plus selected key snapshots. Compare
   passage, question, solver and key without assuming any is correct. Propose
   corrected versions in its outputs, or retain UNCERTAIN for human adjudication.
4. Parent reviews/exports a new public version and launches another NEW solver
   with `options.reading:{profile:"strict-blind",inputs:["artifacts/public/projection.json"],recheckOf:"<debug-child-id>"}`.
   This new native session receives neither debug history nor key snapshots.

A spent grant cannot be reused, a debug scope cannot become blind, and reusing an
output filename cannot rewrite original evidence. NON_BLIND is useful, scoped
and legitimate for debugging; its disqualification is epistemic, not a claim
that debugging is forbidden or inherently an OS escape.

## Bash and exact trust limits

`.generation/config/reading.json` selects `/usr/bin/bwrap` by default. Override
with `--reading-bwrap` or `GENERATION_HARNESS_READING_BWRAP`. Nothing is installed
or discovered through PATH. Missing/unsafe binary, unsupported platform, denied
namespace setup or unsafe shell configuration fails closed with BWRAP diagnostics.
An explicit invalid selection never falls back to another executable or shell.

Only `pwd`, `ls [path]`, `wc <file>` are accepted. Bubblewrap clears environment,
unshares namespaces, mounts only the applicable parent/child scope **read-only**
at /work plus trusted command executables and library directories. Child shell
cwd corresponds to its actual workspace subdirectory. Parent/key/sibling folders
are not mounted in a child sandbox. Redirects, pipes, substitutions, interpreters,
network/package commands and arbitrary scripts are not supported. Solver has no
shell; native !/!!/RPC direct bash is blocked. Use write/edit for mutations.

This remains a **model-tool boundary, not a whole-process sandbox**:

- Trusted Core/SDK/Subagents, native extensions, configured providers, OS binaries,
  libraries and operator configuration must be intact. Trusted SDK/extension or
  direct filesystem operations can bypass tool hooks; hostile RPC/SDK clients
  are not contained by these controls.
- Public hooks cannot atomically interpose on native filesystem syscalls. Hostile
  same-user processes, external link/root replacement races, malicious mounts and
  compromised trusted code are unsupported. Model tools themselves cannot create
  links or invoke an unguarded writer.
- Parent extension-load failures are not universally fatal in frozen Core; it has
  no mandatory-extension startup gate. Do not use a Reading session reporting
  policy/extension load errors. Required child-policy failures do fail the child
  before its first model request.
- Native login/export/model UI actions remain trusted operator operations. Audit
  files are protected from model tools, not cryptographically tamper-proof against
  the operator/OS or guaranteed durable across process crashes/disk failure.
- Bubblewrap contains the generated command, not Node/provider execution. macOS,
  Windows-native and Linux hosts without usable namespaces have no shell fallback.
- Deterministic PASS and native completion only proceed to review. UNCERTAIN stays
  distinct. No exam acceptance, DB publication, commit or push path is added.

## Offline verification

```sh
GENERATION_HARNESS_OFFLINE=1 npm test
GENERATION_HARNESS_OFFLINE=1 npm run typecheck
GENERATION_HARNESS_OFFLINE=1 ./node_modules/.bin/tsc --noEmit --project .generation/tsconfig.json
```

Tests use actual native tools, sessions and workflow execution with faux models,
never paid inference. Coverage includes flexible file tasks, real distinct child
cwd, private/sibling/source denial, traversal/link/Unicode aliases, readonly
inputs, native child Bubblewrap, operator-only key approval, immutable original
answers, NON_BLIND lineage, fresh strict recheck, JSON plan sequencing/parallel,
model/output/cwd controls, and new-folder session rotation. Existing VS1–VS4 and
legacy strict-blind suites remain unchanged in semantic contracts.

Latest verification evidence: `npm test` exited 0: **160/160 harness tests passed**,
**3491 Subagents tests passed**, 13 Subagents tests skipped, zero failures.
Both typecheck commands passed. The full verification log is
`/tmp/generation-harness-scoped-authoring-final.log`.
The frozen packages and backend implementation diff is empty.
