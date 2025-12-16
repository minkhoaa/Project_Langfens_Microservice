import { describe, it, expect } from 'vitest'
import { mapApiQuestionToUi, ApiQuestion } from '../mapApiQuestionToUi'

describe('CU-006: mapApiQuestionToUi', () => {
  // Case 1: Standard valid payload
  it('should map a standard valid API question', () => {
    const api: ApiQuestion = {
      id: '123',
      text: 'What is React?',
      type: 'single-choice',
      options: [
        { id: 'a', label: 'A library', isCorrect: true },
        { id: 'b', label: 'A framework', isCorrect: false },
      ],
      points: 10,
      explanation: 'React is a JavaScript library.',
      mediaUrl: 'https://example.com/image.png',
    }

    const result = mapApiQuestionToUi(api)

    expect(result.id).toBe('123')
    expect(result.questionText).toBe('What is React?')
    expect(result.questionType).toBe('single-choice')
    expect(result.answers).toHaveLength(2)
    expect(result.answers[0].correct).toBe(true)
    expect(result.points).toBe(10)
    expect(result.hasMedia).toBe(true)
    expect(result.mediaUrl).toBe('https://example.com/image.png')
  })

  // Case 2: Null input
  it('should return default UI question for null input', () => {
    const result = mapApiQuestionToUi(null)

    expect(result.id).toBe('')
    expect(result.questionText).toBe('')
    expect(result.questionType).toBe('unknown')
    expect(result.answers).toEqual([])
    expect(result.points).toBe(0)
  })

  // Case 3: Undefined input
  it('should return default UI question for undefined input', () => {
    const result = mapApiQuestionToUi(undefined)

    expect(result.id).toBe('')
    expect(result.questionType).toBe('unknown')
  })

  // Case 4: Missing optional fields (null)
  it('should handle missing optional fields (null)', () => {
    const api: ApiQuestion = {
      id: '1',
      text: null,
      type: null,
      options: null,
      points: null,
      explanation: null,
      mediaUrl: null,
    }

    const result = mapApiQuestionToUi(api)

    expect(result.questionText).toBe('')
    expect(result.questionType).toBe('unknown')
    expect(result.answers).toEqual([])
    expect(result.points).toBe(0)
    expect(result.explanation).toBe('')
    expect(result.hasMedia).toBe(false)
  })

  // Case 5: Missing optional fields (undefined)
  it('should handle missing optional fields (undefined)', () => {
    const api: ApiQuestion = { id: '2' }

    const result = mapApiQuestionToUi(api)

    expect(result.id).toBe('2')
    expect(result.questionText).toBe('')
    expect(result.answers).toEqual([])
  })

  // Case 6: Empty arrays
  it('should handle empty options array', () => {
    const api: ApiQuestion = {
      id: '3',
      text: 'Question with no options',
      options: [],
    }

    const result = mapApiQuestionToUi(api)

    expect(result.answers).toEqual([])
  })

  // Case 7: Numeric ID
  it('should convert numeric ID to string', () => {
    const api: ApiQuestion = { id: 42, text: 'Numeric ID' }

    const result = mapApiQuestionToUi(api)

    expect(result.id).toBe('42')
    expect(typeof result.id).toBe('string')
  })

  // Case 8: HTML sanitization
  it('should sanitize HTML in text fields', () => {
    const api: ApiQuestion = {
      id: '4',
      text: '<p>Hello <script>alert("xss")</script>World</p>',
      explanation: '<b>Bold</b> explanation',
      options: [{ id: 'x', label: '<i>Italic</i> option' }],
    }

    const result = mapApiQuestionToUi(api)

    expect(result.questionText).not.toContain('<script>')
    expect(result.questionText).not.toContain('<p>')
    expect(result.explanation).not.toContain('<b>')
    expect(result.answers[0].text).not.toContain('<i>')
  })

  // Case 9: Zero points
  it('should handle zero points correctly', () => {
    const api: ApiQuestion = { id: '5', points: 0 }

    const result = mapApiQuestionToUi(api)

    expect(result.points).toBe(0)
  })

  // Case 10: Options without isCorrect
  it('should default isCorrect to false when missing', () => {
    const api: ApiQuestion = {
      id: '6',
      options: [{ id: 'a', label: 'Option A' }],
    }

    const result = mapApiQuestionToUi(api)

    expect(result.answers[0].correct).toBe(false)
  })

  // Case 11: Media URL presence
  it('should set hasMedia based on mediaUrl presence', () => {
    const withMedia: ApiQuestion = { id: '7', mediaUrl: 'http://x.com/img.jpg' }
    const withoutMedia: ApiQuestion = { id: '8', mediaUrl: '' }

    expect(mapApiQuestionToUi(withMedia).hasMedia).toBe(true)
    expect(mapApiQuestionToUi(withoutMedia).hasMedia).toBe(false)
  })
})
