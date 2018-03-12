function uiWebview_setcssHighlight() {
    var css = document.createElement('link');
    css.href="founderEpub.css";
    css.rel="stylesheet";
    css.type="text/css";
    document.getElementsByTagName('head')[0].appendChild(css);
    setFontSize(1);
    //document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '160%%';
}

uiWebview_setcssHighlight();
