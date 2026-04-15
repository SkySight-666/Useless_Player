function loadNativeModule() {
  try {
    if (typeof $falcon !== 'undefined' && $falcon && typeof $falcon.requireModule === 'function') {
      const native = $falcon.requireModule('player_native')
      if (native) return native
    }
  } catch (e) {}

  try {
    if (globalThis && globalThis.player_native) {
      return globalThis.player_native
    }
  } catch (e) {}

  return null
}

export function getShellModule() {
  const native = loadNativeModule()
  if (native && native.Shell) return native.Shell

  try {
    if (globalThis && globalThis.Shell && typeof globalThis.Shell.exec === 'function') {
      return globalThis.Shell
    }
  } catch (e) {}

  return null
}

export function shellExec(command) {
  const shell = getShellModule()
  if (!shell) {
    return { ok: false, code: -1, output: 'shell module unavailable' }
  }
  try {
    const out = shell.exec(command)
    if (out && typeof out === 'object') {
      const code = typeof out.code === 'number' ? out.code : 0
      const output = out.output != null ? String(out.output) : ''
      return { ok: code === 0, code, output }
    }
    return { ok: true, code: 0, output: String(out || '') }
  } catch (err) {
    return { ok: false, code: -1, output: String(err || 'shell exec failed') }
  }
}
