export const MUSICD_ROOT = '/userdisk/bin/musicd'
export const MUSICCTL_BIN = MUSICD_ROOT + '/musicctl'

export function shellQuote(value) {
  const str = String(value || '')
  return "'" + str.replace(/'/g, "'\\''") + "'"
}

export function parseStateText(raw) {
  const state = {}
  const lines = String(raw || '').split('\n')
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i]
    const idx = line.indexOf('=')
    if (idx <= 0) continue
    const k = line.slice(0, idx)
    const v = line.slice(idx + 1)
    state[k] = v
  }
  return state
}
