<template lang="pug">
  section
    input-dialog(
      :on-open-flg='openDialogFlg', @data-change='onDataChange',
      placeholder='0.23\n0.13\n0.12',
    )
    h3.chart-ttl
      |Histogram According to Square-root Choice
      el-button.input-data-btn(
        @click='openDataInputDialog()',
        type='text', icon='el-icon-s-data'
      ) Input Data!
    .chart(:id='id', style='width: 100%;height: 450px;')
</template>

<script lang="ts">
import { Component, Vue, Prop, Watch } from 'vue-property-decorator'
import { MessageBox } from 'element-ui'
import InputDialog from './InputDialog.vue'
import { histogramOptions } from './ChartPgHelper'
import * as echarts from 'echarts'

@Component({
  components: { InputDialog },
})
export default class Histogram extends Vue {
  @Prop({ default: 'histogram-playground' }) private id!: string
  private chart: echarts.ECharts | null = null
  private chartData: string | null = null
  private openDialogFlg = 0
  private rawData: string = ''

  openDataInputDialog() {
    this.openDialogFlg = Date.now()
  }

  mounted() {
    this.initChart()
    this.openDataInputDialog()
  }

  beforeDestroy() {
    if (!this.chart) {
      return
    }
    this.chart.dispose()
    this.chart = null
  }

  initChart() {
    const el = document.getElementById(this.id)
    this.chart = echarts.init(el as HTMLDivElement)
    this.chart.showLoading()
  }

  onDataChange(rawData: string) {
    this.rawData = rawData
    this.updateChart()
  }
  // @Watch('chartData')
  // onValueChange(newValue: string, oldValue: string): void {
  //   this.updateChart()
  // }

  updateChart() {
    if (this.chart) {
      try {
        const opt = histogramOptions(this.rawData)
        this.chart.setOption(opt)
        this.chart.hideLoading()
      } catch (e) {
        setTimeout(() => {
          MessageBox.alert(e.toString(), {
            confirmButtonText: 'OK',
          }).then(() => {
            setTimeout(() => {
              this.openDataInputDialog()
            }, 150)
          }).catch(() => { /* Handle `cancel` Action */ })
        }, 150)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import "src/styles/challenges.scss";

.chart-ttl {
  margin-bottom: .7rem;
}

.input-data-btn {
  float: right;
  margin-top: -5px;
  margin-left: -105px;
}

@media (max-width: 800px) {
  .input-data-btn {
    display: block;
    margin-left: calc(100% - 100px);
  }
}
</style>
