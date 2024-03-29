<template lang="pug">
  .app-container
    h2.module-ttl
      | Try GraphQL Queries Here!
      el-button.cheat-sheet-btn(@click='openCheatSheet', type='text', icon='el-icon-question')
        | Cheat Sheet
    .inner-container
      .graphql-area(v-loading='!ifameReadyFlg')
        iframe.graphql-iframe(:src='graphiglUrl', :onload='ifameReady()')
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { MessageBox } from 'element-ui'
import { UserModule } from '@/store/modules/user'
import { getBaseURL } from '@/utils/request'
import { getToken } from '@/utils/auth'

@Component
export default class Form extends Vue {
  private graphiglUrl = ''
  private ifameReadyFlg = false

  beforeMount() {
    this.graphiglUrl = `${getBaseURL()}graphiql?auth=${getToken()}`
  }

  mounted() {
    const roles = UserModule.roles.map((r: string) => r.toString().toLowerCase())
    const { appConfigs } = UserModule
    if (!roles.includes('admin')) {
      MessageBox.alert('Only Admin Users Are Allowed.', {
        confirmButtonText: 'OK',
      }).then(() => {
        this.$router.push({ path: '/' })
      }).catch(() => { /* Handle `cancel` Action */ })
    } else if (!appConfigs.general.allowGraphiql) {
      this.ifameReadyFlg = false
      this.graphiglUrl = ''
      MessageBox.alert('GraphiQL is Unavailable. Turn on GraphiQL in Console', {
        confirmButtonText: 'OK',
      }).then(() => {
        this.$router.push({ path: '/console/index' })
      }).catch(() => { /* Handle `cancel` Action */ })
    }
  }

  private openCheatSheet() {
    const url = 'https://github.com/jerrywdlee/iuliana-challenges/blob/master/documents/graphql_cheat_sheet.md'
    const win = window.open(url)
  }

  private ifameReady() {
    if (this.graphiglUrl) {
      this.ifameReadyFlg = true
    }
  }

  private onSubmit() {
    this.$message('submit!')
  }

  private onCancel() {
    this.$message({
      message: 'cancel!',
      type: 'warning',
    })
  }
}
</script>

<style lang="scss">
.graphql-area {
  .el-loading-mask {
    border-radius: 5px;
  }
}
</style>

<style lang="scss" scoped>
@import "src/styles/console.scss";

.graphql-area {
  .graphql-iframe {
    width: 100%;
    border: none;
    box-shadow: 3px 3px 6px 6px rgba(0,0,0,0.15);
    border-radius: 5px;
    min-height: calc(100vh - 165px);
  }
}

.module-ttl {
  padding-left: 15px;
  padding-right: 15px;
}

.cheat-sheet-btn {
  float: right;
  margin-left: -105px;
}
@media (max-width: 800px) {
  .cheat-sheet-btn {
    display: block;
    margin-left: calc(100% - 100px);
  }
}
</style>
