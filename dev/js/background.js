(function() {
  var config, f;

  config = {
    STORAGE_NAMES: ['page'],
    CONTEXTMENU_TEXT: 'Hotchkiss で留める',
    TAB_QUERY: {
      active: true,
      currentWindow: true
    },
    BADGE_ACT_COLOR: '#ff6d78',
    BADGE_PAS_COLOR: '#bcb0b1'
  };

  f = {
    getNowTabs: function(callback) {
      return chrome.tabs.query(config.TAB_QUERY, callback);
    },
    getPages: function(callback) {
      return chrome.storage.local.get(config.STORAGE_NAMES, callback);
    },
    setStorage: function(save, callback) {
      return chrome.storage.local.set(save, callback);
    },
    setBadge: function(pageSize) {
      return (function(ba) {
        ba.setBadgeText({
          text: '' + pageSize
        });
        if (pageSize === 0) {
          return ba.setBadgeBackgroundColor({
            color: config.BADGE_PAS_COLOR
          });
        } else {
          return ba.setBadgeBackgroundColor({
            color: config.BADGE_ACT_COLOR
          });
        }
      })(chrome.browserAction);
    },
    useHotchkiss: function(info, tab) {
      var nowPage;
      nowPage = {
        faviconUrl: tab.favIconUrl,
        title: tab.title,
        url: tab.url,
        domain: tab.url.match(/\/\/([^\/]+)/)[1]
      };
      return f.getPages(function(response) {
        var newPage;
        newPage = (function(o) {
          o = o || [];
          o = o.matchUrlRemove(tab.url);
          o.unshift(nowPage);
          f.setBadge(o.length);
          return {
            page: o
          };
        })(response.page);
        return f.setStorage(newPage, function() {});
      });
    }
  };

  Array.prototype.matchUrlRemove = function(tabUrl) {
    return this.filter(function(page) {
      if (tabUrl !== page.url) {
        return true;
      }
    });
  };

  (function() {
    var initBadge;
    initBadge = null;
    f.getPages(function(response) {
      return initBadge = (response.page != null) && response.page.length > 0 ? response.page.length : 0;
    });
    return setTimeout(function() {
      return f.setBadge(initBadge);
    }, 1000);
  })();

  chrome.contextMenus.create({
    title: config.CONTEXTMENU_TEXT,
    onclick: f.useHotchkiss
  });

  chrome.commands.onCommand.addListener(function(command) {
    switch (command) {
      case 'go-to-next':
        return f.getNowTabs(function(tabs) {
          var nowUrl;
          nowUrl = tabs[0].url;
          return f.getPages(function(respons) {
            return (function(o) {
              var isLast, next, pageSize, removalIdxs, urlIdx, urls;
              pageSize = o.length;
              if (pageSize > 0) {
                urls = o.map(function(page) {
                  return page.url;
                });
                urlIdx = urls.indexOf(nowUrl);
                isLast = pageSize === urlIdx + 1;
                removalIdxs = [0];
                next = (function() {
                  if (urlIdx > -1) {
                    if (!isLast) {
                      removalIdxs = [urlIdx + 1, urlIdx];
                    } else {
                      removalIdxs.unshift(urlIdx);
                    }
                    return {
                      url: o[isLast ? urlIdx : urlIdx + 1].url
                    };
                  } else {
                    return {
                      url: o[0].url
                    };
                  }
                })();
                return chrome.tabs.update(next, function(tab) {
                  removalIdxs.forEach(function(idx) {
                    return o.splice(idx, 1);
                  });
                  f.setStorage({
                    page: o
                  }, function() {});
                  return f.setBadge(o.length);
                });
              }
            })(respons.page);
          });
        });
    }
  });

}).call(this);
