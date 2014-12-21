$(document).ready ->
    $("img").mouseenter ->
        src = $(this).attr("src")
        $.ajax
            type: "GET"
            url: src
            success: (data, textStatus, request)->
                length = request.getResponseHeader("Content-Length")
                $("<img/>").attr("src", src).load ->
                    showSize(src, @width, @height, length)

    $("img").mouseleave ->
        $("#web-image-info").remove()

showSize = (src, width, height, length)->
    sizeInfo = width + "x" + height
    info = sizeInfo + "&nbsp;&nbsp;" + (length / 1024).toFixed(2) + "k"
    if $("#web-image-info").length > 0
        $("#web-image-info").html(info)
    else
        $("body").append("<div id=\"web-image-info\">" + info + "</div>")
