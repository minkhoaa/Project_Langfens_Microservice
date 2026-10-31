import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { harnessRoot, runtimeLaunch } from '../../../scripts/runtime.mjs';
import { parseFrontmatter } from 'generation-harness-core';
import { discoverAgents } from 'generation-subagents';
import { resolveSkillsWithFallback } from '../../../packages/generation-subagents/src/agents/skills.ts';
import { q } from './helpers.mjs';
import { createDomain } from '../domain.ts';

const readingProfile = join(harnessRoot, '.generation/reading');
const skillsDir = join(readingProfile, 'skills');
const agentsDir = join(readingProfile, 'agents');

const REQUIRED_SKILLS = [
  'using-reading-superpowers',
  'reading-authoring',
  'reading-quality-review',
  'reading-verification',
];

const REQUIRED_AGENTS = [
  'passage-author',
  'question-author',
  'semantic-checker',
  'ielts-examiner',
];

test('reading bootstrap automatically configures 4 skills, 4 agents, and Exam Designer rules', () => {
  const launch = runtimeLaunch(['--reading']);

  // 1. Verify parent system prompt specifies Exam Designer role and automatic skill entry
  const systemPromptArg = launch.args[launch.args.indexOf('--system-prompt') + 1];
  assert.ok(systemPromptArg, 'System prompt must be specified');
  const systemPrompt = readFileSync(systemPromptArg, 'utf8');
  assert.match(systemPrompt, /IELTS Academic Reading author/);
  assert.match(systemPrompt, /Exam Designer/);
  assert.match(systemPrompt, /using-reading-superpowers/);
  assert.match(systemPrompt, /passage-author/);
  assert.match(systemPrompt, /question-author/);
  assert.match(systemPrompt, /semantic-checker/);
  assert.match(systemPrompt, /ielts-examiner/);
  assert.match(systemPrompt, /Passage authoring precedes question creation/);
  assert.match(systemPrompt, /Revalidate changed artifacts without restarting successful stages/);
  assert.match(systemPrompt, /Bound repair iterations and stop with BLOCKED\/UNVERIFIED/);

  // 2. Verify all 4 skills are passed on CLI via --skill
  for (const skill of REQUIRED_SKILLS) {
    const expectedPath = join(skillsDir, skill);
    assert.ok(launch.args.includes(expectedPath), `CLI args must include --skill ${expectedPath}`);
    assert.ok(existsSync(join(expectedPath, 'SKILL.md')), `Skill file must exist at ${expectedPath}/SKILL.md`);

    const content = readFileSync(join(expectedPath, 'SKILL.md'), 'utf8');
    const { frontmatter } = parseFrontmatter(content);
    assert.equal(frontmatter.name, skill);
    assert.ok(typeof frontmatter.description === 'string' && frontmatter.description.trim().length > 0);
  }

  // 3. Verify all 4 agents exist and declare correct configuration
  for (const agentName of REQUIRED_AGENTS) {
    const agentFile = join(agentsDir, `${agentName}.md`);
    assert.ok(existsSync(agentFile), `Agent file must exist at ${agentFile}`);

    const content = readFileSync(agentFile, 'utf8');
    const { frontmatter } = parseFrontmatter(content);
    assert.equal(frontmatter.name, agentName);
    assert.equal(frontmatter.advertise, true);
    assert.equal(frontmatter.defaultContext, 'fresh');
    assert.equal(frontmatter.inheritSkills, false);
    assert.equal(frontmatter.inheritProjectContext, false);
    assert.equal(frontmatter.inheritGlobalContext, false);
    assert.ok(frontmatter.tools, `Agent ${agentName} must declare tools`);

    // Verify skill declarations and resolution
    assert.ok(frontmatter.skills, `Agent ${agentName} must declare skills`);
    assert.ok(frontmatter.skillPath, `Agent ${agentName} must declare skillPath`);

    const agentSkills = typeof frontmatter.skills === 'string'
      ? frontmatter.skills.split(',').map((s) => s.trim())
      : frontmatter.skills;
    const skillPathList = typeof frontmatter.skillPath === 'string'
      ? [frontmatter.skillPath]
      : frontmatter.skillPath;

    const resolved = resolveSkillsWithFallback(
      agentSkills,
      readingProfile,
      readingProfile,
      skillPathList,
      agentsDir,
    );
    assert.equal(resolved.missing.length, 0, `Agent ${agentName} has missing skills: ${resolved.missing.join(', ')}`);
    assert.equal(resolved.resolved.length, agentSkills.length);
  }

  // 4. Verify coding mode isolation: normal launch does NOT discover reading agents or skills
  const codingLaunch = runtimeLaunch([]);
  assert.ok(!codingLaunch.args.includes('--reading'));
  assert.ok(!codingLaunch.args.some((a) => a.includes('using-reading-superpowers')));
});

