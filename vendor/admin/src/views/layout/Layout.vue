<template lang="pug">
  .app-wrapper(:class='classObj')
    .drawer-bg(v-if='classObj.mobile && sidebar.opened', @click='handleClickOutside')
    sidebar.sidebar-container(:collapse='classObj.hideSidebar')
    .main-container
      navbar
      app-main
</template>

<script lang="ts">
import { Navbar, AppMain, Sidebar } from './components'
import ResizeMixin from './mixin/ResizeHandler'
import { Component } from 'vue-property-decorator'
import { mixins } from 'vue-class-component'
import { DeviceType, AppModule } from '@/store/modules/app'

@Component({
  components: {
    Navbar,
    Sidebar,
    AppMain,
  },
})
export default class Layout extends mixins(ResizeMixin) {
  get classObj() {
    return {
      hideSidebar: !this.sidebar.opened,
      openSidebar: this.sidebar.opened,
      withoutAnimation: this.sidebar.withoutAnimation,
      mobile: this.device === DeviceType.Mobile,
    }
  }

  private handleClickOutside() {
    AppModule.CloseSideBar(false)
  }
}
</script>

<style lang="scss" scoped>
  @import "src/styles/mixin.scss";
  @import "src/styles/variables.scss";

  .app-wrapper {
    @include clearfix;
    position: relative;
    height: 100%;
    width: 100%;
  }

  .drawer-bg {
    background: #000;
    opacity: 0.3;
    width: 100%;
    top: 0;
    height: 100%;
    position: absolute;
    z-index: 999;
  }

  .main-container {
    min-height: 100%;
    transition: margin-left .28s;
    margin-left: $sideBarWidth;
    position: relative;
  }

  .sidebar-container {
    transition: width 0.28s;
    width: $sideBarWidth !important;
    height: 100%;
    position: fixed;
    font-size: 0px;
    top: 0;
    bottom: 0;
    left: 0;
    z-index: 1001;
    overflow: hidden;
  }

  .hideSidebar {
    .main-container {
      margin-left: 36px;
    }

    .sidebar-container {
      width: 36px !important;
    }
  }

  /* for mobile response */
  .mobile {
    .main-container {
      margin-left: 0px;
    }

    .sidebar-container {
      transition: transform .28s;
      width: $sideBarWidth !important;
    }

    &.openSidebar {
      position: fixed;
      top: 0;
    }

    &.hideSidebar {
      .sidebar-container {
        transition-duration: 0.3s;
        transform: translate3d(-$sideBarWidth, 0, 0);
      }
    }
  }

  .withoutAnimation {
    .main-container,
    .sidebar-container {
      transition: none;
    }
  }
</style>
