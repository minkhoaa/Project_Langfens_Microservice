// Static metadata for Langfens generation-harness roles, agents, and tools.
// Zero model execution, zero network calls, offline only.
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { harnessRoot } from './runtime.mjs';

export function getHarnessRoles() {
  return [
    {
      id: 'reading',
      name: 'IELTS Reading Generator',
      status: 'Active',
      type: 'Academic & General Training Reading',
      scope: '3 Passages · 40 Questions (13–14 scoring units per section)',
      questionTypes: 19,
      description: 'Generates full canonical IELTS Reading test papers adhering strictly to the 19 .NET question types.',
      pipeline: [
        '1. Reading Generator: drafts passage & question groups (13–14 units/section)',
        '2. Question Validator: validates canonical schema, answer slots & parity',
        '3. Projection Filter: produces student allowlist, stripping private keys',
        '4. Blind Solver: solves from student projection without answer keys',
        '5. Semantic Reviewer: verifies passage support, entailment & distractors',
        '6. Evidence Verifier: validates passage spans, coverage & review signoffs'
      ],
      contracts: 'Strict wire types, all-or-nothing scoring units, no private annotation leaks.'
    },
    {
      id: 'writing',
      name: 'IELTS Writing Generator',
      status: 'Planned',
      type: 'Task 1 (Report/Letter) & Task 2 (Discursive Essay)',
      scope: 'Prompt generation, visual data tables/charts & multi-band scoring rubrics',
      description: 'Generates authentic IELTS Writing prompts with task descriptions, model answers, and band criteria.',
      pipeline: [
        '1. Task Formulation: generates Academic Chart/Process or GT Letter prompt',
        '2. Rubric Assessment: generates Task Achievement, Coherence, Lexical & Grammar criteria',
        '3. Model Response: produces sample answers at target band scores (6.5–8.5)'
      ],
      contracts: 'Band descriptor alignment, word-count constraints (150/250 words).'
    },
    {
      id: 'speaking',
      name: 'IELTS Speaking Generator',
      status: 'Planned',
      type: 'Parts 1, 2, 3 Interactive Simulation',
      scope: 'Examiner scripts, candidate cue cards, and follow-up discussion prompts',
      description: 'Generates structured 3-part IELTS speaking interviews with evaluation criteria.',
      pipeline: [
        '1. Part 1: General familiar topic questions (4–5 minutes)',
        '2. Part 2: Individual long turn cue card + follow-up questions',
        '3. Part 3: Two-way abstract and analytical discussion questions'
      ],
      contracts: 'CEFR level calibration, conversational turn constraints.'
    },
    {
      id: 'listening',
      name: 'IELTS Listening Generator',
      status: 'Planned',
      type: 'Sections 1 to 4 Audio Scripts & Questions',
      scope: 'Audio dialogue scripts, monologue lectures & 40 question items',
      description: 'Generates realistic multi-accent audio scripts and timed question sets.',
      pipeline: [
        '1. Script Synthesis: Section 1-4 dialogues, monologues & academic lectures',
        '2. Question Pairing: form completion, multiple choice, map labelling',
        '3. Distractor Verification: verifies plausible acoustic & semantic distractors'
      ],
      contracts: 'Strict audio timing markers, word count caps, single-listen constraints.'
    }
  ];
}

