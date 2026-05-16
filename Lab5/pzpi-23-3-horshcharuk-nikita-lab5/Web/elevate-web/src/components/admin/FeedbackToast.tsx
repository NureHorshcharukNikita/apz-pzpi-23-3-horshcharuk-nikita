import { useEffect, useRef } from 'react'
import { createPortal } from 'react-dom'
import { useTranslation } from 'react-i18next'

export type FeedbackToastState = { ok: boolean; text: string } | null

type Props = {
  state: FeedbackToastState
  onDismiss: () => void
  autoDismissOkMs?: number
}

export function FeedbackToast({ state, onDismiss, autoDismissOkMs = 5200 }: Props) {
  const { t } = useTranslation()
  const dismissRef = useRef(onDismiss)
  dismissRef.current = onDismiss

  useEffect(() => {
    if (!state?.ok || !autoDismissOkMs) return
    const id = window.setTimeout(() => dismissRef.current(), autoDismissOkMs)
    return () => window.clearTimeout(id)
  }, [state?.ok, state?.text, autoDismissOkMs])

  if (!state) return null

  return createPortal(
    <div
      className={`feedback-toast ${state.ok ? 'feedback-toast--ok' : 'feedback-toast--error'}`}
      role={state.ok ? 'status' : 'alert'}
      aria-live={state.ok ? 'polite' : 'assertive'}
    >
      <p className="feedback-toast__text">{state.text}</p>
      <button
        type="button"
        className="btn ghost small feedback-toast__close"
        onClick={onDismiss}
        aria-label={t('common.dismissToast')}
      >
        ×
      </button>
    </div>,
    document.body,
  )
}
