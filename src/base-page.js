export class BasePage extends $falcon.Page {
  constructor() {
    super()
    this.timeoutTokens = new Set()
    this.intervalTokens = new Set()
  }

  setTimeout(func, ms) {
    const token = setTimeout(() => {
      this.timeoutTokens.delete(token)
      func()
    }, ms)
    this.timeoutTokens.add(token)
    return token
  }

  setInterval(func, ms) {
    const token = setInterval(func, ms)
    this.intervalTokens.add(token)
    return token
  }

  clearTimeout(token) {
    this.timeoutTokens.delete(token)
    clearTimeout(token)
  }

  clearInterval(token) {
    this.intervalTokens.delete(token)
    clearInterval(token)
  }

  release() {
    for (const token of this.timeoutTokens) clearTimeout(token)
    for (const token of this.intervalTokens) clearInterval(token)
    this.timeoutTokens.clear()
    this.intervalTokens.clear()
  }

  onLoad(options) {
    super.onLoad(options)
    this.options = options
  }

  onNewOptions(options) {
    super.onNewOptions(options)
    this.options = options
  }

  onUnload() {
    try {
      super.onUnload()
      if (this.$root && this.$root.onUnload) this.$root.onUnload()
    } finally {
      this.release()
    }
  }
}