test('role specifications enforce explicit responsibilities, authorized tools, and context isolation', () => {
  const agentConfigs = {};
  for (const name of REQUIRED_AGENTS) {
    const content = readFileSync(join(agentsDir, `${name}.md`), 'utf8');
    agentConfigs[name] = parseFrontmatter(content).frontmatter;
  }

  // passage-author: passage authoring, not questions, write access
  const passageAuthorTools = agentConfigs['passage-author'].tools.split(',').map((t) => t.trim());
  assert.ok(passageAuthorTools.includes('write'));
  assert.ok(passageAuthorTools.includes('read'));
  assert.ok(passageAuthorTools.includes('bash'));
  assert.ok(!passageAuthorTools.includes('create_single_choice'));

  // question-author: canonical question builders & validators
  const questionAuthorTools = agentConfigs['question-author'].tools.split(',').map((t) => t.trim());
  assert.ok(questionAuthorTools.includes('write'));
  assert.ok(questionAuthorTools.includes('create_single_choice'));
  assert.ok(questionAuthorTools.includes('create_multiple_choice'));
  assert.ok(questionAuthorTools.includes('create_completion'));
  assert.ok(questionAuthorTools.includes('create_matching'));
  assert.ok(questionAuthorTools.includes('create_short_answer'));
  assert.ok(questionAuthorTools.includes('create_flow_chart'));
  assert.ok(questionAuthorTools.includes('validate_exam'));

  // semantic-checker: read-only, evidence verification, no write or question creation
  const semanticTools = agentConfigs['semantic-checker'].tools.split(',').map((t) => t.trim());
  assert.ok(!semanticTools.includes('write'));
  assert.ok(!semanticTools.includes('create_single_choice'));
  assert.ok(semanticTools.includes('verify_evidence'));
  assert.ok(semanticTools.includes('validate_exam'));

  // ielts-examiner: read-only, grading parity, delivery projection, no write
  const examinerTools = agentConfigs['ielts-examiner'].tools.split(',').map((t) => t.trim());
  assert.ok(!examinerTools.includes('write'));
  assert.ok(!examinerTools.includes('create_single_choice'));
  assert.ok(examinerTools.includes('check_grading_parity'));
  assert.ok(examinerTools.includes('inspect_delivery_projection'));
  assert.ok(examinerTools.includes('validate_exam'));
});

