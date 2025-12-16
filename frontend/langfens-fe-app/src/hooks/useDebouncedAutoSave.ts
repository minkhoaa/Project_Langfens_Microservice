import { useEffect, useRef, useCallback } from 'react'

/**
 * A hook that debounces auto-save functionality.
 * Triggers save callback after a delay, canceling previous pending saves.
 * 
 * @param value - The value to watch for changes
 * @param onSave - Callback to execute when debounced save triggers
 * @param delay - Debounce delay in milliseconds (default: 1000)
 * @param enabled - Whether auto-save is enabled (default: true)
 */
export function useDebouncedAutoSave<T>(
  value: T,
  onSave: (value: T) => void | Promise<void>,
  delay: number = 1000,
  enabled: boolean = true
): {
  isPending: boolean
  cancel: () => void
  flush: () => void
} {
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const isPendingRef = useRef(false)
  const latestValueRef = useRef(value)
  const onSaveRef = useRef(onSave)
  const initialRenderRef = useRef(true)

  // Keep refs updated
  latestValueRef.current = value
  onSaveRef.current = onSave

  const cancel = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
      timeoutRef.current = null
    }
    isPendingRef.current = false
  }, [])

  const flush = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
      timeoutRef.current = null
      onSaveRef.current(latestValueRef.current)
      isPendingRef.current = false
    }
  }, [])

  useEffect(() => {
    // Skip initial render
    if (initialRenderRef.current) {
      initialRenderRef.current = false
      return
    }

    if (!enabled) {
      cancel()
      return
    }

    // Clear previous timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
    }

    // Set new timeout
    isPendingRef.current = true
    timeoutRef.current = setTimeout(() => {
      onSaveRef.current(latestValueRef.current)
      isPendingRef.current = false
      timeoutRef.current = null
    }, delay)

    // Cleanup on unmount or value change
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [value, delay, enabled, cancel])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [])

  return {
    isPending: isPendingRef.current,
    cancel,
    flush,
  }
}
