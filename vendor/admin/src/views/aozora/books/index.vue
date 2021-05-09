<template lang="pug">
  .app-container
    h1.module-ttl Aozora Bunko - Search Books
    .inner-container
      h2.inner-container-ttl Search Books
      el-form(ref='booksForm', :model='booksForm', label-width='120px')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-form-item(label='Title', prop='Book Title')
            el-input(v-model='booksForm.title', type='text',
              name='title', placeholder='Book Title', :disabled='booksForm.onloadFlg')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-form-item(label='Author', prop='Author Name')
            el-input(v-model='booksForm.author', type='text',
              name='author', placeholder='Author Name', :disabled='booksForm.onloadFlg')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-form-item(label='Role', prop='role')
            el-select(v-model='booksForm.role', placeholder='Select Role',
              :disabled='booksForm.onloadFlg')
              el-option(v-for='role in booksForm.roleList',
                :label='role.toUpperCase()', :key='role', :value='role')
        el-col(:xs='24', :sm='24', :md='6', :lg='6', :xl='6')
          el-row.inline-btn-row
            el-button(type='primary', @click='searchBooks', :loading='booksForm.onloadFlg')
              | Search Books
    .inner-container
      el-table(key='booksTable', :data='books', :loading='booksForm.onloadFlg',
        empty-text='No Data', name='Books', border, fit, stripe, highlight-current-row)
        el-table-column(label='UID', prop='uid', align='center', width='80', class-name='book-id')
          template(slot-scope='{row}')
            span {{ row.book_uid }}
        el-table-column(label='Title', prop='title', align='center', class-name='book-title')
          template(slot-scope='{row}')
            el-link(type='primary' @click='getBookInfo(row.id)') {{ row.title }}
        el-table-column(label='Authors', prop='authors', align='center', class-name='book-authors')
          template(slot-scope='{row}')
            span {{ row.authorNames }}
      el-pagination(background, layout='total, prev, pager, next', :page-size='booksForm.limitPerPage',
        :disabled='booksForm.onloadFlg', :total='booksForm.bookNum', @current-change='booksPageChange')
    el-dialog.book-info(:visible.sync="dialogVisible", title='Book Info')
      el-table(:data='bookInfo', :show-header='false', border, fit, stripe, highlight-current-row)
        el-table-column(label='')
          template(slot-scope='{row}')
            b {{ row.label }}
        el-table-column(label='')
          template(slot-scope='{row}')
            el-button(v-if='row.url' @click='openUrl(row.url)', type='text', icon='el-icon-link')
              | {{ row.val }}
            span(v-else) {{ row.val }}
      br
      el-table(:data='bookAuthors', border, fit, stripe, highlight-current-row)
        el-table-column(label='Author Name', align='center')
          template(slot-scope='{row}')
            span {{ row.full_name }}
        el-table-column(label='Name Roman', align='center')
          template(slot-scope='{row}')
            span {{ row.first_name_roman }} {{ row.last_name_roman }}
        el-table-column(label='Role', align='center')
          template(slot-scope='{row}')
            span {{ row.role }}
        el-table-column(label='Aozora Url', align='center')
          template(slot-scope='{row}')
            el-button(@click='openUrl(row.aozora_url)', type='text', icon='el-icon-link')
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
  private booksForm: formData = {
    title: '',
    author: '',
    role: '',
    roleList: [ '著者', '翻訳者' ],
    bookNum: 0,
    limitPerPage: 20,
    onloadFlg: false,
  }

  private books = [] as {[key: string]: any}[]

  private searchBooks(event: MouseEvent) {
    event.preventDefault()

    const queryParams = new URLSearchParams()
    queryParams.append('book_title', this.booksForm.title)
    queryParams.append('author_name', this.booksForm.author)
    queryParams.append('role', this.booksForm.role)
    this.$message(`Seaching Books...`)

    this.loadBooks(queryParams)
    return true
  }

  private booksPageChange(page = 1) {
    const queryParams = new URLSearchParams()
    queryParams.append('book_title', this.booksForm.title)
    queryParams.append('author_name', this.booksForm.author)
    queryParams.append('role', this.booksForm.role)
    queryParams.append('page', page.toString())

    this.loadBooks(queryParams)
  }

  private loadBooks(queryParams: URLSearchParams) {
    const getData = {
      url: `/aozora/books.json?${queryParams.toString()}`,
      method: 'get',
    }

    this.booksForm.onloadFlg = true
    request(getData).then(res => {
      const { data } = res
      this.books = data.books.map((b: { authors: any[] }) => {
        const authorNames = b.authors.map(a => a.full_name).join(', ')
        return { ...b, authorNames }
      })

      this.booksForm.bookNum = data.total_count
      this.booksForm.limitPerPage = data.limit_per_page
      this.booksForm.onloadFlg = false
    }).catch(err => {
      console.error(err)
      this.booksForm.onloadFlg = false
    })
  }

  private bookInfo = [] as {[key: string]: any}[]
  private bookAuthors = [] as {[key: string]: any}[]
  private dialogVisible = false

  private getBookInfo(rowId: number) {
    const getData = {
      url: `/aozora/${rowId}/show_book.json`,
      method: 'get',
    }
    request(getData).then(res => {
      const { data } = res
      const labels = [
        'title', 'title_yomi', 'subtitle', 'subtitle_yomi',
        'book_uid', 'copyright',
      ]
      this.bookInfo = labels.map(label => {
        return { label, val: data[label] }
      })

      const urlLabels = ['card_url', 'html_url', 'text_url', 'wiki_url']
      urlLabels.forEach(label => {
        const urlRow = { label, url: data[label], val: `Open ${label}` }
        if (!data[label]) {
          urlRow.val = ''
        }
        this.bookInfo.push(urlRow)
      })

      this.bookAuthors = data.authors

      this.dialogVisible = true
    }).catch(err => {
      console.error(err)
    })
  }

  private openUrl(url: string) {
    return window.open(url)
  }

  mounted() {}
}
</script>

<style lang="scss">
@media (max-width: 800px) {
  .book-info {
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
