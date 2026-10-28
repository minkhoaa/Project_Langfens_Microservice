# Pi Subagents 0.83.1 migration — verification boundary

**Not certified as 100% parity.** The complete pinned native source/runtime and
public API surface have been restored, with broad offline evidence. Strong native
ESM state independence remains BLOCKED under the public-loader constraint; some
advanced configuration/host paths remain UNVERIFIED. Source presence, a successful
build, or an import-only test is not a behavioral PASS.

## Immutable reference and dependency compatibility

- Upstream: `nicobailon/pi-subagents`, commit
  **`312082429bda07714fe0fe7729fe8d4935de4c5a`**, package **0.83.1**, MIT,
  copyright Nico Bailon. Original license retained.
- The baseline checkout is external and temporary. No moving branch, upstream
  install script, global Pi executable, or global npm module is used at runtime.
- All 339 upstream `src/` files are adapted in this package, plus the detached
  runner/preload/retention/inspector scripts, workflow VM worker, 13 agent profiles,
  skills, prompts, and documentation. `UPSTREAM-PROVENANCE.json` records per-file
  original/adapted SHA-256 hashes, SDK namespace changes, and host adaptations.
- Original optional peers: Pi AI >=1.2.0, other Pi SDK peers `*`; development SDK
  1.2.0 and typebox 1.3.27. Local SDK/agent/AI/TUI peers are **1.4.0**, typebox
  **1.3.27**. The full adapted source typechecks against those public SDK exports.
- Direct upstream dependencies: Temporal polyfill 0.5.1, acorn 8.18.0, jiti 2.7.0,
  undici 8.12.3, yaml 2.8.3. The adaptation uses the already-installed local
  Temporal/acorn/jiti versions and host-compatible undici **8.10.2** and yaml
  **2.9.0**. Calendar, workflow parsing/VM, YAML-backed configuration and mocked
  integrations have offline tests; live HTTP/provider compatibility is not claimed.
- The lockfile was updated with `--offline --ignore-scripts --no-audit --no-fund`.
  No network installation or dependency lifecycle script was executed.

## Architecture and scope

The default entry point is the pinned upstream native extension, including its
activation, supervision, workflow, detached-process, recovery, management, fleet,
mission, schedule, watchdog, permissions and integration components. There is no
new coordinator or replacement agent loop.

`generation-harness-core` is unchanged. Native children use its existing
`DefaultResourceLoader`, `registerTool`, `ModelRuntime`, `SessionManager`,
`createAgentSession`, lifecycle and tool execution APIs. The existing named
Generation programmatic foreground API is preserved in `src/compat`, using the
same adapted native child factory; its established input/result contract is not
substituted for the default upstream tool protocol.

Generation-specific adaptations:

1. SDK imports and peer aliases target local Generation packages. Configuration,
   package discovery, default artifacts and sessions resolve through `.runtime`;
   project resources use `.generation`. User-scope discovery does not consult
   host-global npm or `~/.pi`. Bundled optional CLI profiles select `.runtime/bin`.
2. Foreground children have independent model registries. Explicit child provider
   registrations precede model resolution and override inherited parent providers
   without changing parent/sibling registrations. Model/thinking suffix handling
   remains native, including SDK capability clamping.
3. The host's four default builtins remain unchanged. Public native SDK factories
   supply explicitly selected `grep`, `find`, and `ls` as replaceable child-only
   extension tools; watchdog uses those same definitions, not invented substitutes.
4. Public reloads of an empty native resource loader replace upstream's private
   `loader.loaded` mutation. No extension factory is evaluated twice by that reset.
   This resets transformed module factories, **not Node's native ESM module map**.
5. Child cache retention maps the former shared Pi setting into both the
   Generation AI and harness namespaces without changing parent request options.
6. All 15 upstream public subpaths are exported alongside the root entry point.
   The manifest also packages every script/resource required by runtime paths.

## Eight review findings

Paths are package-relative; tests below execute under an isolated offline scope.

