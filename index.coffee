$imageInfo = $("<div id=\"web-image-info\"></div>")
$("body").append($imageInfo)

_currentSrc = ""
_canLoad = true
_db = {}
_currentInfo = ''

###
    detect is mouse on top left side
###
isTopLeft = (e)-> e.clientX < 300 and e.clientY < 300

###
    hide image info
###
hideImageInfo = ->
    _currentInfo = ''
    $imageInfo.hide()

###
    show image info
###
showImageInfo = (data, showAtRightSide)->
    _db[data.src] = data
    sizeInfo = data.width + "x" + data.height
    if data.length > 0
        info = sizeInfo + "  " + (data.length / 1024).toFixed(2) + "k"
    else
        info = sizeInfo

    if info isnt _currentInfo
        _currentInfo = info
        $imageInfo.text(info).show()
    if showAtRightSide
        $imageInfo.addClass('web-image-info-right')
    else
        $imageInfo.removeClass('web-image-info-right')

###
    enable or disable notify
###
showImageInfoEnable = false
_handleBackgroundNotify = (enable)->
    unless enable
        hideImageInfo()
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

_handleMove = (e)->
    if e.target.nodeName isnt "IMG"
        _currentInfo = ''
        hideImageInfo()
    else if _canLoad and e.target.src
        width = e.target.naturalWidth
        height = e.target.naturalHeight
        if _db[e.target.src]
            showImageInfo(_db[e.target.src], isTopLeft(e))
        else
            _canLoad = false
            _currentSrc = e.target.src
            $.ajax
                type: "HEAD"
                url: _currentSrc
                success: (data, textStatus, request)->
                    _canLoad = true
                    length = ~~request.getResponseHeader("Content-Length")
                    showImageInfo
                        src: _currentSrc
                        width: width
                        height: height
                        length: length
                    , isTopLeft(e)
                error: (e)->
                    _canLoad = true
                    showImageInfo
                        src: _currentSrc
                        width: width
                        height: height
                        length: 0
                    , isTopLeft(e)
