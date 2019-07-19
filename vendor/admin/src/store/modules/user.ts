import { VuexModule, Module, MutationAction, Mutation, Action, getModule } from 'vuex-module-decorators'
import { login, logout, getUserInfo } from '@/api/login'
import { getToken, setToken, removeToken } from '@/utils/auth'
import store from '@/store'
import {
  appConfigs, getAppConfig,
  initEmptyAppConfigs,
} from '@/api/config.ts'

export interface IUserState {
  token: string
  userId: null | number
  name: string
  avatar: string
  roles: string[]
  appConfigs: appConfigs
}

@Module({ dynamic: true, store, name: 'user' })
class User extends VuexModule implements IUserState {
  public token = getToken() || ''
  public userId: null | number = null
  public name = ''
  public avatar = ''
  public roles = []
  public appConfigs = initEmptyAppConfigs()

  @Action({ commit: 'SET_TOKEN' })
  public async Login(userInfo: { username: string, password: string}) {
    const username = userInfo.username.trim()
    const { data, headers } = await login(username, userInfo.password)

    return headers['authorization']
  }

  @Action({ commit: 'SET_TOKEN' })
  public RefreshToken(token?: string) {
    if (!token) {
      token = getToken()
    }
    return token || ''
  }

  @Action({ commit: 'SET_TOKEN' })
  public async FedLogOut() {
    removeToken()
    return ''
  }

  @MutationAction({ mutate: ['roles', 'userId', 'name', 'avatar'] })
  public async GetUserInfo() {
    const token = getToken()
    if (token === undefined) {
      throw Error('GetUserInfo: token is undefined!')
    }
    const { data } = await getUserInfo(token)
    if (data.roles && data.roles.length > 0) {
      return {
        userId: data.userId,
        roles: data.roles,
        name: data.name,
        avatar: data.avatar,
      }
    } else {
      throw Error('GetUserInfo: roles must be a non-null array!')
    }
  }

  @MutationAction({ mutate: ['appConfigs'] })
  public async UpdateAppConfigs(appConfigs?: appConfigs) {
    if (!appConfigs) {
      appConfigs = await getAppConfig()
    }
    return { appConfigs }
  }

  @MutationAction({ mutate: ['token', 'roles'] })
  public async LogOut() {
    if (getToken() === undefined) {
      throw Error('LogOut: token is undefined!')
    }
    await logout()
    removeToken()
    return {
      token: '',
      roles: [],
    }
  }

  @Mutation
  private SET_TOKEN(token: string) {
    this.token = token
  }
}

export const UserModule = getModule(User)
