#!/bin/sh
# Copyright © 2013-2017 Wifimedia.
. /sbin/wifimedia/adslib.sh

img1(){
##Img && Title
echo '
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link1'", "'$img1'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}

img2(){
##Img && Title
echo '
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link2'", "'$img2'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}

img3(){
##Img && Title
echo '
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link3'", "'$img3'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}

img4(){
##Img && Title
echo '
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link4'", "'$img4'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}

img5(){
##Img && Title
echo '
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link5'", "'$img5'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}