export function getHarnessAgents(root = harnessRoot) {
  let dir = join(root, '.generation/agents');
  if (!existsSync(dir)) {
    dir = join(harnessRoot, '.generation/agents');
  }
  if (!existsSync(dir)) return [];
  try {
    const files = readdirSync(dir).filter(f => f.endsWith('.md'));
    return files.map(file => {
      const raw = readFileSync(join(dir, file), 'utf8');
      const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
      if (!match) return { name: file.replace('.md', ''), description: '', file };
      const meta = {};
      for (const line of match[1].split('\n')) {
        const idx = line.indexOf(':');
        if (idx > 0) meta[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
      }
      const firstParagraph = match[2].trim().split('\n\n')[0].replace(/\r?\n/g, ' ');
      return {
        name: meta.name || file.replace('.md', ''),
        description: meta.description || '',
        tools: meta.tools ? meta.tools.split(',').map(s => s.trim()).filter(Boolean) : [],
        excludeTools: meta.excludeTools ? meta.excludeTools.split(',').map(s => s.trim()).filter(Boolean) : [],
        extensions: meta.subagentOnlyExtensions || '',
        promptMode: meta.systemPromptMode || 'default',
        context: meta.defaultContext || 'fresh',
        summary: firstParagraph,
        file
      };
    }).sort((a, b) => a.name.localeCompare(b.name));
  } catch {
    return [];
  }
}

export function getHarnessTools() {
  return [
    {
      category: 'Built-in Core Tools',
      items: [
        {
          name: 'read',
          scope: 'Built-in',
          description: 'Read file contents with support for line limit, offset, and image inspection.',
          parameters: 'path (string, required), limit (number), offset (number)',
          policy: 'Path restricted to repository and allowed roots. Fails closed on symlink escape.'
        },
        {
          name: 'bash',
          scope: 'Built-in',
          description: 'Execute shell commands with timeout, structured output capture, and environment isolation.',
          parameters: 'command (string, required), timeout (number)',
          policy: 'Restricted execution; network calls blocked in offline/test mode.'
        },
        {
          name: 'edit',
          scope: 'Built-in',
          description: 'Targeted exact text replacement in single files. Atomic, fails on ambiguous matches.',
          parameters: 'path (string, required), edits (array of {oldText, newText})',
          policy: 'Exact string matching; prevents non-contiguous overlapping edits.'
        },
        {
          name: 'write',
          scope: 'Built-in',
          description: 'Create or overwrite files atomically with directory creation.',
          parameters: 'path (string, required), content (string, required)',
          policy: 'Atomic file creation via temporary file and rename; safe file permissions.'
        }
      ]
    },
    {
      category: 'Subagents Substrate Tools',
      items: [
        {
          name: 'subagent',
          scope: 'Subagents Substrate',
          description: 'Delegate focused tasks to child agents, run parallel workflows, or execute scripted multi-step plans.',
          parameters: 'agent (string), task (string), workflow (string|boolean), args (object), async (boolean)',
          policy: 'Isolated child sessions, dedicated worktrees, no secret leaking across child boundaries.'
        }
      ]
    },
    {
      category: 'IELTS Reading Domain Tools',
      items: [
        {
          name: 'get_question_spec',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Executable contract for one of the 19 shared .NET question types.',
          parameters: 'type (string, required: one of 19 IELTS question kinds)',
          policy: 'Strict schema definition; validates question structure against .NET backend rules.'
        },
        {
          name: 'validate_question',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Validate canonical question, admin ingestion schema, and key completeness.',
          parameters: 'question (Question object, required)',
          policy: 'Validates answer slots, scoring units, and diagnostic error codes.'
        },
        {
          name: 'validate_group',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Check group membership, exact bounds, keys, and independent scoring units.',
          parameters: 'group (QuestionGroup object, required)',
          policy: 'Ensures 13–14 scoring units per Section; checks contiguity and index sequencing.'
        },
        {
          name: 'validate_exam',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Validate complete Exam -> Sections -> QuestionGroups -> Questions structure.',
          parameters: 'exam (Exam object, required), complete (boolean), requirements (object)',
          policy: 'Validates 40 scoring units for complete papers; verifies section allocations.'
        },
        {
          name: 'verify_evidence',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Check exact passage spans, question coverage, and independent semantic-review inputs.',
          parameters: 'passageMd, group/groups/exam, evidence, blindSolverId, semanticReviews',
          policy: 'Never proves real IELTS quality; verifies span indices and reviewer coverage.'
        },
        {
          name: 'check_grading_parity',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Execute source-derived backend grading against explicit IELTS expectations.',
          parameters: 'question (Question object, required), cases (array of parity cases)',
          policy: 'Verifies .NET backend parity; fails closed on unsupported regex.'
        },
        {
          name: 'inspect_delivery_projection',
          scope: 'Extension (.generation/extensions/reading.ts)',
          description: 'Produce an allowlisted, normalized student projection; inspect delivery against it.',
          parameters: 'exam (Exam object, required), projectionJson (optional string)',
          policy: 'Strips private keys, explanations, and reviewer notes before blind child session.'
        }
      ]
    }
  ];
}