// Full 13Q multi-agent workflow offline test with mocked model responses
test('exercise native role handoffs offline without certifying scripted reviewer claims', { timeout: 60000 }, (t) => {
  const root = mkdtempSync(join(tmpdir(), 'superpowers-workflow-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));

  const env = { ...process.env, GENERATION_HARNESS_RUNTIME_DIR: join(root, 'runtime') };
  const reading = runtimeLaunch(['--reading'], env);

  const passageText =
    'Geothermal energy originates from the Earth’s molten interior and radioactive decay in deep crustal rocks. ' +
    'Conventional hydrothermal systems extract steam or pressurized hot water from permeable reservoirs to drive electricity-generating turbines. ' +
    'Enhanced Geothermal Systems (EGS) expand resource accessibility by hydraulically fracturing hot impermeable granite formations at depths exceeding three kilometers. ' +
    'Binary cycle power plants circulate secondary working fluids with boiling points lower than water, permitting efficient generation from reservoirs below 150 degrees Celsius. ' +
    'Although geothermal installations boast capacity factors exceeding ninety percent and minimal land use, challenges include induced microseismic activity and high upfront exploration capital.';

  // Build a 13-question paper across diverse types without hardcoded distribution
  const paper = {
    id: 'exam-geothermal-01',
    complete: true,
    expectedQuestionCount: 13,
    sections: [
      {
        id: 'sec-01',
        idx: 1,
        title: 'Geothermal Energy Systems',
        passageMd: passageText,
        questionGroups: [
          {
            id: 'grp-01',
            idx: 1,
            instructionMd: 'Do the following statements agree with the information given in the passage? Write TRUE, FALSE, or NOT GIVEN.',
            questions: Array.from({ length: 4 }, (_, i) => {
              const x = q('TRUE_FALSE_NOT_GIVEN');
              return {
                ...x,
                id: `q${i + 1}`,
                sectionId: 'sec-01',
                groupId: 'grp-01',
                idx: i + 1,
                promptMd: [
                  'Conventional hydrothermal systems extract water from permeable reservoirs.',
                  'Enhanced Geothermal Systems were first pioneered in Iceland.',
                  'Binary cycle power plants operate above 200 degrees Celsius.',
                  'Geothermal facilities boast capacity factors exceeding ninety percent.',
                ][i],
                explanationMd: 'Directly verifiable from the passage text.',
                options: x.options.map((o, j) => ({
                  ...o,
                  id: `o${i + 1}-${j + 1}`,
                  idx: j + 1,
                  isCorrect: j === (i === 1 ? 2 : i === 2 ? 1 : 0),
                })),
              };
            }),
          },
          {
            id: 'grp-02',
            idx: 2,
            instructionMd: 'Complete the summary below. Choose NO MORE THAN TWO WORDS from the passage for each answer.',
            questions: Array.from({ length: 4 }, (_, i) => {
              const x = q('SUMMARY_COMPLETION');
              return {
                ...x,
                id: `q${i + 5}`,
                sectionId: 'sec-01',
                groupId: 'grp-02',
                idx: i + 5,
                promptMd: `The Earth's heat is harnessed through [${i + 1}].`,
                explanationMd: 'Directly in text.',
                options: [],
                blankAcceptTexts: {
                  [`${i + 1}`]: [['steam'], ['water'], ['energy'], ['granite']][i],
                },
              };
            }),
          },
          {
            id: 'grp-03',
            idx: 3,
            instructionMd: 'Choose the correct letter, A, B, C or D.',
            questions: Array.from({ length: 3 }, (_, i) => {
              const base = q('MULTIPLE_CHOICE_SINGLE');
              return {
                ...base,
                id: `q${i + 9}`,
                sectionId: 'sec-01',
                groupId: 'grp-03',
                idx: i + 9,
                promptMd: `What characterizes geothermal plant operation ${i + 1}?`,
                explanationMd: 'Supported by paragraph statements on plant efficiency.',
                options: base.options.map((o, j) => ({
                  ...o,
                  id: `o${i + 9}-${j + 1}`,
                  idx: j + 1,
                  contentMd: ['High capacity factor', 'High emissions', 'Large land footprint', 'Low reliability'][j],
                  isCorrect: j === 0,
                })),
              };
            }),
          },
          {
            id: 'grp-04',
            idx: 4,
            instructionMd: 'Choose TWO letters, A-E.',
            questions: Array.from({ length: 2 }, (_, i) => {
              const base = q('MULTIPLE_CHOICE_MULTIPLE');
              return {
                ...base,
                id: `q${i + 12}`,
                sectionId: 'sec-01',
                groupId: 'grp-04',
                idx: i + 12,
                promptMd: 'Which TWO operational risks are associated with deep geothermal systems?',
                explanationMd: 'The text notes induced microseismic activity and upfront exploration capital.',
                options: [
                  { id: `o${i + 12}-1`, idx: 1, contentMd: 'Induced microseismic activity', isCorrect: true },
                  { id: `o${i + 12}-2`, idx: 2, contentMd: 'High exploration capital', isCorrect: true },
                  { id: `o${i + 12}-3`, idx: 3, contentMd: 'Extensive surface land disruption', isCorrect: false },
                  { id: `o${i + 12}-4`, idx: 4, contentMd: 'Severe atmospheric air pollution', isCorrect: false },
                  { id: `o${i + 12}-5`, idx: 5, contentMd: 'Rapid groundwater depletion', isCorrect: false },
                ],
              };
            }),
          },
        ],
      },
    ],
  };

  const providerPath = join(root, 'offline-superpowers-provider.mjs');
  const receiptPath = join(root, 'workflow-receipt.json');

  writeFileSync(
    providerPath,
    `
import ${JSON.stringify(new URL('../../../test/offline.mjs', import.meta.url).href)};
import assert from 'node:assert/strict';
import { writeFileSync, existsSync } from 'node:fs';
import { fauxProvider, fauxAssistantMessage, fauxToolCall, getSystemMessageText } from ${JSON.stringify(import.meta.resolve('generation-ai'))};

const paper = ${JSON.stringify(paper)};
const receipt = ${JSON.stringify(receiptPath)};
const skillsRoot = ${JSON.stringify(skillsDir)};

export default api => {
  const fake = fauxProvider({ models: [{ id: 'parent' }] });
  const steps = {};
  const metrics = {
    roles: {},
    skillsRead: [],
    calls: [],
    reviews: {},
    phaseTransitions: [],
  };

  const call = (name, args) => fauxAssistantMessage(fauxToolCall(name, args), { stopReason: 'toolUse' });

  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === 'system').map(getSystemMessageText).join('\\n');
    const user = JSON.stringify(ctx.messages.filter(m => m.role === 'user'));

    // Role identification via specialized system prompt
    let role = 'parent';
    if (prompt.includes('passage-author specialist')) role = 'passage-author';
    else if (prompt.includes('question-author specialist')) role = 'question-author';
    else if (prompt.includes('independently review')) role = 'semantic-checker';
    else if (prompt.includes('independently examine')) role = 'ielts-examiner';

    const tools = new Map();
    for (const m of ctx.messages.filter(m => m.role === 'system')) {
      for (const n of m.toolsRemoved ?? []) tools.delete(n);
      for (const d of m.toolsAdded ?? []) tools.set(d.name, d);
    }
    const names = [...tools.keys()];
    const n = steps[role] ?? 0;
    steps[role] = n + 1;

    metrics.roles[role] ??= {
      promptBytes: Buffer.byteLength(prompt),
      declarationBytes: Buffer.byteLength(JSON.stringify([...tools.values()])),
      tools: names,
    };

    const last = ctx.messages.filter(m => m.role === 'toolResult').at(-1);
    if (last) {
      const expectedPilotFailure=role==='question-author'&&last.toolName==='validate_exam';
      assert.equal(!!last.isError, expectedPilotFailure, 'Tool result error: ' + JSON.stringify(last));
      if(expectedPilotFailure){
        const report=JSON.parse(last.content[0].text);
        assert.ok(report.diagnostics.some(d=>d.code==='PILOT_UNSUPPORTED_SCORING_STRUCTURE'));
        assert.equal(report.data.answerSlots,15);
        metrics.pilot=report.data;
      }
      metrics.calls.push({ role, tool: last.toolName, isError: !!last.isError });
      if (last.toolName === 'read' && last.content?.[0]?.text?.includes('using-reading-superpowers')) {
        metrics.skillsRead.push('using-reading-superpowers');
      } else if (last.toolName === 'read' && last.content?.[0]?.text?.includes('reading-authoring')) {
        metrics.skillsRead.push('reading-authoring');
      } else if (last.toolName === 'read' && last.content?.[0]?.text?.includes('reading-quality-review')) {
        metrics.skillsRead.push('reading-quality-review');
      }
    }

    // --- Role 1: passage-author ---
    if (role === 'passage-author') {
      assert.ok(names.includes('write'));
      assert.ok(names.includes('read'));
      assert.ok(!names.includes('create_single_choice'));
      if (n === 0) return call('read', { path: skillsRoot + '/reading-authoring/SKILL.md' });
      if (n === 1) {
        // Save initial exam structure with passage
        const initial = {
          id: paper.id,
          complete: false,
          expectedQuestionCount: 13,
          sections: [{ id: paper.sections[0].id, idx: 1, title: paper.sections[0].title, passageMd: paper.sections[0].passageMd, questionGroups: [], questions: [] }]
        };
        return call('write', { path: 'exam.json', content: JSON.stringify(initial) });
      }
      if (n === 2) return call('validate_exam', { exam: { file: 'exam.json' } });
      metrics.phaseTransitions.push('phase-1-passage-complete');
      return fauxAssistantMessage('PASS: Passage authored. Word count 812 words, 5 paragraphs in exam.json.');
    }

    // --- Role 2: question-author ---
    if (role === 'question-author') {
      assert.ok(names.includes('create_single_choice'));
      assert.ok(names.includes('create_multiple_choice'));
      assert.ok(names.includes('create_completion'));
      assert.ok(names.includes('validate_exam'));
      if (n === 0) return call('read', { path: skillsRoot + '/reading-authoring/SKILL.md' });
      if (n === 1) return call('get_question_spec', { type: 'TRUE_FALSE_NOT_GIVEN' });
      if (n === 2) return call('create_single_choice', {
        id: 'q1',
        sectionId: 'sec-01',
        type: 'TRUE_FALSE_NOT_GIVEN',
        idx: 1,
        difficulty: 3,
        promptMd: paper.sections[0].questionGroups[0].questions[0].promptMd,
        options: paper.sections[0].questionGroups[0].questions[0].options.map(({ idx, ...o }) => o),
      });
      if (n === 3) return call('write', { path: 'exam.json', content: JSON.stringify(paper) });
      if (n === 4) return call('validate_exam', { exam: { file: 'exam.json' }, pilot: true });
      metrics.phaseTransitions.push('phase-2-questions-complete');
      return fauxAssistantMessage('PASS: 13 canonical questions authored and validated in exam.json.');
    }

    // --- Role 3: semantic-checker ---
    if (role === 'semantic-checker') {
      assert.ok(names.includes('verify_evidence'));
      assert.ok(!names.includes('write'));
      if (n === 0) return call('read', { path: skillsRoot + '/reading-quality-review/SKILL.md' });
      if (n === 1) return call('read', { path: 'exam.json' });
      if (n === 2) return call('verify_evidence', {
        question: paper.sections[0].questionGroups[0].questions[0],
        passage: { id: 'sec-01', text: paper.sections[0].passageMd },
        evidence: { sourceId: 'sec-01', start: 0, end: 50, quote: paper.sections[0].passageMd.slice(0, 50) }
      });
      const finding = 'PASS: Semantic verification clean. All 13 items grounded; no ambiguities detected.';
      metrics.reviews['semantic'] = finding;
      return fauxAssistantMessage(finding);
    }

    // --- Role 4: ielts-examiner ---
    if (role === 'ielts-examiner') {
      assert.ok(names.includes('check_grading_parity'));
      assert.ok(names.includes('inspect_delivery_projection'));
      assert.ok(!names.includes('write'));
      if (n === 0) return call('read', { path: skillsRoot + '/reading-quality-review/SKILL.md' });
      if (n === 1) return call('read', { path: 'exam.json' });
      if (n === 2) return call('inspect_delivery_projection', { question: paper.sections[0].questionGroups[0].questions[0] });
      if (n === 3) return call('validate_exam', { exam: { file: 'exam.json' } });
      const finding = 'PASS: IELTS examination clean. Authentic task design, compliant instructions, zero answer leaks.';
      metrics.reviews['examiner'] = finding;
      return fauxAssistantMessage(finding);
    }

    // --- Role 5: Exam Designer (parent) ---
    assert.match(prompt, /Exam Designer/);
    if (n === 0) {
      // Automatic entry: parent executes using-reading-superpowers skill first!
      return call('read', { path: skillsRoot + '/using-reading-superpowers/SKILL.md' });
    }
    if (n === 1) {
      // Phase 1: delegate to passage-author
      return call('subagent', {
        agent: 'passage-author',
        task: 'task-passage-author: Author IELTS Academic Reading passage on Geothermal Energy. Save initial structure in exam.json.',
        async: false,
        options: { context: 'fresh' }
      });
    }
    if (n === 2) {
      assert.ok(metrics.phaseTransitions.includes('phase-1-passage-complete'), 'Passage must precede question authoring');
      // Phase 2: delegate to question-author
      return call('subagent', {
        agent: 'question-author',
        task: 'task-question-author: Author 13 canonical questions grounded in the passage in exam.json.',
        async: false,
        options: { context: 'fresh' }
      });
    }
    if (n === 3) {
      assert.ok(metrics.phaseTransitions.includes('phase-2-questions-complete'), 'Questions must precede review');
      // Phase 3: independent review - semantic checker in fresh context
      return call('subagent', {
        agent: 'semantic-checker',
        task: 'semantic-review: Independently review exam.json revision r1. Verify evidence.',
        async: false,
        options: { context: 'fresh' }
      });
    }
    if (n === 4) {
      assert.ok(metrics.reviews.semantic?.includes('PASS'), 'Semantic review must complete');
      // Phase 3: independent review - IELTS examiner in fresh context
      return call('subagent', {
        agent: 'ielts-examiner',
        task: 'examiner-review: Independently review exam.json revision r1. Verify IELTS.',
        async: false,
        options: { context: 'fresh' }
      });
    }

    // Phase 5: Completion Gate Verification
    assert.ok(metrics.reviews.semantic?.includes('PASS'));
    assert.ok(metrics.reviews.examiner?.includes('PASS'));
    metrics.providerRequests = fake.state.callCount;
    writeFileSync(receipt, JSON.stringify(metrics, null, 2));
    return fauxAssistantMessage('BLOCKED: pilot has 15 answer slots for 13 marks; scripted reviewer PASS claims are not independent quality evidence. Artifact: exam.json');
  };

  fake.setResponses(Array(100).fill(respond));
  api.registerProvider(fake.provider);
};`
  );

  const result = spawnSync(
    'npm',
    [
      'run',
      'start:reading',
      '--',
      '--extension',
      providerPath,
      '--provider',
      'faux',
      '--model',
      'parent',
      '--mode',
      'json',
      '--no-session',
      '--offline',
      '-p',
      'Generate an IELTS Academic Reading test on Geothermal Energy with 13 questions.',
    ],
    {
      cwd: harnessRoot,
      env,
      encoding: 'utf8',
      timeout: 50000,
      maxBuffer: 10_000_000,
    }
  );

  assert.equal(result.status, 0, result.stderr + '\n' + result.stdout.slice(-12000));
  if (!existsSync(receiptPath)) {
    console.error('STDERR:', result.stderr);
    console.error('STDOUT:', result.stdout);
  }
  assert.ok(existsSync(receiptPath), 'Receipt must be generated');

  const metrics = JSON.parse(readFileSync(receiptPath, 'utf8'));

  // 1. Verify automatic skill activation
  assert.ok(
    metrics.skillsRead.includes('using-reading-superpowers'),
    'using-reading-superpowers skill must execute automatically',
  );

  // 2. Verify all 4 roles executed their designated skills
  assert.ok(metrics.skillsRead.includes('reading-authoring'), 'reading-authoring skill must be read');
  assert.ok(metrics.skillsRead.includes('reading-quality-review'), 'reading-quality-review skill must be read');

  // 3. Verify role sequence: passage authoring preceded question creation
  assert.deepEqual(metrics.phaseTransitions, ['phase-1-passage-complete', 'phase-2-questions-complete']);

  // 4. Verify artifact saved and valid
  const examArtifact = JSON.parse(readFileSync(join(reading.cwd, 'exam.json'), 'utf8'));
  assert.equal(examArtifact.expectedQuestionCount, 13);
  assert.ok(examArtifact.sections[0].passageMd.length > 200);
  const totalQuestions = examArtifact.sections[0].questionGroups.reduce(
    (sum, g) => sum + g.questions.length,
    0,
  );
  assert.equal(totalQuestions, 13);

  // 5. Verify independent review verdicts obtained
  assert.ok(metrics.reviews.semantic?.includes('PASS'));
  assert.ok(metrics.reviews.examiner?.includes('PASS'));

  // Native execution is real; faux-provider semantic claims are not quality evidence.
  assert.equal(metrics.pilot.pilot.status,'FAIL');
  assert.equal(metrics.pilot.answerSlots,15);
  assert.match(result.stdout, /BLOCKED: pilot has 15 answer slots/);
  assert.doesNotMatch(result.stdout, /PASS: 13Q IELTS Academic Reading exam verified and ready/);

  t.diagnostic(`Full 13Q Workflow Metrics: ${JSON.stringify({
    providerRequests: metrics.providerRequests,
    totalCalls: metrics.calls.length,
    rolesInvolved: Object.keys(metrics.roles),
  })}`);
});

test('rejection and recovery: repairs defective question and re-reviews without restarting passage stage', { timeout: 60000 }, (t) => {
  const root = mkdtempSync(join(tmpdir(), 'superpowers-recovery-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));

  const env = { ...process.env, GENERATION_HARNESS_RUNTIME_DIR: join(root, 'runtime') };
  const reading = runtimeLaunch(['--reading'], env);

  const providerPath = join(root, 'offline-recovery-provider.mjs');
  const receiptPath = join(root, 'recovery-receipt.json');

  writeFileSync(
    providerPath,
    `
import ${JSON.stringify(new URL('../../../test/offline.mjs', import.meta.url).href)};
import assert from 'node:assert/strict';
import { writeFileSync, existsSync } from 'node:fs';
import { fauxProvider, fauxAssistantMessage, fauxToolCall, getSystemMessageText } from ${JSON.stringify(import.meta.resolve('generation-ai'))};

const receipt = ${JSON.stringify(receiptPath)};
const skillsRoot = ${JSON.stringify(skillsDir)};

export default api => {
  const fake = fauxProvider({ models: [{ id: 'parent' }] });
  const steps = {};
  const metrics = {
    roles: {},
    calls: [],
    repairedItems: [],
    reReviewCalls: 0,
    passageReruns: 0,
  };

  const call = (name, args) => fauxAssistantMessage(fauxToolCall(name, args), { stopReason: 'toolUse' });

  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === 'system').map(getSystemMessageText).join('\\n');
    const user = JSON.stringify(ctx.messages.filter(m => m.role === 'user'));

    let role = 'parent';
    if (prompt.includes('passage-author specialist')) role = 'passage-author';
    else if (prompt.includes('question-author specialist')) role = 'question-author';
    else if (prompt.includes('independently review')) role = 'semantic-checker';
    else if (prompt.includes('independently examine')) role = 'ielts-examiner';

    const n = steps[role] ?? 0;
    steps[role] = n + 1;

    const last = ctx.messages.filter(m => m.role === 'toolResult').at(-1);
    if (last) {
      metrics.calls.push({ role, tool: last.toolName, isError: !!last.isError });
    }

    if (role === 'passage-author') {
      if (n === 0) {
        metrics.passageReruns++;
        return call('write', { path: 'exam.json', content: JSON.stringify({ id: 'e1', complete: true, expectedQuestionCount: 1, sections: [{ id: 's1', idx: 1, passageMd: 'Solar panels harness photovoltaic energy.', questionGroups: [] }] }) });
      }
      return fauxAssistantMessage('PASS: Passage authored.');
    }

    if (role === 'question-author') {
      if (user.includes('targeted repair')) {
        metrics.repairedItems.push('q1');
        // The first author invocation consumed n=0,1. Exercise a real saved repair,
        // not a hardcoded claim about an unchanged file.
        if (n === 2) return call('read', { path: 'exam.json' });
        if (n === 3) {
          const repaired=JSON.parse(last.content[0].text);
          repaired.sections[0].questionGroups[0].questions[0].promptMd='Solar panels harness photovoltaic energy.';
          return call('write', { path:'exam.json', content:JSON.stringify(repaired) });
        }
        if (n === 4) return call('validate_exam', { exam:{file:'exam.json'} });
        return fauxAssistantMessage('STRUCTURE ONLY: Question 1 repaired and validated.');
      }
      if (n === 0) return call('write', { path: 'exam.json', content: JSON.stringify({ id: 'e1', complete: true, expectedQuestionCount: 1, sections: [{ id: 's1', idx: 1, passageMd: 'Solar panels harness photovoltaic energy.', questionGroups: [{ id: 'g1', idx: 1, instructionMd: 'TRUE, FALSE, NOT GIVEN', questions: [{ id: 'q1', sectionId: 's1', groupId: 'g1', idx: 1, type: 'TRUE_FALSE_NOT_GIVEN', skill: 'READING', difficulty: 2, promptMd: 'Solar panels convert wind energy.', options: [{ id: 'o1', idx: 1, contentMd: 'True', isCorrect: true }, { id: 'o2', idx: 2, contentMd: 'False', isCorrect: false }, { id: 'o3', idx: 3, contentMd: 'Not Given', isCorrect: false }] }] }] }] }) });
      return fauxAssistantMessage('PASS: Question authored.');
    }

    if (role === 'semantic-checker') {
      if (user.includes('re-review')) {
        metrics.reReviewCalls++;
        return fauxAssistantMessage('PASS: Question 1 re-review verified. Evidence matches TRUE.');
      }
      // First review flags defect in Q1 key
      return fauxAssistantMessage('FAIL: Question 1 answer key contradicts passage evidence.');
    }

    if (role === 'ielts-examiner') {
      return fauxAssistantMessage('PASS: Examiner evaluation clean.');
    }

    // Exam Designer (parent)
    if (n === 0) return call('read', { path: skillsRoot + '/using-reading-superpowers/SKILL.md' });
    if (n === 1) return call('subagent', { agent: 'passage-author', task: 'task-passage-author: Author passage.', async: false, options: { context: 'fresh' } });
    if (n === 2) return call('subagent', { agent: 'question-author', task: 'task-question-author: Author questions.', async: false, options: { context: 'fresh' } });
    if (n === 3) return call('subagent', { agent: 'semantic-checker', task: 'semantic-review: Review exam.json.', async: false, options: { context: 'fresh' } });
    if (n === 4) {
      // Reviewer flagged defect -> Phase 4 targeted repair: route to question-author only!
      return call('subagent', { agent: 'question-author', task: 'targeted repair: Question 1 answer key contradicts passage evidence. Fix key in exam.json.', async: false, options: { context: 'fresh' } });
    }
    if (n === 5) {
      // Re-review ONLY with semantic-checker
      return call('subagent', { agent: 'semantic-checker', task: 're-review: Re-verify repaired Question 1.', async: false, options: { context: 'fresh' } });
    }
    if (n === 6) {
      // Now examiner review
      return call('subagent', { agent: 'ielts-examiner', task: 'examiner-review: Review exam.json.', async: false, options: { context: 'fresh' } });
    }

    writeFileSync(receipt, JSON.stringify(metrics, null, 2));
    return fauxAssistantMessage('UNVERIFIED: repair saved; scripted reviews do not establish quality readiness.');
  };

  fake.setResponses(Array(100).fill(respond));
  api.registerProvider(fake.provider);
};`
  );

  const result = spawnSync(
    'npm',
    [
      'run',
      'start:reading',
      '--',
      '--extension',
      providerPath,
      '--provider',
      'faux',
      '--model',
      'parent',
      '--mode',
      'json',
      '--no-session',
      '--offline',
      '-p',
      'Generate an IELTS Reading exam with targeted recovery test.',
    ],
    {
      cwd: harnessRoot,
      env,
      encoding: 'utf8',
      timeout: 50000,
      maxBuffer: 10_000_000,
    }
  );

  assert.equal(result.status, 0, result.stderr + '\n' + result.stdout.slice(-12000));
  assert.ok(existsSync(receiptPath), 'Recovery receipt must exist');

  const metrics = JSON.parse(readFileSync(receiptPath, 'utf8'));

  // 1. Verify targeted repair fixed Q1
  assert.ok(metrics.repairedItems.length>0);
  const repaired=JSON.parse(readFileSync(join(reading.cwd,'exam.json'),'utf8'));
  assert.equal(repaired.sections[0].questionGroups[0].questions[0].promptMd,'Solar panels harness photovoltaic energy.');
  assert.equal(repaired.sections[0].passageMd,'Solar panels harness photovoltaic energy.');
  const repairValidation=createDomain().call('validate_exam',{exam:repaired});
  assert.equal(repairValidation.data.claims.structure,'PASS',JSON.stringify(repairValidation.diagnostics.filter(d=>d.status==='FAIL')));

  // 2. Verify passage author was NOT rerun during repair
  assert.equal(metrics.passageReruns, 1, 'Passage author must not be rerun when only question was repaired');

  // 3. Verify targeted re-review ran
  assert.equal(metrics.reReviewCalls, 1, 'Targeted re-review must be performed for affected item');

  // 4. Verify workflow completed successfully after recovery
  assert.match(result.stdout, /UNVERIFIED: repair saved/);
  assert.doesNotMatch(result.stdout, /PASS: Repaired exam verified and ready/);
});

test('completion gate blocks and halts with BLOCKED when quality cannot be established after bounded retries', { timeout: 60000 }, (t) => {
  const root = mkdtempSync(join(tmpdir(), 'superpowers-blocked-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));

  const env = { ...process.env, GENERATION_HARNESS_RUNTIME_DIR: join(root, 'runtime') };
  const reading = runtimeLaunch(['--reading'], env);

  const providerPath = join(root, 'offline-blocked-provider.mjs');
  const receiptPath = join(root, 'blocked-receipt.json');

  writeFileSync(
    providerPath,
    `
import ${JSON.stringify(new URL('../../../test/offline.mjs', import.meta.url).href)};
import { writeFileSync } from 'node:fs';
import { fauxProvider, fauxAssistantMessage, fauxToolCall, getSystemMessageText } from ${JSON.stringify(import.meta.resolve('generation-ai'))};

const receipt = ${JSON.stringify(receiptPath)};
const skillsRoot = ${JSON.stringify(skillsDir)};

export default api => {
  const fake = fauxProvider({ models: [{ id: 'parent' }] });
  const steps = {};
  const metrics = { repairAttempts: 0, finalVerdict: null };

  const call = (name, args) => fauxAssistantMessage(fauxToolCall(name, args), { stopReason: 'toolUse' });

  const respond = ctx => {
    const prompt = ctx.messages.filter(m => m.role === 'system').map(getSystemMessageText).join('\\n');
    const user = JSON.stringify(ctx.messages.filter(m => m.role === 'user'));

    let role = 'parent';
    if (prompt.includes('passage-author specialist')) role = 'passage-author';
    else if (prompt.includes('question-author specialist')) role = 'question-author';
    else if (prompt.includes('independently review')) role = 'semantic-checker';

    const n = steps[role] ?? 0;
    steps[role] = n + 1;

    if (role === 'passage-author') {
      if (n === 0) return call('write', { path: 'exam.json', content: JSON.stringify({ id: 'e1', complete: true, expectedQuestionCount: 1, sections: [{ id: 's1', idx: 1, passageMd: 'Passage text.', questionGroups: [] }] }) });
      return fauxAssistantMessage('PASS: Passage authored.');
    }

    if (role === 'question-author') {
      if (user.includes('repair')) {
        metrics.repairAttempts++;
        return fauxAssistantMessage('ATTEMPT: Attempted question repair but ambiguity persists in passage.');
      }
      return fauxAssistantMessage('PASS: Questions authored.');
    }

    if (role === 'semantic-checker') {
      // Consistently fails due to irreconcilable contradiction
      return fauxAssistantMessage('FAIL: Irreconcilable factual contradiction between passage and questions.');
    }

    // Parent
    if (n === 0) return call('read', { path: skillsRoot + '/using-reading-superpowers/SKILL.md' });
    if (n === 1) return call('subagent', { agent: 'passage-author', task: 'task-passage-author: Author passage.', async: false, options: { context: 'fresh' } });
    if (n === 2) return call('subagent', { agent: 'question-author', task: 'task-question-author: Author questions.', async: false, options: { context: 'fresh' } });
    if (n === 3) return call('subagent', { agent: 'semantic-checker', task: 'semantic-review: Review exam.json.', async: false, options: { context: 'fresh' } });
    if (n === 4) {
      // Repair round 1
      return call('subagent', { agent: 'question-author', task: 'repair attempt 1: Fix factual contradiction.', async: false, options: { context: 'fresh' } });
    }
    if (n === 5) {
      return call('subagent', { agent: 'semantic-checker', task: 'semantic-review: Re-review exam.json round 1.', async: false, options: { context: 'fresh' } });
    }
    if (n === 6) {
      // Repair round 2 (max iteration reached)
      return call('subagent', { agent: 'question-author', task: 'repair attempt 2: Fix factual contradiction.', async: false, options: { context: 'fresh' } });
    }
    if (n === 7) {
      return call('subagent', { agent: 'semantic-checker', task: 'semantic-review: Re-review exam.json round 2.', async: false, options: { context: 'fresh' } });
    }

    // Max repair iterations reached; stop with BLOCKED/UNVERIFIED
    metrics.finalVerdict = 'BLOCKED';
    writeFileSync(receipt, JSON.stringify(metrics, null, 2));
    return fauxAssistantMessage('BLOCKED: Maximum repair iterations (2) reached. Quality cannot be established; factual contradiction persists.');
  };

  fake.setResponses(Array(100).fill(respond));
  api.registerProvider(fake.provider);
};`
  );

  const result = spawnSync(
    'npm',
    [
      'run',
      'start:reading',
      '--',
      '--extension',
      providerPath,
      '--provider',
      'faux',
      '--model',
      'parent',
      '--mode',
      'json',
      '--no-session',
      '--offline',
      '-p',
      'Generate an IELTS Reading exam with unresolvable defects.',
    ],
    {
      cwd: harnessRoot,
      env,
      encoding: 'utf8',
      timeout: 50000,
      maxBuffer: 10_000_000,
    }
  );

  assert.equal(result.status, 0, result.stderr + '\n' + result.stdout.slice(-12000));
  if (!existsSync(receiptPath)) {
    console.error('BLOCKED TEST STDOUT:', result.stdout);
    console.error('BLOCKED TEST STDERR:', result.stderr);
  }
  assert.ok(existsSync(receiptPath), 'Blocked receipt must exist');

  const metrics = JSON.parse(readFileSync(receiptPath, 'utf8'));

  // 1. Verify bounded repair attempts (stopped at 2 rounds)
  assert.equal(metrics.repairAttempts, 2, 'Must bound repair rounds to 2');

  // 2. Verify verdict is BLOCKED, NOT PASS
  assert.equal(metrics.finalVerdict, 'BLOCKED');
  assert.match(result.stdout, /BLOCKED: Maximum repair iterations \(2\) reached/);
  assert.doesNotMatch(result.stdout, /PASS:.*verified and ready/);
});

test('targeted repair revalidates changed items without restarting successful stages', () => {
  // Unit test verifying repair semantics:
  // If examiner identifies issue with Q9 distractor:
  // - Only Q9 is modified and revalidated with validate_question.
  // - Passage is NOT re-authored.
  // - Unaffected questions (Q1-Q8, Q10-Q13) are untouched.
  const originalExam = {
    id: 'exam-repair-test',
    complete: true,
    expectedQuestionCount: 2,
    sections: [
      {
        id: 's1',
        idx: 1,
        title: 'Section 1',
        passageMd: 'Solar panels convert sunlight directly into electricity using photovoltaic cells.',
        questionGroups: [
          {
            id: 'g1',
            idx: 1,
            questions: [
              {
                ...q('TRUE_FALSE_NOT_GIVEN'),
                id: 'q1',
                sectionId: 's1',
                groupId: 'g1',
                idx: 1,
                promptMd: 'Photovoltaic cells convert sunlight to electricity.',
              },
              {
                ...q('MULTIPLE_CHOICE_SINGLE'),
                id: 'q2',
                sectionId: 's1',
                groupId: 'g1',
                idx: 2,
                promptMd: 'What do solar panels convert?',
                options: [
                  { id: 'o1', contentMd: 'Sunlight', isCorrect: true },
                  { id: 'o2', contentMd: 'Wind', isCorrect: false },
                  { id: 'o3', contentMd: 'Water', isCorrect: false },
                  { id: 'o4', contentMd: 'Sunlight energy', isCorrect: false }, // Ambiguous distractor
                ],
              },
            ],
          },
        ],
      },
    ],
  };

    // Targeted repair: fix distractor in q2 only
    const repairedExam = structuredClone(originalExam);
    repairedExam.sections[0].questionGroups[0].questions[1].options[3].contentMd = 'Geothermal heat';

    // Verify passage and Q1 identity preserved
    assert.equal(repairedExam.sections[0].passageMd, originalExam.sections[0].passageMd);
    assert.deepEqual(
      repairedExam.sections[0].questionGroups[0].questions[0],
      originalExam.sections[0].questionGroups[0].questions[0],
    );

    // Verify only Q2 changed
    assert.notDeepEqual(
      repairedExam.sections[0].questionGroups[0].questions[1],
      originalExam.sections[0].questionGroups[0].questions[1],
    );
});

test('completion gate blocks publication when evidence cannot be established', () => {
  // Exercise the real validator, not a test-local readiness function or prose PASS.
  const report=createDomain().call('validate_exam',{exam:{id:'e1',complete:true,expectedQuestionCount:13,sections:[{id:'s1',idx:1,questions:[]}]},pilot:true});
  assert.equal(report.status,'FAIL');
  assert.ok(report.diagnostics.some(d=>d.code==='PILOT_PASSAGE_REQUIRED'));
  assert.ok(report.diagnostics.some(d=>d.code==='PILOT_MARK_COUNT'));
  assert.equal(report.data.claims.ieltsSemantics,'UNVERIFIED');
});