| Finding | Result | Source change and evidence |
|---|---|---|
| 1. Missing runtime/public surface | Restored source; full equivalence UNVERIFIED | Complete pinned runtime under `src/{api,agents,extension,runs,intercom,missions,profiles,policy,slash,tui,watchdog,workflows}`; all public exports in `package.json`. 87 adapted upstream unit suites plus native integrations exercise major mechanisms, not every upstream scenario. |
| 2. Parent/sibling provider mutation | PASS | `runs/shared/child-session.ts` retains isolated foreground runtime ownership and unclaimed-provider inheritance. Actual parallel child provider overrides and parent reuse: `test/native-parity.test.mjs`; upstream `child-session-parent-providers.test.ts`. |
| 3. Model resolution before child providers | PASS | Native provider registration/refresh occurs before `resolveCliModel`; facade no longer pre-rejects child-local providers. Both actual default native tool and SDK facade execute a child-only model without registering it in the parent. Thinking and parent registry checks included. |
| 4. Agent-relative extension paths | PASS for exercised paths | Native discovery retains definition provenance; `compat/agents/agents.ts` resolves relative extension/path-like-tool entries from the definition. Actual custom-tool execution for both forms in `native-parity.test.mjs`; pinned tool-plan/preflight suites retained. Full discovery configuration remains separately UNVERIFIED below. |
| 5. Independent module state | PASS for transformed fixture; BLOCKED for stronger native ESM independence | Actual enum-containing TypeScript fixture returns `1,1`; native `.mjs` returns `1,2`. Differential execution against the pinned original factory produces the same results on this host. See exact boundary below. |
| 6. Thinking overrides/precedence | PASS for tested precedence | Suffix and agent thinking retained through native model/session creation; persisted child JSONL verifies low/default vs explicit high. Pinned factory differential verifies high; model/thinking unit suites cover parsing and ceilings. |
| 7. Path-like tools | PASS | Pinned `child-tool-plan.ts` normalizes tool-extension entries; the facade delegates to that plan. Real selected custom-tool calls succeed from agent-relative paths. Missing tools/extensions still fail before inference with cleanup. |
| 8. Model-only exposure | PASS | Pinned native tool metadata and compatibility tool both use `exposure: "model-only"`; actual session registry inspection and upstream activation/schema tests verify the boundary. |

## Capability matrix

PASS means the named offline behavior is exercised and agrees with the pinned
implementation/source; it does not certify all external hosts or every omitted
suite. FAIL is reserved for demonstrated missing/different required functionality,
BLOCKED for a demonstrated constraint, and UNVERIFIED for insufficient evidence.
Upstream references are relative to the pinned checkout; corresponding adapted
source/test paths have the same layout unless explicitly noted.

