config =
  STORAGE_NAMES: ['page']
  CONTEXTMENU_TEXT: 'Hotchkiss で留める'
  TAB_QUERY: {active: true, currentWindow: true}
  BADGE_ACT_COLOR: '#ff6d78'
  BADGE_PAS_COLOR: '#bcb0b1'


f =
  getNowTabs: (callback) ->
    chrome.tabs.query config.TAB_QUERY, callback

  getPages: (callback) ->
    chrome.storage.local.get config.STORAGE_NAMES, callback

  setStorage: (save, callback) ->
    chrome.storage.local.set save, callback

  setBadge: (pageSize) ->
    do (ba = chrome.browserAction) ->
      ba.setBadgeText {text: '' + pageSize}
      if pageSize is 0
        ba.setBadgeBackgroundColor {color: config.BADGE_PAS_COLOR}
      else
        ba.setBadgeBackgroundColor {color: config.BADGE_ACT_COLOR}

  useHotchkiss: (info, tab) ->
    nowPage =
      faviconUrl: tab.favIconUrl
      title: tab.title
      url: tab.url
      domain: tab.url.match(/\/\/([^\/]+)/)[1]

    f.getPages (response) ->
      newPage = do (o = response.page) ->
        o = o || []
        o = o.matchUrlRemove tab.url
        o.unshift nowPage
        f.setBadge o.length
        { page: o }

      f.setStorage newPage, ->


Array::matchUrlRemove = (tabUrl) ->
  @filter (page) ->
    if tabUrl isnt page.url then true


do ->
  initBadge = null


  f.getPages (response) -> initBadge = if response.page? and response.page.length > 0 then response.page.length else 0

  setTimeout ->
    f.setBadge initBadge
  , 1000


chrome.contextMenus.create
  title: config.CONTEXTMENU_TEXT
  onclick: f.useHotchkiss


chrome.commands.onCommand.addListener (command) ->
  switch command
    when 'go-to-next'
      f.getNowTabs (tabs) ->
        nowUrl = tabs[0].url

        f.getPages (respons) ->
          do (o = respons.page) ->
            pageSize = o.length

            if pageSize > 0
              urls = o.map (page) -> page.url
              urlIdx = urls.indexOf nowUrl
              isLast = pageSize is urlIdx + 1
              removalIdxs = [0]

              next = do ->

                if urlIdx > -1

                  if not isLast
                    removalIdxs = [urlIdx+1, urlIdx] # 大きい方から削除
                  else
                    removalIdxs.unshift urlIdx

                  {url: o[if isLast then urlIdx else urlIdx+1].url}
                else
                  {url: o[0].url}

              chrome.tabs.update next, (tab) ->
                removalIdxs.forEach (idx) ->
                  o.splice idx, 1

                f.setStorage {page: o}, ->
                f.setBadge o.length
