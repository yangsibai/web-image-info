const $imageInfo = $('<div id="web-image-info"></div>');
$('body').append($imageInfo);
$imageInfo.hide();

const _db = {};
let _currentSrc = '';
let _canLoad = true;
let _currentInfo = '';

/**
 * hide image info
 */
const hideImageInfo = () => {
  _currentInfo = '';
  $imageInfo.hide();
};

/**
 * show image info
 */
const showImageInfo = data => {
  _db[data.src] = data;
  const sizeInfo = data.width + 'x' + data.height;
  let info = '';
  if (data.length > 0) {
    info = sizeInfo + '  ' + (data.length / 1024).toFixed(2) + 'k';
  } else {
    info = sizeInfo;
  }

  if (info !== _currentInfo) {
    _currentInfo = info;
    $imageInfo.text(info).show();
  }
};

/**
 * enable or disable notify
 */
let showImageInfoEnable = false;

const _handleBackgroundNotify = enable => {
  if (!enable) {
    hideImageInfo();
  }
  showImageInfoEnable = enable;
};

chrome.runtime.sendMessage(
  {
    cmd: 'check enable',
  },
  _handleBackgroundNotify,
);

chrome.runtime.onMessage.addListener(_handleBackgroundNotify);

let _enableHandler = true;

$(document).ready(() => {
  $(document).mousemove(e => {
    if (!showImageInfoEnable) {
      return;
    }
    if (_enableHandler) {
      _handleMove(e);
      _enableHandler = false;
    }
  });
});

setInterval(() => {
  _enableHandler = true;
}, 100);

function getFileSizeOfURL(url, cb) {
  const iTime = performance.getEntriesByName(url)[0];
  if (iTime && iTime.transferSize) {
    cb(null, iTime.transferSize);
  }
  $.ajax({
    type: 'HEAD',
    url,
    success: (data, textStatus, request) => {
      const length = parseInt(request.getResponseHeader('Content-Length'), 10);
      cb(null, length);
    },
    error: e => {
      cb(e);
    },
  });
}

function showImageInfoOfURL(dimensions, url) {
  if (_db[url]) {
    showImageInfo(_db[url]);
    return;
  }
  getFileSizeOfURL(url, (err, length) => {
    const size = err ? 0 : length;
    showImageInfo({
      src: url,
      width: dimensions.width,
      height: dimensions.height,
      length: size,
    });
  });
}

const _handleMove = e => {
  const node = e.target;
  if (node.nodeName === 'IMG' && node.src) {
    showImageInfoOfURL(
      {
        width: node.naturalWidth,
        height: node.naturalHeight,
      },
      node.src,
    );
    return;
  }
  const style = window.getComputedStyle(node);
  bg = style.backgroundImage;
  if (bg.startsWith('url')) {
    bgURL = bg.substring(5, bg.length - 2);
    const img = document.createElement('img');
    img.src = bgURL;
    img.onload = function() {
      showImageInfoOfURL(
        {
          width: this.width,
          height: this.height,
        },
        bgURL,
      );
    };
    return;
  }
  hideImageInfo();
};
