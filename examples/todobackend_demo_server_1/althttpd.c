<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<base href="https://sqlite.org/althttpd/file">
<meta http-equiv="Content-Security-Policy" content="default-src 'self' data:; script-src 'self' 'nonce-fc0c3ebe6d797a775b04315ae155d2b11184230cb822ceff'; style-src 'self' 'unsafe-inline'; img-src * data:">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Althttpd: Browser Verification</title>
<link rel="alternate" type="application/rss+xml" title="RSS Feed"  href="/althttpd/timeline.rss">
<link rel="stylesheet" href="/althttpd/style.css?id=a2fe8e47" type="text/css">
</head>
<body class="file rpage-file cpage-file">
<header>
  <div class="title"><h1>Althttpd</h1>Browser Verification</div>
  <div class="status">
    <a href='/althttpd/login'>Login</a>

  </div>
</header>
<nav class="mainmenu" title="Main Menu">
  <a id='hbbtn' href='/althttpd/sitemap' aria-label='Site Map'>&#9776;</a><a href='/althttpd/home' class=''>Home</a>
<a href='/althttpd/timeline' class=''>Timeline</a>
<a href='/althttpd/forum' class=''>Forum</a>

</nav>
<nav id="hbdrop" class='hbdrop' title="sitemap"></nav>
<div class="content"><span id="debugMsg"></span>
<h1 id="x1">Checking to see if you are a robot<span id="x2"></span></h1>
<form method="GET" id="x6"><p>
<span id="x3" style="visibility:hidden;">Press <input type="submit" id="x5" value="Ok" focus> to continue</span>
<span id="x7" style="visibility:hidden;">You appear to be a robot.</span></p>
<input type="hidden" name="raw" value="1">
<input id="x4" type="hidden" name="proof" value="0">
</form>
<script nonce='fc0c3ebe6d797a775b04315ae155d2b11184230cb822ceff'>
function aaa(x){return document.getElementById(x);}function bbb(h,a){aaa("x4").value=h;if((a%75)==0){aaa("x2").textContent=aaa("x2").textContent+".";}var z;if(a>0){setTimeout(bbb,1,h+a,a-1);}else if((z=window.getComputedStyle(document.body).zIndex)==='0'||z===0){aaa("x3").style.visibility="visible";aaa("x2").textContent="";aaa("x1").textContent="All clear";aaa("x6").onsubmit=function(){aaa("x3").style.visibility="hidden";};aaa("x5").focus();}else{aaa("x7").style.visibility="visible";aaa("x2").textContent="";aaa("x3").style.display="none";aaa("x1").textContent="Access Denied";}}function ccc(a,b,c){return (a*863+b)*1055+c;}window.addEventListener('load',function(){bbb(ccc(803,293,689),589);},false);
window.addEventListener('pageshow',function(e){if(e.persisted)window.location.reload();});
</script>
</div>
<footer>
This page was generated in about
0.006s by
Fossil 2.28 [654fe05f4f] 2025-12-19 10:11:40
</footer>
<script nonce="fc0c3ebe6d797a775b04315ae155d2b11184230cb822ceff">/* style.c:903 */
function debugMsg(msg){
var n = document.getElementById("debugMsg");
if(n){n.textContent=msg;}
}
</script>
<script nonce='fc0c3ebe6d797a775b04315ae155d2b11184230cb822ceff'>
/* hbmenu.js *************************************************************/
(function() {
var hbButton = document.getElementById("hbbtn");
if (!hbButton) return;
if (!document.addEventListener) return;
var panel = document.getElementById("hbdrop");
if (!panel) return;
if (!panel.style) return;
var panelBorder = panel.style.border;
var panelInitialized = false;
var panelResetBorderTimerID = 0;
var animate = panel.style.transition !== null && (typeof(panel.style.transition) == "string");
var animMS = panel.getAttribute("data-anim-ms");
if (animMS) {
animMS = parseInt(animMS);
if (isNaN(animMS) || animMS == 0)
animate = false;
else if (animMS < 0)
animMS = 400;
}
else
animMS = 400;
var panelHeight;
function calculatePanelHeight() {
panel.style.maxHeight = '';
var es   = window.getComputedStyle(panel),
edis = es.display,
epos = es.position,
evis = es.visibility;
panel.style.visibility = 'hidden';
panel.style.position   = 'absolute';
panel.style.display    = 'block';
panelHeight = panel.offsetHeight + 'px';
panel.style.display    = edis;
panel.style.position   = epos;
panel.style.visibility = evis;
}
function showPanel() {
if (panelResetBorderTimerID) {
clearTimeout(panelResetBorderTimerID);
panelResetBorderTimerID = 0;
}
if (animate) {
if (!panelInitialized) {
panelInitialized = true;
calculatePanelHeight();
panel.style.transition = 'max-height ' + animMS +
'ms ease-in-out';
panel.style.overflowY  = 'hidden';
panel.style.maxHeight  = '0';
}
setTimeout(function() {
panel.style.maxHeight = panelHeight;
panel.style.border    = panelBorder;
}, 40);
}
panel.style.display = 'block';
document.addEventListener('keydown',panelKeydown,true);
document.addEventListener('click',panelClick,false);
}
var panelKeydown = function(event) {
var key = event.which || event.keyCode;
if (key == 27) {
event.stopPropagation();
panelToggle(true);
}
};
var panelClick = function(event) {
if (!panel.contains(event.target)) {
panelToggle(true);
}
};
function panelShowing() {
if (animate) {
return panel.style.maxHeight == panelHeight;
}
else {
return panel.style.display == 'block';
}
}
function hasChildren(element) {
var childElement = element.firstChild;
while (childElement) {
if (childElement.nodeType == 1)
return true;
childElement = childElement.nextSibling;
}
return false;
}
window.addEventListener('resize',function(event) {
panelInitialized = false;
},false);
hbButton.addEventListener('click',function(event) {
event.stopPropagation();
event.preventDefault();
panelToggle(false);
},false);
function panelToggle(suppressAnimation) {
if (panelShowing()) {
document.removeEventListener('keydown',panelKeydown,true);
document.removeEventListener('click',panelClick,false);
if (animate) {
if (suppressAnimation) {
var transition = panel.style.transition;
panel.style.transition = '';
panel.style.maxHeight = '0';
panel.style.border = 'none';
setTimeout(function() {
panel.style.transition = transition;
}, 40);
}
else {
panel.style.maxHeight = '0';
panelResetBorderTimerID = setTimeout(function() {
panel.style.border = 'none';
panelResetBorderTimerID = 0;
}, animMS);
}
}
else {
panel.style.display = 'none';
}
}
else {
if (!hasChildren(panel)) {
var xhr = new XMLHttpRequest();
xhr.onload = function() {
var doc = xhr.responseXML;
if (doc) {
var sm = doc.querySelector("ul#sitemap");
if (sm && xhr.status == 200) {
panel.innerHTML = sm.outerHTML;
showPanel();
}
}
}
var url = hbButton.href + (hbButton.href.includes("?")?"&popup":"?popup")
xhr.open("GET", url);
xhr.responseType = "document";
xhr.send();
}
else {
showPanel();
}
}
}
})();
</script>
</body>
</html>