| Capability | Pinned source | Existing implementation / behavioral evidence | Result and remaining verification |
|---|---|---|---|
| Agent discovery, precedence, configuration and builtins | `src/agents/`, `agents/` | Full discovery/frontmatter/builtins restored; `agent-selection`, runtime-agent-registration, preflight and actual project-agent execution tested. | UNVERIFIED for comprehensive discovery parity. Port full `agent-frontmatter`, `agent-discovery-cache`, agent management/override/scan-dir suites; verify packaged-resource discovery in a clean install. |
| Runtime agent registration and ownership | `src/api/agents.ts`, `agents/runtime-agent-*` | Upstream runtime registration, session ownership, collisions, model defaults, provider-tier overrides and shutdown tests retained. | PASS for tested runtime registration contracts. |
| Agent management, refinements, memory and private skills | `src/agents/{agent-management,agent-refinements,agent-memory,skills}.ts` | Source restored; refinement and management/model/list paths exercised by adapted suites. | UNVERIFIED for the entire management/memory/skills feature family. `agent-management`, `agent-memory`, comprehensive skills/package cases remain next targets. |
| Native extensions and actual custom-tool execution | `src/runs/shared/{child-session,child-tool-plan}.ts` | Native loader and standard child tool loop; explicit custom tools, definition-relative providers, path-like tools, strict selection and parent exclusion tested. Native SDK `ls` also executes as a child-only tool. | PASS for exercised native selection/loading/execution contracts, subject to ESM boundary. |
| Foreground/background extension discovery distinction | `child-session.ts`, `child-launch.ts`, `docs/agents.md` | Parent-bound launches disable ambient extensions; detached runner enables them when allowed. Native foreground and actual detached children load the explicitly declared provider and tools. | UNVERIFIED for complete ambient package/MCP discovery permutations. No new loader introduced. |
| Required extensions, permissions and capability ceilings | `src/api/{required-child-extensions,capability-ceiling}.ts`, shared permissions/tool plans | Required load/provider/startup failures, nested ceilings/agent allowlists and permission tool-plan suites retained; real startup error emits shutdown before inference. | PASS for tested fail-closed admission/propagation contracts. External permission-system host setup remains UNVERIFIED. |
| Foreground single and sequential chains | `src/runs/foreground/` | Existing Generation single/chain regressions retained; actual native default agent/provider/write execution; upstream `run-child-session`, control and model suites. | PASS for exercised execution, terminal-error and ordered isolation behavior. Exhaustive output/acceptance differential remains UNVERIFIED. |
| Parallel and concurrency behavior | `src/runs/shared/parallel-utils.ts`, `src/workflows/`, runner | Original foreground barrier/failure/cancellation tests retained; actual default `workflow:"parallel"` uses a two-child barrier and distinct outputs. Pinned differential checks semaphore/order/output formatting; workflow VM suites cover failed peers. | PASS for exercised concurrency, identity and peer-isolation mechanisms. |
| Detached execution independent of parent interaction | `src/runs/background/async-execution.ts`, native runner | Real Node runner, fixture provider, actual native write call. RPC returns while status is running; child finishes after parent disposal. Headless no-UI auto-drain semantics preserved. | PASS for the tested native Node host. |
| Status/discovery/await/cancel and peer isolation | background status/control/wait APIs | Actual restored parent invokes `status` and `bg_wait`; native stop cancels one detached process without failing its successful peer. Upstream wait/control/background-work suites retained. | PASS for tested management and wait/cancel contracts. |
| Parent process exit and durable recovery | native runner/bootstrap, async retention/recovery | Separate launching Node process exits while runner is active. A replacement parent opens the original session, discovers the run and observes completion/artifacts. Async resume/recovery descriptor unit suites retained. | PASS for launcher-exit recovery; UNVERIFIED for the full runner-crash/SIGKILL/retention reconciliation matrix. |
| Retained resume, interrupt and steering | background control/resume implementation | Upstream async-resume, subagent-control/wait, nested control and recovery suites retained. | UNVERIFIED for all real native-process retained-child transitions; add end-to-end interrupt/steer/resume/crash scenarios. |
| Nested delegation and recursion policy | `extension/fanout-child.ts`, child runtime/launch | Actual nester child invokes a permitted leaf through native subagent tooling; inherited deny-all agent list is enforced. Upstream nested-events/control/fanout/depth/ceilings suites retained. | PASS for exercised nesting and inherited restrictions. |
| Fresh/fork context and permitted inheritance | `shared/fork-context.ts`, pruned fork, child launch/hooks | Full pinned source; existing fresh isolation tests plus child launch/control/fork-related unit cases. | UNVERIFIED for full/pruned fork, global/project instruction and skills inheritance across native foreground/background/recovery. |
| Model/provider registry isolation | native child factory and provider inheritance | Actual sibling override/parent reuse tests, real child-local provider inference, upstream factory cases and pinned differential. | PASS for registry ownership/inheritance, not arbitrary mutable internals of provider objects (upstream intentionally inherits those providers). |
| Model/thinking/scope/profiles | model resolution/scope, profiles and thinking ceilings | Model-info/resolution/scope and agent registration suites; persisted actual thinking; pinned factory differential. | PASS for tested model/override/thinking mechanisms; UNVERIFIED for all provider-specific profiles/virtual models on real hosts. |
| Transformed module factory isolation | native child factory/cache boundary | Public empty-loader reload, actual TypeScript transform fixture and pinned differential both produce independent `1,1`. | PASS for exercised transformed extension behavior. |
| Native ESM module state independence | native child factory/host loader | `.mjs` fixture remains `1,2` after public reload, in both original and adapted implementations. | BLOCKED for stronger independence requirement under unchanged public Core/native-loader APIs. See below. |
| Scripted workflows/structured fanout/VM | `src/workflows/scripted-workflow.ts`, worker | Original VM/runtime validation suite retained; actual saved workflow awaits a native child; default parallel workflow tested; pinned differential runs the actual worker VM with stable keys/frozen inputs. | PASS for exercised script/VM/fanout mechanisms. |
| Workflow status/resume/claims/resources/gates | workflows and public resource/preflight APIs | Workflow graph, resume/claim, scripts-feature admission, preflight and related unit suites retained. | UNVERIFIED for every trusted-resource/gate/host-command/restart permutation. |
| Worktrees/ownership/cleanup | `src/runs/shared/worktree*.ts` | Real disposable git repositories, concurrent repository locks, workflow admission, retained unknown settlement and cleanup-plan tests retained. No project repository commits/mutations performed. | PASS for the exercised native git/worktree contracts on this Linux host. Other host/filesystem variants UNVERIFIED. |
| Supervisor/intercom | `src/intercom/`, public bridge/control APIs | Native supervisor request/reply/owner/stale-context and intercom bridge suites retained; nested real tool execution uses child runtime hooks. | PASS for tested local native channels/ownership; actual remote intercom transport UNVERIFIED. |
| Tool activation, exposure, management commands, RPC/delegation API | `src/extension/`, `src/slash/`, public APIs | Pinned activation, schemas, delegation, supervisor and command/RPC paths retained; actual default extension and standard parent tool loop tested. | PASS for exercised activation/exposure/admission; every slash command variant and third-party RPC client remains UNVERIFIED. |
| Fleet/inspectors/observability | `src/tui/`, inspectors, status/artifact modules | Real component render/input/update/steer/stop tests, fleet status/transcript/viewport, inspector registration and async status suites retained. Actual run JSONL/status/output artifacts persisted/recovered. | PASS for tested offline native fleet/artifact contracts; live terminal/remote inspectors UNVERIFIED. |
| Missions/durable schedules | `src/missions/`, scheduled runs/calendar/claims | Mission stores/projection/goal/lifecycle, concurrent state, calendar edge cases, schedule histories/claims/recovery and scheduled mission suites retained. | PASS for exercised local persistence/scheduling mechanisms; operational multi-host scheduling remains UNVERIFIED. |
| Watchdog/acceptance/structured output/budgets | `src/watchdog/`, shared runtime/contracts | Broad watchdog policy/review/runtime/render/LSP mock suites, structured output rejection/validation, capability/budget/control admission cases. Native search definitions restored through public SDK factories. | UNVERIFIED for entire advanced family. Real watchdog scheduling, provider retries and every acceptance/gate/budget interaction need further end-to-end/differential coverage. |
| External CLI/job providers and integrations | external runner/job/public APIs, `src/integrations/`, Herdr/Rex | Local fake executable processes exercise stdout/stderr, timeout/cancellation/descendant cleanup; external job providers tested with doubles. All native adapters restored, builtins resolve runtime-owned executables. | UNVERIFIED for real CLI authentication, remote machines/panes, provider services and non-Node/standalone hosts. Not authorized or represented as offline PASS. |
| Errors, startup cancellation, shutdown and recovery | child/native/background lifecycle | Strict missing tools/extensions, required startup errors, bounded upstream shutdown, failed peers, process cleanup and many upstream failure cases retained. | PASS for named tested cases; full crash/startup/retention failure matrix remains UNVERIFIED. |
| Public package exports and resource installation | `package.json`, runner scripts, agents/skills/prompts/docs | All native public subpaths and runtime files packaged; complete source typechecks/builds. | UNVERIFIED until a clean temporary package-install/resource/runner scenario is verified; import-only evidence is not functional parity. |

