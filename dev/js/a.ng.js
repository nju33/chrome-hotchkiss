(function() {
  var hk;

  hk = angular.module('hk', []);

  hk.directive('hkList', function($timeout) {
    return {
      replace: true,
      restrict: 'E',
      template: function() {
        return "<a class=\"app-a\" ng-click=\"openPage(page.url)\">\n  <div class=\"app-title\" ng-bind=\"page.title\"></div>\n  <div class=\"app-aside\">\n    <img class=\"app-favicon\" ng-src=\"{{page.faviconUrl}}\">\n    <span class=\"app-url\" ng-bind=\"page.domain\"></span>\n    <span class=\"app-split\"></span>\n    <div class=\"app-delete\" title=\"このページを削除\" ng-click=\"deletePage($event, $index)\">\n      <div class=\"i-delete-component\"></div>\n      <div class=\"i-delete-component\"></div>\n    </div>\n  </div>\n</a>";
      },
      link: function(scope, el) {
        $timeout(function() {
          var parentH;
          parentH = el[0].parentNode;
          return parentH.style.height = "" + parentH.clientHeight + "px";
        }, 200);
        return scope.openPage = function(url) {
          return chrome.tabs.create({
            url: url
          }, function() {});
        };
      }
    };
  }).controller('HkCtrl', function($scope, $q) {
    var getPage, subPages;
    getPage = function() {
      var deferred;
      deferred = $q.defer();
      chrome.storage.local.get(['page'], function(response) {
        return deferred.resolve(response.page);
      });
      return deferred.promise;
    };
    subPages = null;
    $scope.pages = null;
    getPage().then(function(pages) {
      subPages = pages;
      return $scope.pages = angular.copy(pages);
    });
    $scope.removalIdxs = [];
    return $scope.deletePage = function(e, idx) {
      e.stopPropagation();
      $scope.removalIdxs.push(idx);
      subPages.splice(idx, 1);
      setTimeout(function() {
        return (function(ba) {
          ba.setBadgeText({
            text: "" + subPages.length
          });
          if (subPages.length === 0) {
            return ba.setBadgeBackgroundColor({
              color: '#bcb0b1'
            });
          }
        })(chrome.browserAction);
      }, 700);
      return chrome.storage.local.set({
        page: subPages
      }, function() {});
    };
  });

}).call(this);
