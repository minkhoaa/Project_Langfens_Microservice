import type { TSchema } from 'typebox';

export type Status = 'PASS' | 'FAIL' | 'UNVERIFIED' | 'ERROR';
export type Category = 'contract' | 'structure' | 'semantic' | 'hierarchy' | 'evidence' | 'projection' | 'serialization' | 'grading' | 'compatibility' | 'isolation';
// Canonical authoring/schema shapes are resolved dynamically from the sole contract,
// not duplicated as independently maintained TypeScript Question interfaces.
export type CanonicalRecord = Record<string, any>;
export interface Check { id: string; status: Status; category: Category; path: string; provenance: string[] }
export interface Diagnostic { code: string; status: Exclude<Status, 'PASS'>; path: string; message: string; suggestedCorrection: string; expected?: unknown; provenance?: string[]; decodedPath?: string; propertyIndex?: number }
export interface ReadingResult { status: Status; contractVersion: string; contractId: string; contractHash: string | null; checks: Check[]; diagnostics: Diagnostic[]; data?: CanonicalRecord }
export type OutcomeMark = Readonly<Record<Status, number>>;
export interface Report {
  result: ReadingResult;
  mark(): OutcomeMark;
  statusSince(mark: OutcomeMark): Status;
  addCheck(check: Check): void;
  addDiagnostic(diagnostic: Diagnostic): void;
  check(id: string, status: Status, provenance?: string | string[], path?: string, category?: Category): void;
  diagnostic(code: string, path: string, message: string, correction?: string, expected?: unknown, status?: Exclude<Status, 'PASS'>, rule?: string, extra?: Partial<Diagnostic>): void;
  pending(code: string, path: string, message: string, rule?: string, correction?: string): void;
  finish(data?: CanonicalRecord): ReadingResult;
}
export interface CanonicalValidator { Check(value: unknown): boolean; Errors(value: unknown): CanonicalRecord[] }
export interface CanonicalContext { schema: CanonicalRecord; meta: CanonicalRecord; hash: string; propertyNames: Set<string>; validator(ref: string): CanonicalValidator }
export interface QuestionSummary { structuralValid: boolean; type?: string; family?: string; answerSlots: number | null; scoringUnits: number | null; [key: string]: unknown }
export interface Domain { call(name: string, args: unknown): ReadingResult }
export type BoundarySchema = TSchema;
