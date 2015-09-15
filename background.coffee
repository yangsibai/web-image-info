if typeof localStorage['enable'] is 'undefined'
    localStorage['enable'] = true
enable = JSON.parse(localStorage['enable'])

_toggle = (_enable)->
    if _enable
        chrome.browserAction.setIcon
            path: 'icons/48.png'
        chrome.browserAction.setTitle
            title: 'Image Info - running'
    else
        chrome.browserAction.setIcon
            path: 'icons/48_disable.png'
        chrome.browserAction.setTitle
            title: 'disabled (click to enable)'

_toggle(enable)

chrome.browserAction.onClicked.addListener (tab)->
    enable = not enable
    localStorage['enable'] = enable
    chrome.tabs.sendMessage(tab.id, enable)
    _toggle(enable)

chrome.runtime.onMessage.addListener (request, sender, sendMessage)->
    sendMessage enable