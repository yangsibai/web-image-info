if (typeof localStorage['enable'] === 'undefined') {
  localStorage['enable'] = true;
}

let enable = JSON.parse(localStorage['enable']);

const _toggle = function(_enable) {
  if (_enable) {
    chrome.browserAction.setIcon({
      path: 'icons/48.png',
    });
    return chrome.browserAction.setTitle({
      title: 'Image Info - running',
    });
  } else {
    chrome.browserAction.setIcon({
      path: 'icons/48_disable.png',
    });
    return chrome.browserAction.setTitle({
      title: 'disabled (click to enable)',
    });
  }
};

_toggle(enable);

chrome.browserAction.onClicked.addListener(function() {
  enable = !enable;
  localStorage['enable'] = enable;
  chrome.tabs.query({}, function(tabs) {
    var i, len, results, tab;
    results = [];
    for (i = 0, len = tabs.length; i < len; i++) {
      tab = tabs[i];
      results.push(chrome.tabs.sendMessage(tab.id, enable));
    }
    return results;
  });
  return _toggle(enable);
});

chrome.runtime.onMessage.addListener(function(request, sender, sendMessage) {
  return sendMessage(enable);
});
