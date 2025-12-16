/**
 * Maps API question response to UI-friendly format.
 * Handles various edge cases and normalizes data.
 */
export interface ApiQuestion {
  id: string | number
  text?: string | null
  type?: string | null
  options?: Array<{ id: string; label: string; isCorrect?: boolean }> | null
  points?: number | null
  explanation?: string | null
  mediaUrl?: string | null
}

export interface UiQuestion {
  id: string
  questionText: string
  questionType: string
  answers: Array<{ id: string; text: string; correct: boolean }>
  points: number
  explanation: string
  hasMedia: boolean
  mediaUrl: string
}

export function mapApiQuestionToUi(api: ApiQuestion | null | undefined): UiQuestion {
  if (!api) {
    return {
      id: '',
      questionText: '',
      questionType: 'unknown',
      answers: [],
      points: 0,
      explanation: '',
      hasMedia: false,
      mediaUrl: '',
    }
  }

  const id = String(api.id ?? '')
  const questionText = sanitizeHtml(api.text ?? '')
  const questionType = api.type ?? 'unknown'
  const points = typeof api.points === 'number' ? api.points : 0
  const explanation = sanitizeHtml(api.explanation ?? '')
  const mediaUrl = api.mediaUrl ?? ''
  const hasMedia = !!mediaUrl

  const answers = (api.options ?? []).map((opt) => ({
    id: String(opt.id ?? ''),
    text: sanitizeHtml(opt.label ?? ''),
    correct: opt.isCorrect ?? false,
  }))

  return {
    id,
    questionText,
    questionType,
    answers,
    points,
    explanation,
    hasMedia,
    mediaUrl,
  }
}

function sanitizeHtml(text: string): string {
  return text
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<[^>]+>/g, '')
    .trim()
}
