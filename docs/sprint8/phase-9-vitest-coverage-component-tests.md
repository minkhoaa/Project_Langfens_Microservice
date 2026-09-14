# Phase 9 — Vitest coverage + component tests

> **Plan file:** This is Phase 9 of Sprint 8. Read [`README.md`](./README.md) for global constraints, file structure, and execution handoff.

---

## Task 9.1: Add wizard component tests

**Files:**
- Create: `langfens-fe-app/src/app/admin/exams/auto-gen/__tests__/wizard.test.tsx`

- [ ] **Step 1: Write the test file**

```tsx
import { describe, expect, it } from "vitest";
import { createRoot, Root } from "react-dom/client";
import React from "react";
import { StepIndicator } from "../_components/StepIndicator";
import { SkillPicker } from "../_components/SkillPicker";
import { TopicForm } from "../_components/TopicForm";
import { NavButtons } from "../_components/NavButtons";
import { act } from "react";

declare global {
  // eslint-disable-next-line no-var
  var IS_REACT_ACT_ENVIRONMENT: boolean;
}
(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true;

describe("StepIndicator", () => {
  let container: HTMLDivElement | null = null;
  let root: Root | null = null;

  it("renders 4 steps when totalSteps=4", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<StepIndicator step={2} totalSteps={4} />);
    });
    const indicator = container.querySelector('[data-testid="step-indicator"]');
    expect(indicator).not.toBeNull();
    expect(container.children.length).toBe(1);
    root!.unmount();
    container.remove();
  });
});

describe("SkillPicker", () => {
  it("calls onChange when clicking a skill", async () => {
    const onChange = (s: "reading" | "listening" | "writing" | "speaking") => {
      expect(s).toBe("listening");
    };
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<SkillPicker skill="reading" onChange={onChange} />);
    });
    const buttons = container.querySelectorAll("button");
    expect(buttons.length).toBe(4);
    (buttons[1] as HTMLButtonElement).click();
    root!.unmount();
    container.remove();
  });
});

describe("TopicForm", () => {
  it("renders topic input and level input", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(<TopicForm topic="x" level={6} onTopic={() => {}} onLevel={() => {}} />);
    });
    expect(container.querySelector("#topic")).not.toBeNull();
    expect(container.querySelector("#level")).not.toBeNull();
    root!.unmount();
    container.remove();
  });
});

describe("NavButtons", () => {
  it("Next button is disabled when canNext=false", async () => {
    container = document.createElement("div");
    document.body.appendChild(container);
    root = createRoot(container);
    await act(async () => {
      root!.render(
        <NavButtons
          step={1}
          totalSteps={4}
          canNext={false}
          onPrev={() => {}}
          onNext={() => {}}
        />
      );
    });
    const buttons = container.querySelectorAll("button");
    const nextButton = buttons[1] as HTMLButtonElement;
    expect(nextButton.disabled).toBe(true);
    root!.unmount();
    container.remove();
  });
});
```

- [ ] **Step 2: Run Vitest**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test
```

Expected: 102 (Sprint 7 baseline) + 4 new = 106+ tests passed. 0 skipped.

- [ ] **Step 3: Verify no skipped suites**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
npm run test 2>&1 | grep -E "skipped|Skipped"
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /home/khoa/Projects/langfens/langfens-fe-app
git add src/app/admin/exams/auto-gen/__tests__/wizard.test.tsx
git commit -m "test(fe-admin): add Vitest component tests for wizard"
```

---
