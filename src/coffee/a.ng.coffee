hk = angular.module 'hk', []

hk
.directive 'hkList', ($timeout) ->
  replace: true
  restrict: 'E'
  template: ->
    """
    <a class="app-a" ng-click="openPage(page.url)">
      <div class="app-title" ng-bind="page.title"></div>
      <div class="app-aside">
        <img class="app-favicon" ng-src="{{page.faviconUrl}}">
        <span class="app-url" ng-bind="page.domain"></span>
        <span class="app-split"></span>
        <div class="app-delete" title="このページを削除" ng-click="deletePage($event, $index)">
          <div class="i-delete-component"></div>
          <div class="i-delete-component"></div>
        </div>
      </div>
    </a>
    """
  link: (scope, el) ->
    $timeout ->
      parentH = el[0].parentNode
      parentH.style.height = "#{parentH.clientHeight}px"
    , 200

    scope.openPage = (url) ->
      chrome.tabs.create {url: url}, ->

.controller 'HkCtrl', ($scope, $q) ->
  getPage = ->
    deferred = $q.defer()
    chrome.storage.local.get ['page'], (response) ->
      deferred.resolve response.page
    deferred.promise

  # 実際に削除を行う
  subPages = null

  $scope.pages = null
  getPage().then (pages) ->
    subPages = pages
    $scope.pages = angular.copy pages

  $scope.removalIdxs = []
  $scope.deletePage = (e, idx) ->
    e.stopPropagation()

    $scope.removalIdxs.push idx
    subPages.splice idx, 1

    setTimeout ->
      do (ba = chrome.browserAction) ->
        ba.setBadgeText {text: "#{subPages.length}"}
        if subPages.length is 0
          ba.setBadgeBackgroundColor {color: '#bcb0b1'}
        chrome.pages.splice idx, 1
    , 700

    chrome.storage.local.set {page: subPages}, ->
