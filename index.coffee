_enableHandler = true

$(document).ready ->
    $(document).mousemove (e)->
        if _enableHandler
            _handleMove(e)
            _enableHandler = false

setInterval ->
    _enableHandler = true
, 100

_currentSrc = ""
_canLoad = true
_db = {}
_handleMove = (e)->
    if e.target.nodeName isnt "IMG"
        $("#web-image-info").hide()
    else if _canLoad and e.target.src
        if _db[e.target.src]
            showSize(_db[e.target.src])
        else
            _canLoad = false
            _currentSrc = e.target.src
            $.ajax
                type: "GET"
                url: _currentSrc
                success: (data, textStatus, request)->
                    length = request.getResponseHeader("Content-Length")
                    $("<img/>").attr("src", _currentSrc).load ->
                        _canLoad = true
                        showSize
                            src: e.target.src
                            width: @width
                            height: @height
                            length: length

showSize = (data)->
    _db[data.src] = data
    sizeInfo = data.width + "x" + data.height
    info = sizeInfo + "&nbsp;&nbsp;" + (data.length / 1024).toFixed(2) + "k"
    if $("#web-image-info").length > 0
        $("#web-image-info").html(info).show()
    else
        $("body").append("<div id=\"web-image-info\">" + info + "</div>")