## Exact native ESM boundary

Core's public `DefaultResourceLoader` accepts paths and extension factories but has
no per-child native module identity/cache policy option. Its module loader creates
Jiti with `moduleCache:false`; native Node imports can still enter Node's permanent
ESM module map. Public `reload()` clears the extension factory cache, not that map.
No public Core API exposes a native ESM cache reset or a child-scoped loader realm.

The original review's `.mjs` reproduction assumed that clearing upstream's private
factory-cache flag also cleared native ESM state. The differential suite directly
executes the pinned original factory using the same local SDK and proves that it
does not: original and adapted factories both yield `1,2`. The transformed fixture
correctly yields `1,1` in both. We do not weaken the requirement, report false
independence, mutate Core/private flags, or invent another extension loader.

If stronger `.mjs` independence is mandatory, an owner decision/public Core loader
capability is needed. Full equivalence with Pi's own 1.2 SDK loader on every host is
also not proven by comparing both factories on Generation's 1.4 host.

## Test safety and actual evidence

- `test/offline-bootstrap.mjs` imports the existing harness network guard before SDK
  loading, creates temporary HOME/agent/runtime/session scopes, purges Pi variables,
  and passes the network guard to Node subprocesses. Credentials are explicit
  in-memory stores or explicitly scoped disposable fixture files, never host auth.
