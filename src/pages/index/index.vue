<template>
  <div class="page root">
    <div class="topbar">
      <text class="title">Useless Player</text>
      <text class="sub">backend: {{ backendRoot }}</text>
      <text class="sub">output: {{ state.audio_output_name || '-' }}</text>
      <text class="sub">{{ state.playing === '1' ? 'playing' : (state.paused === '1' ? 'paused' : 'idle') }}</text>
    </div>

    <div class="main">
      <div class="left">
        <input class="path-input" :value="pathInput" @input="onPathInput" placeholder="/userdisk/Music/demo.mp3" />

        <div class="btn-row">
          <text class="btn" @click="playNow">PLAY</text>
          <text class="btn" @click="enqueueNow">ENQUEUE</text>
          <text class="btn" @click="pauseNow">PAUSE</text>
          <text class="btn" @click="resumeNow">RESUME</text>
          <text class="btn" @click="nextNow">NEXT</text>
          <text class="btn danger" @click="stopNow">STOP</text>
        </div>

        <div class="btn-row">
          <text class="btn ghost" @click="setOutput('speaker')">SPK</text>
          <text class="btn ghost" @click="setOutput('tc_analog')">ANALOG</text>
          <text class="btn ghost" @click="setOutput('tc_digital')">DIGITAL</text>
          <text class="btn ghost" @click="setOutput('bt')">BT</text>
          <text class="btn ghost" @click="refreshOutputs">OUTPUTS</text>
          <text class="btn ghost" @click="refreshState">STATE</text>
        </div>

        <div class="song-line">
          <text class="song-label">Now:</text>
          <text class="song-text">{{ state.track_title || '-' }}</text>
        </div>
      </div>

      <div class="right">
        <scroller class="log-scroller" scroll-direction="vertical" show-scrollbar="true">
          <div v-for="(line, idx) in logs" :key="idx" class="log-line">
            <text class="log-text">{{ line }}</text>
          </div>
        </scroller>
      </div>
    </div>
  </div>
</template>

<script>
import { MUSICD_ROOT, MUSICCTL_BIN, parseStateText, shellQuote } from '../../utils/backend.js'
import { shellExec } from '../../utils/shell-api.js'

export default {
  name: 'index',
  data() {
    return {
      backendRoot: MUSICD_ROOT,
      pathInput: '/userdisk/Music/',
      logs: [],
      state: {
        playing: '0',
        paused: '0',
        audio_output_name: '',
        track_title: ''
      },
      _pollToken: null
    }
  },

  mounted() {
    this.addLog('player ready')
    this.refreshState()
    this.handleExternalInvoke(this.$page && this.$page.options ? this.$page.options : {})
    this._pollToken = this.$page.setInterval(() => this.refreshState(), 1200)
  },

  methods: {
    onShow() {
      this.handleExternalInvoke(this.$page && this.$page.options ? this.$page.options : {})
    },

    onUnload() {
      if (this._pollToken) this.$page.clearInterval(this._pollToken)
      this._pollToken = null
    },

    addLog(msg) {
      this.logs.push(msg)
      if (this.logs.length > 80) this.logs.shift()
    },

    runCtl(args) {
      const cmd = MUSICCTL_BIN + ' ' + args
      const ret = shellExec(cmd)
      this.addLog('$ ' + cmd)
      if (ret.output) this.addLog(String(ret.output).trim())
      return String(ret.output || '')
    },

    onPathInput(e) {
      this.pathInput = e && e.value ? e.value : ''
    },

    playNow() {
      const p = this.pathInput.trim()
      if (!p) return
      this.runCtl('play ' + shellQuote(p))
      this.refreshState()
    },

    enqueueNow() {
      const p = this.pathInput.trim()
      if (!p) return
      this.runCtl('enqueue ' + shellQuote(p))
      this.refreshState()
    },

    pauseNow() { this.runCtl('pause'); this.refreshState() },
    resumeNow() { this.runCtl('resume'); this.refreshState() },
    stopNow() { this.runCtl('stop'); this.refreshState() },
    nextNow() { this.runCtl('next'); this.refreshState() },

    setOutput(name) {
      this.runCtl('card ' + name)
      this.refreshState()
    },

    refreshOutputs() {
      this.runCtl('card list')
    },

    refreshState() {
      const raw = this.runCtl('state')
      if (!raw) return
      this.state = Object.assign({}, this.state, parseStateText(raw))
    },

    handleExternalInvoke(options) {
      if (!options) return
      const action = String(options.action || '').toLowerCase()
      if (!action) return

      if (options.output) {
        this.runCtl('card ' + shellQuote(String(options.output)))
      }

      if (action === 'play') {
        const target = String(options.url || options.path || options.target || '')
        if (target) this.runCtl('play ' + shellQuote(target))
      } else if (action === 'enqueue') {
        const target = String(options.url || options.path || options.target || '')
        if (target) this.runCtl('enqueue ' + shellQuote(target))
      } else if (action === 'pause' || action === 'resume' || action === 'next' || action === 'stop' || action === 'state') {
        this.runCtl(action)
      } else if (action === 'output') {
        const out = String(options.name || options.output || '')
        if (out) this.runCtl('card ' + shellQuote(out))
      }

      this.refreshState()

      if (String(options.autoclose || '') === '1') {
        this.$page && this.$page.finish && this.$page.finish()
      }
    }
  }
}
</script>

<style lang="less" scoped>
@import '../../styles/base.less';

.root {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.topbar {
  height: 40px;
  display: flex;
  align-items: center;
  border-bottom-width: 1px;
  border-bottom-style: solid;
  border-bottom-color: rgba(255, 255, 255, 0.14);
}

.title {
  margin-right: 10px;
  font-size: 20px;
  font-weight: 700;
  color: #8ed0ff;
}

.sub {
  margin-right: 10px;
  font-size: 12px;
  color: #b7d7ee;
}

.main {
  flex: 1;
  display: flex;
  margin-top: 8px;
  overflow: hidden;
}

.left {
  width: 560px;
  margin-right: 10px;
  display: flex;
  flex-direction: column;
}

.right {
  flex: 1;
  border-width: 1px;
  border-style: solid;
  border-color: rgba(255, 255, 255, 0.18);
  background-color: rgba(6, 12, 18, 0.55);
}

.path-input {
  width: 100%;
  height: 34px;
  padding-left: 8px;
  padding-right: 8px;
  color: #e7f5ff;
  background-color: rgba(6, 12, 18, 0.65);
  border-width: 1px;
  border-style: solid;
  border-color: rgba(126, 198, 255, 0.45);
}

.btn-row {
  margin-top: 8px;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.btn {
  width: 84px;
  height: 30px;
  line-height: 30px;
  margin-right: 6px;
  margin-bottom: 6px;
  text-align: center;
  border-radius: 4px;
  font-size: 12px;
  background-color: #2d8fd3;
  color: #ffffff;
}

.ghost {
  background-color: #2c4258;
}

.danger {
  background-color: #b84b4b;
}

.song-line {
  margin-top: 2px;
  height: 28px;
  display: flex;
  align-items: center;
}

.song-label {
  width: 40px;
  margin-right: 6px;
  color: #90c6e8;
  font-size: 12px;
}

.song-text {
  flex: 1;
  font-size: 12px;
  color: #ffffff;
}

.log-scroller {
  width: 100%;
  height: 100%;
  padding-left: 6px;
  padding-right: 6px;
  padding-top: 6px;
  box-sizing: border-box;
}

.log-line {
  min-height: 18px;
}

.log-text {
  font-size: 11px;
  color: #acd4ee;
}
</style>
