import { BasePage } from './base-page.js'

class App extends $falcon.App {
  constructor() {
    super()
  }

  onLaunch(options) {
    super.onLaunch(options)
    // 按 800 宽设计，适配词典笔长条屏
    this.setViewPort(800)
    $falcon.useDefaultBasePageClass(BasePage)
  }
}

export default App
