import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { renderHook, act } from '@testing-library/react'
import { useDebouncedAutoSave } from '../useDebouncedAutoSave'

describe('CU-007: useDebouncedAutoSave', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  // Case 1: Initial state - no save triggered
  it('should not trigger save on initial render', () => {
    const onSave = vi.fn()
    renderHook(() => useDebouncedAutoSave('initial', onSave, 1000))

    vi.advanceTimersByTime(2000)

    expect(onSave).not.toHaveBeenCalled()
  })

  // Case 2: Save triggered after delay
  it('should trigger save after delay when value changes', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'changed' })
    vi.advanceTimersByTime(1000)

    expect(onSave).toHaveBeenCalledWith('changed')
    expect(onSave).toHaveBeenCalledTimes(1)
  })

  // Case 3: Save NOT triggered before delay
  it('should not trigger save before delay completes', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'changed' })
    vi.advanceTimersByTime(500)

    expect(onSave).not.toHaveBeenCalled()
  })

  // Case 4: Debounce reset on rapid changes
  it('should debounce rapid changes and only trigger once', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'v0' } }
    )

    rerender({ value: 'v1' })
    vi.advanceTimersByTime(300)
    rerender({ value: 'v2' })
    vi.advanceTimersByTime(300)
    rerender({ value: 'v3' })
    vi.advanceTimersByTime(1000)

    expect(onSave).toHaveBeenCalledTimes(1)
    expect(onSave).toHaveBeenCalledWith('v3')
  })

  // Case 5: Component unmount cancels timer
  it('should cancel pending save on unmount', () => {
    const onSave = vi.fn()
    const { rerender, unmount } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'changed' })
    vi.advanceTimersByTime(500)
    unmount()
    vi.advanceTimersByTime(1000)

    expect(onSave).not.toHaveBeenCalled()
  })

  // Case 6: Cancel function works
  it('should cancel pending save when cancel() is called', () => {
    const onSave = vi.fn()
    const { result, rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'changed' })
    vi.advanceTimersByTime(500)
    act(() => result.current.cancel())
    vi.advanceTimersByTime(1000)

    expect(onSave).not.toHaveBeenCalled()
  })

  // Case 7: Flush function triggers immediate save
  it('should trigger immediate save when flush() is called', () => {
    const onSave = vi.fn()
    const { result, rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 1000),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'flushed' })
    vi.advanceTimersByTime(100)
    act(() => result.current.flush())

    expect(onSave).toHaveBeenCalledWith('flushed')
    expect(onSave).toHaveBeenCalledTimes(1)
  })

  // Case 8: Disabled mode prevents save
  it('should not trigger save when disabled', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value, enabled }) => useDebouncedAutoSave(value, onSave, 1000, enabled),
      { initialProps: { value: 'initial', enabled: false } }
    )

    rerender({ value: 'changed', enabled: false })
    vi.advanceTimersByTime(2000)

    expect(onSave).not.toHaveBeenCalled()
  })

  // Case 9: Custom delay works
  it('should respect custom delay value', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 500),
      { initialProps: { value: 'initial' } }
    )

    rerender({ value: 'changed' })
    vi.advanceTimersByTime(400)
    expect(onSave).not.toHaveBeenCalled()

    vi.advanceTimersByTime(100)
    expect(onSave).toHaveBeenCalledTimes(1)
  })

  // Case 10: Multiple value changes with final value saved
  it('should save the latest value after debounce', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value }) => useDebouncedAutoSave(value, onSave, 500),
      { initialProps: { value: 'a' } }
    )

    rerender({ value: 'b' })
    rerender({ value: 'c' })
    rerender({ value: 'd' })
    vi.advanceTimersByTime(500)

    expect(onSave).toHaveBeenLastCalledWith('d')
  })

  // Case 11: Re-enabling triggers save
  it('should trigger save when re-enabled after value change', () => {
    const onSave = vi.fn()
    const { rerender } = renderHook(
      ({ value, enabled }) => useDebouncedAutoSave(value, onSave, 500, enabled),
      { initialProps: { value: 'initial', enabled: false } }
    )

    rerender({ value: 'changed', enabled: false })
    vi.advanceTimersByTime(1000)
    expect(onSave).not.toHaveBeenCalled()

    rerender({ value: 'changed', enabled: true })
    vi.advanceTimersByTime(500)
    expect(onSave).toHaveBeenCalledWith('changed')
  })
})