- Unit tests are adapted from the pin; namespace/path/SDK fixture changes retain
  assertions. No tests were deleted or weakened. Native integrations use faux
  providers, native tools and real local child processes; no live inference or
  external service is invoked.
- Expanded subagents package test suite (114 test files): **2,148 tests; 2,137 pass, 0 fail,
  11 skip** (all skips platform-gated: Windows `.cmd`/symlinks, Linux FIFO/process identity, or case-insensitive filesystem).
- Clean package install & execution test (`test/package-install.test.mjs`): **PASS**, verifying
  tarball packaging, all 16 export subpaths, skill and prompt discovery, workflow script worker,
  and detached child process execution from an isolated install.
- Pinned differential suite: **4 tests, 4 pass** (actual native factory with TS and
  MJS fixtures, concurrent scheduling/semaphore/output identity, workflow worker VM).
  It requires an explicitly selected external checkout and checks its exact SHA;
  it never downloads or installs the reference.
- Original harness regression suite: **46 tests, 46 pass**.
- Combined offline execution: **2,183 tests run (plus 4 differential); 2,183 pass, 0 fail, 11 skip**.
- Root full typecheck (`npm run typecheck`), build (`npm run build`), and test (`npm test`)
  all exit 0 cleanly with `GENERATION_HARNESS_OFFLINE=1`.
  No live-provider, remote-host or Windows validation is claimed.

## Next verification targets / acceptance status

1. Decide the native ESM independence boundary without changing Core or adding a
   loader. Keep the demonstrated boundary explicit; do not assert 100% parity.
2. Port/run the remaining agent-frontmatter/management/memory/skills, trusted
   workflow resources, full/pruned fork, retained native-process transitions,
   runner crash/retention and clean package-install suites.
3. Expand differential inputs across configuration/errors, resume/status,
   permissions/acceptance and durable recovery—not just the four current scenarios.
4. Validate remaining external integrations only with local doubles unless a
   separate host/provider authorization is given. Mark unavailable host scenarios
   UNVERIFIED, not PASS.
5. Audit final git scope: package/runtime/tests/manifests/lockfile only; Core source
   must remain byte-for-byte unchanged. No project commits or pushes.

This is a substantial native source migration with broad offline tests, not a
completed 100% verification certificate.
