// Shared building blocks
export * from './shared';
// Discriminator + canonical slug list
export * from './discriminator';
// Per-type label + authoring metadata
export * from './labels';
export * from './metadata';
// Per-type payload & answer schemas + the discriminated unions
export * from './types';
export * from './answers';
// Backward-compat deprecated aliases
export * from './deprecated-aliases';
// Cross-reference validators + envelope schemas (Phase 3)
export * from './invariants';
export * from './envelopes';
export * from './retry';