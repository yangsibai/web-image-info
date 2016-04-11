showImageInfoEnable = false

_handleBackgroundNotify = (enable)->
    unless enable
        $("#web-image-info").remove()
    showImageInfoEnable = enable


chrome.runtime.sendMessage
    cmd: 'check enable'
, _handleBackgroundNotify

chrome.runtime.onMessage.addListener _handleBackgroundNotify

_enableHandler = true

$(document).ready ->
    $(document).mousemove (e)->
        return unless showImageInfoEnable
        if _enableHandler
            _handleMove(e)
            _enableHandler = false

setInterval ->
    _enableHandler = true
, 100

_currentSrc = ""
_canLoad = true
_db = {}
_currentInfo = ''
_handleMove = (e)->
    if e.target.nodeName isnt "IMG"
        _currentInfo = ''
        $("#web-image-info").hide()
    else if _canLoad and e.target.src
        width = e.target.naturalWidth
        height = e.target.naturalHeight
        if _db[e.target.src]
            showSize(_db[e.target.src])
        else
            _canLoad = false
            _currentSrc = e.target.src
            $.ajax
                type: "HEAD"
                url: _currentSrc
                success: (data, textStatus, request)->
                    length = request.getResponseHeader("Content-Length")
                    $("<img/>").attr("src", _currentSrc).load ->
                        _canLoad = true
                        showSize
                            src: _currentSrc
                            width: width
                            height: height
                            length: length
                error: (e)->
                    $("<img/>").attr("src", _currentSrc).load ->
                        _canLoad = true
                        showSize
                            src: _currentSrc
                            width: width
                            height: height
                            length: 0

showSize = (data)->
    _db[data.src] = data
    sizeInfo = data.width + "x" + data.height
    if data.length > 0
        info = sizeInfo + "  " + (data.length / 1024).toFixed(2) + "k"
    else
        info = sizeInfo
    if $("#web-image-info").length > 0
        if info isnt _currentInfo
            _currentInfo = info
            $("#web-image-info").text(info).show()
    else
        $("body").append("<div id=\"web-image-info\">" + info + "</div>")
