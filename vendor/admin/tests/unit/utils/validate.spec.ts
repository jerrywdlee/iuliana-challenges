import { isValidUsername, isExternal } from '@/utils/validate'

describe('Utils:validate', () => {
  it('isValidUsername', () => {
    expect(isValidUsername('admin@example.com')).toBe(true)
    expect(isValidUsername('editor@example.com')).toBe(true)
    expect(isValidUsername('xxxx')).toBe(false)
  })

  it('isExternal', () => {
    expect(isExternal('https://www.armour.com/')).toBe(true)
    expect(isExternal('mailto:someone@test.com')).toBe(true)
    expect(isExternal('123aBC')).toBe(false)
  })
})
