describe 'Test', ->
  it 'Array::matchUrlRemoveはFunctoin', ->
    expect(Array::matchUrlRemove).toEqual jasmine.any Function

describe 'ドメイン抽出', ->
  reR = /\/\/([^\/]+)/
  urlS = 'http://example.com/hogehoge/fugafuga'
  matchUrlA = urlS.match reR

  it 'http://...が\/\\/\\/([^\\/]+)/にマッチ', ->
    expect(urlS).toMatch reR

  it 'httpでもhttpsでも結果は同じ', ->
    httpsS = 'https://example.com/hogehoge/fugafuga'
    matchHttpsA = httpsS.match reR

    expect(matchUrlA).toEqual matchHttpsA

  it 'マッチ配列に`example.com`を含む', ->
    expect(matchUrlA).toContain 'example.com'

  it '配列サイズは2', ->
    expect(matchUrlA.length).toEqual 2

  it '配列の２番目は`example.com`', ->
    expect(matchUrlA[1]).toEqual 'example.com'


describe 'コマンド発火時の処理', ->
  removalIdxs = [0]
  urls = null
  func = null

  beforeEach ->
    urls = ['http://hoge.com', 'http://fuga.com', 'http://piyo.com']

    func = (urlIdxNum) ->
      if urlIdxNum > -1

        if urlIdxNum isnt urls.length - 1
          removalIdxs = [urlIdxNum+1, urlIdxNum] # 大きい方から削除
        else
          removalIdxs.unshift urlIdxNum

      removalIdxs

  afterEach ->
    removalIdxs = [0]


  it '最初の要素ならremovalIdxsは`[0, 1]`', ->
    matchableUrl = 'http://hoge.com'

    resultIdxs = func urls.indexOf matchableUrl

    expect(resultIdxs.length).toBe 2
    expect(resultIdxs[0]).toBe 1
    expect(resultIdxs[1]).toBe 0


  it '最後の要素ならremovalIdxsは`[2, 0]`', ->
    matchableUrl = 'http://piyo.com'

    resultIdxs = func urls.indexOf matchableUrl

    expect(resultIdxs.length).toBe 2
    expect(resultIdxs[0]).toBe 2
    expect(resultIdxs[1]).toBe 0

  it '当てはまらない要素ならremovalIdxsは`[0]`', ->
    matchableUrl = 'http://foo.com'

    resultIdxs = func urls.indexOf matchableUrl

    expect(resultIdxs.length).toBe 1
    expect(resultIdxs[0]).toBe 0

describe 'Angular', ->
  beforeEach angular.mock.module 'hk'

  describe 'HkCtrl', ->
    scope = null
    controller = null

    beforeEach angular.mock.inject ($rootScope, $controller) ->
      scope = $rootScope.$new()
      controller = $controller 'HkCtrl', {'$scope': scope}

    it '初期$scope.pages', ->
      expect(scope.pages).toBe null

  describe 'hkList directive', ->
    elH = null
    scope = null

    beforeEach angular.mock.inject ($rootScope, $compile) ->
      scope = $rootScope.$new()

      elH = angular.element '<hk-list></hk-list>'

      elH = $compile(elH)(scope)
      scope.$digest()

    it '削除ボタンができてる', ->
      delH = elH.children().children()[3]

      expect(angular.element(delH).hasClass('app-delete')).toBe true

    it 'openPage チェック', ->
      expect(scope.openPage).toEqual jasmine.any Function

      spyOn scope, 'openPage'

      # console.log elH.children()[0].click
      # expect(scope.openPage).toHaveBeenCalled()

