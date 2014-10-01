(function() {
  describe('Test', function() {
    return it('Array::matchUrlRemoveはFunctoin', function() {
      return expect(Array.prototype.matchUrlRemove).toEqual(jasmine.any(Function));
    });
  });

  describe('ドメイン抽出', function() {
    var matchUrlA, reR, urlS;
    reR = /\/\/([^\/]+)/;
    urlS = 'http://example.com/hogehoge/fugafuga';
    matchUrlA = urlS.match(reR);
    it('http://...が\/\\/\\/([^\\/]+)/にマッチ', function() {
      return expect(urlS).toMatch(reR);
    });
    it('httpでもhttpsでも結果は同じ', function() {
      var httpsS, matchHttpsA;
      httpsS = 'https://example.com/hogehoge/fugafuga';
      matchHttpsA = httpsS.match(reR);
      return expect(matchUrlA).toEqual(matchHttpsA);
    });
    it('マッチ配列に`example.com`を含む', function() {
      return expect(matchUrlA).toContain('example.com');
    });
    it('配列サイズは2', function() {
      return expect(matchUrlA.length).toEqual(2);
    });
    return it('配列の２番目は`example.com`', function() {
      return expect(matchUrlA[1]).toEqual('example.com');
    });
  });

  describe('コマンド発火時の処理', function() {
    var func, removalIdxs, urls;
    removalIdxs = [0];
    urls = null;
    func = null;
    beforeEach(function() {
      urls = ['http://hoge.com', 'http://fuga.com', 'http://piyo.com'];
      return func = function(urlIdxNum) {
        if (urlIdxNum > -1) {
          if (urlIdxNum !== urls.length - 1) {
            removalIdxs = [urlIdxNum + 1, urlIdxNum];
          } else {
            removalIdxs.unshift(urlIdxNum);
          }
        }
        return removalIdxs;
      };
    });
    afterEach(function() {
      return removalIdxs = [0];
    });
    it('最初の要素ならremovalIdxsは`[0, 1]`', function() {
      var matchableUrl, resultIdxs;
      matchableUrl = 'http://hoge.com';
      resultIdxs = func(urls.indexOf(matchableUrl));
      expect(resultIdxs.length).toBe(2);
      expect(resultIdxs[0]).toBe(1);
      return expect(resultIdxs[1]).toBe(0);
    });
    it('最後の要素ならremovalIdxsは`[2, 0]`', function() {
      var matchableUrl, resultIdxs;
      matchableUrl = 'http://piyo.com';
      resultIdxs = func(urls.indexOf(matchableUrl));
      expect(resultIdxs.length).toBe(2);
      expect(resultIdxs[0]).toBe(2);
      return expect(resultIdxs[1]).toBe(0);
    });
    return it('当てはまらない要素ならremovalIdxsは`[0]`', function() {
      var matchableUrl, resultIdxs;
      matchableUrl = 'http://foo.com';
      resultIdxs = func(urls.indexOf(matchableUrl));
      expect(resultIdxs.length).toBe(1);
      return expect(resultIdxs[0]).toBe(0);
    });
  });

  describe('Angular', function() {
    beforeEach(angular.mock.module('hk'));
    describe('HkCtrl', function() {
      var controller, scope;
      scope = null;
      controller = null;
      beforeEach(angular.mock.inject(function($rootScope, $controller) {
        scope = $rootScope.$new();
        return controller = $controller('HkCtrl', {
          '$scope': scope
        });
      }));
      return it('初期$scope.pages', function() {
        return expect(scope.pages).toBe(null);
      });
    });
    return describe('hkList directive', function() {
      var elH, scope;
      elH = null;
      scope = null;
      beforeEach(angular.mock.inject(function($rootScope, $compile) {
        scope = $rootScope.$new();
        elH = angular.element('<hk-list></hk-list>');
        elH = $compile(elH)(scope);
        return scope.$digest();
      }));
      it('削除ボタンができてる', function() {
        var delH;
        delH = elH.children().children()[3];
        return expect(angular.element(delH).hasClass('app-delete')).toBe(true);
      });
      return it('openPage チェック', function() {
        expect(scope.openPage).toEqual(jasmine.any(Function));
        return spyOn(scope, 'openPage');
      });
    });
  });

}).call(this);
