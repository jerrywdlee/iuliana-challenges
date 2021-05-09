<template lang="pug">
  .app-container
    h1.module-ttl Aozora Bunko - Search Authors
    .inner-container
      h2.inner-container-ttl Search Authors
      el-form(ref='authorsForm', :model='authorsForm', label-width='120px')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-form-item(label='Author', prop='Author Name')
            el-input(v-model='authorsForm.author', type='text',
              name='author', placeholder='Author Name', :disabled='authorsForm.onloadFlg')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-form-item(label='Title', prop='Book Title')
            el-input(v-model='authorsForm.title', type='text',
              name='title', placeholder='Book Title', :disabled='authorsForm.onloadFlg')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-row.inline-btn-row
            el-button(type='primary', @click='searchAuthors', :loading='authorsForm.onloadFlg')
              | Search Authors
    .inner-container
      el-table(:data='authors', :loading='authorsForm.onloadFlg', name='Authors',
        border, fit, stripe, highlight-current-row)
        el-table-column(label='UID', prop='uid', align='center', width='80')
          template(slot-scope='{row}')
            span {{ row.author_uid }}
        el-table-column(label='Name', prop='name', align='center')
          template(slot-scope='{row}')
            el-link(type='primary' @click='getAuthorInfo(row.id)') {{ row.full_name }}
        el-table-column(label='Name Roman', align='center')
          template(slot-scope='{row}')
            span {{ row.first_name_roman }} {{ row.last_name_roman }}
        el-table-column(label='Aozora Url', align='center')
          template(slot-scope='{row}')
            el-button(@click='openUrl(row.aozora_url)', type='text', icon='el-icon-link')
              | Aozora Url
        el-table-column(label='Wiki Url', align='center')
          template(slot-scope='{row}')
            el-button(@click='openUrl(row.wiki_url)', type='text', icon='el-icon-link')
              | Wiki Url
      el-pagination(background, layout='total, prev, pager, next', :page-size='authorsForm.limitPerPage',
        :disabled='authorsForm.onloadFlg', :total='authorsForm.authorNum', @current-change='authorsPageChange')
    el-dialog.author-info(:visible.sync="dialogVisible", title='Author Info')
      el-table(:data='authorInfo', :show-header='false', border, fit, stripe, highlight-current-row)
        el-table-column(label='')
          template(slot-scope='{row}')
            b {{ startCase(row.label) }}
        el-table-column(label='')
          template(slot-scope='{row}')
            el-button(v-if='row.url' @click='openUrl(row.url)', type='text', icon='el-icon-link')
              | {{ row.val }}
            span(v-else) {{ row.val }}
      br
      el-table(:data='authorBooks', border, fit, stripe, highlight-current-row)
        el-table-column(label='Title', align='center')
          template(slot-scope='{row}')
            span {{ row.title }}
        el-table-column(label='Role', align='center')
          template(slot-scope='{row}')
            span {{ row.role }}
        el-table-column(label='Card Url', align='center')
          template(slot-scope='{row}')
            el-button(@click='openUrl(row.card_url)', type='text', icon='el-icon-link')
              | Aozora Url
        el-table-column(label='Wiki Url', align='center')
          template(slot-scope='{row}')
            el-button(@click='openUrl(row.wiki_url)', type='text', icon='el-icon-link')
              | Wiki Url
</template>

<script lang="ts">
/* eslint-disable no-useless-escape */
import { Component, Vue } from 'vue-property-decorator'
import request from '@/utils/request'
import { startCase } from 'lodash'

// configure language
import lang from 'element-ui/lib/locale/lang/en'
import locale from 'element-ui/lib/locale'
locale.use(lang)

type cbFunc = () => void | Promise<void>
interface formData {
  [key: string]: any
  onloadFlg: boolean
}

@Component
export default class Form extends Vue {
  private authorsForm: formData = {
    title: '',
    author: '',
    authorNum: 0,
    limitPerPage: 20,
    onloadFlg: false,
  }

  private authors = [] as {[key: string]: any}[]

  private searchAuthors(event: MouseEvent) {
    event.preventDefault()

    const queryParams = new URLSearchParams()
    queryParams.append('book_title', this.authorsForm.title)
    queryParams.append('author_name', this.authorsForm.author)
    this.$message(`Seaching Books...`)

    this.loadAuthors(queryParams)
    return true
  }

  private authorsPageChange(page = 1) {
    const queryParams = new URLSearchParams()
    queryParams.append('book_title', this.authorsForm.title)
    queryParams.append('author_name', this.authorsForm.author)
    queryParams.append('page', page.toString())

    this.loadAuthors(queryParams)
  }

  private loadAuthors(queryParams: URLSearchParams) {
    const getData = {
      url: `/aozora/authors.json?${queryParams.toString()}`,
      method: 'get',
    }

    this.authorsForm.onloadFlg = true
    request(getData).then(res => {
      const { data } = res
      this.authors = data.authors

      this.authorsForm.authorNum = data.total_count
      this.authorsForm.limitPerPage = data.limit_per_page
      this.authorsForm.onloadFlg = false
    }).catch(err => {
      console.error(err)
      this.authorsForm.onloadFlg = false
    })
  }

  private authorInfo = [] as {[key: string]: any}[]
  private authorBooks = [] as {[key: string]: any}[]
  private dialogVisible = false

  private getAuthorInfo(rowId: number) {
    const getData = {
      url: `/aozora/${rowId}/show_author.json`,
      method: 'get',
    }
    request(getData).then(res => {
      const { data } = res
      const labels = [
        'author_uid', 'full_name', 'last_name', 'first_name',
        'last_name_yomi', 'first_name_yomi',
        'last_name_roman', 'first_name_roman',
        'date_of_birth', 'date_of_death', 'outline',
      ]
      this.authorInfo = labels.map(label => {
        return { label, val: data[label] }
      })

      const urlLabels = ['aozora_url', 'wiki_url']
      urlLabels.forEach(label => {
        const urlRow = { label, url: data[label], val: `Open ${label}` }
        if (!data[label]) {
          urlRow.val = ''
        }
        this.authorInfo.push(urlRow)
      })

      this.authorBooks = data.books

      this.dialogVisible = true
    }).catch(err => {
      console.error(err)
    })
  }

  private openUrl(url: string) {
    return window.open(url)
  }

  private startCase = startCase

  mounted() {}
}
</script>

<style lang="scss">
@media (max-width: 800px) {
  .author-info {
    .el-dialog {
      width: 90%;
    }
  }
}
</style>

<style lang="scss" scoped>
@import "src/styles/console.scss";

.inner-container {
  .el-form {
    display: block;
    width: 100%;
  }
  .el-pagination {
    margin-top: 15px;
  }
  .inline-btn-row {
    display: flex;
    .el-button:first-child {
      margin-left: calc(120px + 10px);
    }
  }
}

@media (max-width: 800px) {
  .inner-container {
    .inline-btn-row {
      .el-button:first-child {
        margin-left: auto;
      }
      //.el-button:last-child {
      //  margin-right: auto;
      //}
    }
  }
}
</style>
