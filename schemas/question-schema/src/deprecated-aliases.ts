import { z } from 'zod';
import {
  multipleChoiceMultiplePayloadObjectSchema,
  multipleChoiceSinglePayloadSchema,
} from './types';
import {
  multipleChoiceMultipleAnswerSchema,
  multipleChoiceSingleAnswerSchema,
} from './answers';

export const mcqSinglePayloadSchema = multipleChoiceSinglePayloadSchema.extend({
  type: z.literal('MCQ_SINGLE'),
});

export const mcqSingleAnswerSchema = multipleChoiceSingleAnswerSchema.extend({
  type: z.literal('MCQ_SINGLE'),
});

export const mcqMultiplePayloadSchema = multipleChoiceMultiplePayloadObjectSchema.extend({
  type: z.literal('MCQ_MULTIPLE'),
});

export const mcqMultipleAnswerSchema = multipleChoiceMultipleAnswerSchema.extend({
  type: z.literal('MCQ_MULTIPLE'),
});

export const DeprecatedAliasPayloadSchema = z.discriminatedUnion('type', [
  mcqSinglePayloadSchema,
  mcqMultiplePayloadSchema,
]);

export const DeprecatedAliasAnswerSchema = z.discriminatedUnion('type', [
  mcqSingleAnswerSchema,
  mcqMultipleAnswerSchema,
]);
