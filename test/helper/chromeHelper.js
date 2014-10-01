(function() {
  window.chrome = {
    storage: {
      local: {
        get: function() {},
        set: function() {}
      }
    },
    tabs: {
      query: function() {},
      update: function() {}
    },
    browserAction: {
      setBadgeText: function() {},
      setBadgeBackgroundColor: function() {},
      setIcon: function() {}
    },
    contextMenus: {
      create: function() {}
    },
    commands: {
      onCommand: {
        addListener: function() {}
      }
    }
  };

}).call(this);
