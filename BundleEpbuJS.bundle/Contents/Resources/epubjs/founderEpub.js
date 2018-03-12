//--------------------------------------页面初始化开始-------------------------------------------------
//--------------------------------------追加公共样式开始------------------------------------------------
$('head').find('[name="viewport"]').remove();

$('<link />', {
	type: 'text/css',
	rel: 'stylesheet',
	href: 'founderEpub.css'
}).add('<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no" />').appendTo(document.head);

//--------------------------------------追加公共样式结束！！------------------------------------------------


//--------------------------布局转换和增加特殊标识（方便查到该元素追回列表显示块）开始-----------------------------
$(document.body).children().not('.marklist,.fnslist,.colorsdiv,script').add('p').add(':header').css('position', 'relative').attr('bodyChild', true);

//-------------------------- 布局转换和增加特殊标识（方便查到该元素追回列表显示块）结束！！-----------------------------


//---------------------------页面中追加【对话框\便签列表\功能列表\颜色选择】浮动窗口开始----------------------------
var aDynDivs = [$('<div class="marklist"><div class="markul"></div></div>'), $('<div class="fnslist">' +
	'<div class="colorsel"></div>' +
	'<div class="addnote"></div>' +
	'<div class="removehl"></div>' +
	'</div>'), $('<div class="colorsdiv">' +
	'<div class="red"><span></span></div>' +
	'<div class="pink"><span></span></div>' +
	'<div class="blue"><span></span></div>' +
	'<div class="green"><span></span></div>' +
	'<div class="yellow"><span></span></div>' +
	'<div class="gray"><span></span></div>' +
	'</div>')];

$(document.body).append(aDynDivs);
//------------------------页面中追加【对话框\便签列表\功能列表\颜色选择】浮动窗口结束！！----------------------------


//---------------------------------------------rangy初始化开始--------------------------------------------
//记忆选中的区域数组和当前选中的对象,项目中所有高亮颜色样式
var aSel = [],
	oCur = null,
	htColor = "highlight",
	aCls = ["green1", "red1", "blue1", "pink1", "yellow1", "gray1"];

//初始化
rangy.init();

var highlighter = rangy.createHighlighter(),
	currentHL = null;

highlighter.addClassApplier(rangy.createCssClassApplier("highlight", {
	ignoreWhiteSpace: true,
	elementTagName: "label",
	elementProperties: {
		href: "#",
		ontouchend: function(e) {
			oCur = e.target;
			currentHL = highlighter.getHighlightForElement(this);

		}
	}
}));
//---------------------------------------------rangy初始化结束！！--------------------------------------------
//--------------------------------------页面初始化结束-------------------------------------------------


//--------------------------------------隐藏其他div-------------------------------------------------
function hideOtherDiv(clsName) {
		if (clsName == 'all') {
			$('.marklist,.fnslist,.colorsdiv').fadeOut('slow');
		} else {
			$('.marklist,.fnslist,.colorsdiv').not(clsName).fadeOut('slow');
		}
	}
	//--------------------------------------隐藏其他div结束！！-------------------------------------------------

$("document").ready(function() {

	var anchor_id = window.location.hash;
//	alert(window.location.hash);
	if (anchor_id != "") {
		var new_position = $(anchor_id).offset();
		if (new_position.left > new_position.top) {
			new_position.top = 0;
		} else {
			new_position.left = 0;
		}

		console.log(new_position.left + 'body');
		var tempData = {
			"left": new_position.left,
			"top": new_position.top,
		};
		sendData({
			"type": "anchorRef",
			"content": encodeURIComponent(JSON.stringify(tempData))
		});
	}



	$("img").on("tap", function(event) {
		console.log(event.clientX + " highlight");
		var $this = $(this),
			pos = $this.offset();
		//如果图片有超链接则自动转到超链接，否则弹窗显示大图
		if ($this.closest('a').length == 0) {
			sendData({
				"type": "pictureref",
				"content": encodeURIComponent(JSON.stringify({
					"src": $this.attr('src'),
					"top": Math.round(pos.top),
					"left": Math.round(pos.left),
					"width": $this.width(),
					"height": $this.height()
				}))
			});
		}
		return false;
	});

$(document).ready(function(){
      
var ismoved = false;
$("body").on("touchmove", function(event) {
       ismoved = true;
       console.log("正在移动");
       });

$("body").on("touchend", function(event) {
       if (ismoved) {
       console.log("移动后的toucheEnd");
       ismoved = false;
       return;
       };
       
       console.log("正常的toucheEnd");
       console.log(event.originalEvent.changedTouches["0"].clientX+"/"+event.originalEvent.changedTouches["0"].clientY);
       //隐藏所有弹出控件
       hideOtherDiv('all');
       var tempData = {
       "left": event.originalEvent.changedTouches["0"].clientX,
       "top": event.originalEvent.changedTouches["0"].clientY,
       };
       
       sendData({
                "type": "tapWebRef",
                "content": encodeURIComponent(JSON.stringify(tempData))
                });
       });
      });

	//----------------------------------------移除高亮/修改颜色/增加便签功能按钮开始----------------------------------

	$(".colorsel").on("tap", function(event) {
		console.log(event.clientX + " colorsel");
		var w1 = $(document).width(),
			w2 = $('.colorsdiv').width(),
			disX = w2 - $('.fnslist').width(),
			l = $('.fnslist').offset().left - disX / 2,
			t = $('.fnslist').offset().top,
			maxL = w1 - w2 - 30;

		//以fnslist功能层定位，主要控制其右侧不偏离出画面
		l = l < 30 ? 30 : l > maxL ? maxL : l;

		$('.colorsdiv').css({
			left: l,
			top: t,
			display: 'block'
		});

		hideOtherDiv('.colorsdiv');
		return false;
	})

	$(".addnote").on("tap", function(event) {
		console.log(event.clientX + " addnote");
		//肯定是用户点击高亮后，所以这里不能调用addNote()，会多一步高亮
		//造成程序代码错乱！
		oCur = $('.current').get(0);
		showDialog($(oCur), "append");

		//区分无笔记高亮|有笔记高亮的参数
		$(oCur).data('hasMark', $(oCur).attr('mark') !== undefined);
		return false;
	})

	$(".removehl").on("tap", function(event) {
			console.log(event.clientX + " removehl");
			var $current = $('.current');
			delHtAndMark($current);

			hideOtherDiv('all');
			return false;
		})
		//----------------------------------------移除高亮/修改颜色/增加便签功能按钮结束----------------------------------

	//---------------------------------高亮颜色设置和选择颜色色块发光效果开始---------------------------------------
	$(".colorsdiv > div").on("tap", function(event) {
			console.log(event.clientX + " colorsdiv");
			var $this = $(this),
				clsName = $this.attr('class') + '1';

			//查看current是否有创建日期一样的元素
			$('[createtime="' + $('.current').attr('createtime') + '"]').removeClass(aCls.join(' ')).addClass(clsName);

			$('.colorsdiv').fadeOut('slow', function() {
				$this.children().removeClass('active');
			});

			htColor = clsName; //记忆刚才用户用到的高亮，下次高亮时应用此颜色

			//发送所有笔记和重点到app
			sendNotes();
			return false;
		})
		//------------------------------------------高亮颜色设置和选择颜色色块发光效果!!---------------------------------

	//-------------------------------高亮点击事件弹出【移除高亮/修改颜色/便签按钮】开始-----------------------------------
	//	$(".highlight").on("tap", function(event) {
	//		console.log(event.clientX + " highlight");
	//		//		popHighlight($(".highlight"));
	//		//		return false;
	//	});
	//----------------------------高亮区域点击弹出【移除高亮/修改颜色/便签按钮】结束！！-----------------------------------




	$("a").on("tap", function(event) {
		console.log(event, " href");
		var $this = $(this);

		if (event.currentTarget.attributes[0].localName == "epub:type" || event.currentTarget.attributes[0].localName == "type") {
			var pos = $this.offset(),
				aRes = ['<!DOCTYPE html>', '<html>', '<head>', '<meta charset="utf-8">', '<title></title>', '</head>', '<body>'];
			//增加样式
			$('link').each(function() {
				aRes.push(this.outerHTML);
			});

			//增加标注标头
			aRes.push('<p style="font-size: 28px!important;line-height:30px!important;">' + $this.text() + '</p>');

			//根据$this的href指向的锚点，获得锚点的html
			aRes.push($($this.attr('href')).removeAttr('bodyChild').find('p').removeAttr('style bodyChild').end().html());
			aRes.push('</body>', '</html>');

			sendData({
				"type": "noteref",
				"content": encodeURIComponent(JSON.stringify({
					"html": aRes.join(''),
					"top": Math.round(pos.top),
					"left": Math.round(pos.left),
					"width": $this.width(),
					"height": $this.height()
				}))
			});
		} else {
			var curUrl = event.currentTarget.href;
		
			sendData({
				"type": "turntourl",
				"content": encodeURIComponent(curUrl)
			});

		}
		return false;
	});
	//---------------------------段落前方块点击弹出便签列表结束！！--------------------------------------------------



})
	//-------------------------------段落前方块点击弹出便签列表开始----------------------------------------------------
	
$(document.body).on('touchend', '.square', function() {
	$('.marklist').css({
		left: $(this).offset().left + 30,
		top: $(this).offset().top - 8,
		display: 'block'
	});

	hideOtherDiv('.marklist');

	//加载本段落中所有的具有mark属性的元素到markul中
	var aLis = ["<ul>"],
		oRes = {};

	//对高亮部分以createtime字段进行分隔，防止高亮前后或中间有html标签阻隔
	$(this).closest('[bodyChild]').find('[mark]').each(function() {
		//以createtime进行分隔
		var createtime = $(this).attr('createtime');

		if (!oRes[createtime]) {
			oRes[createtime] = [this];
		} else {
			oRes[createtime].push(this);
		}
	});

	$.each(oRes, function(k, v) {
		var mark = $(v[0]).attr('mark'),
			createtime = new Date(parseInt(k)),
			sTime = createtime.getFullYear() + '年' + (createtime.getMonth() + 1) + '月' + createtime.getDate() + '日',
			aText = [];

		for (var i = 0, l = v.length; i < l; i++) {
			aText.push($(v[i]).text());
		}

		aLis.push('<li createtime="' + k + '"><p>' + aText.join('') + '</p><p><span>' + mark + '</span><span>' + sTime + '</span></p></li>');
	});

	aLis.push('</ul>');

	$('.markul').html(aLis.join(''));
	return false;
});
	//-------------------------------段落前方块点击弹出便签列表结束----------------------------------------------------
	

//-------------------------------高亮点击事件弹出【移除高亮/修改颜色/便签按钮】开始-----------------------------------
function popHighlight($lightObject) {
	var left = $lightObject.offset().left + $lightObject.width() / 2,
		top = $lightObject.offset().top,
		w = $('.fnslist').width(),
		h = $('.fnslist').height(),
		docH = $(':root').height(),
		winH = $(window).height(),
		l = $(document).width() - w - 30,
		t = docH < winH ? winH : docH - h;

	left = left - w / 2;
	left = left > l ? l : left < 30 ? 30 : left;
	top = top - h;
	top = top > t ? t : top < 0 ? 0 : top;

	$('.fnslist').css({
		left: left,
		top: top,
		display: 'block'
	});

	hideOtherDiv('.fnslist');

	//标识当前选中的元素
	$('.highlight').removeClass('current');
	$lightObject.addClass('current');

	return false;
}
$(document.body).on('touchend', '.highlight', function() {
	popHighlight($(this))
	return false;
});
//----------------------------高亮区域点击弹出【移除高亮/修改颜色/便签按钮】结束！！-----------------------------------





//--------------------------------用户便签列表点击开始------------------------------------------------------------
$(document.body).on('touchstart', '.markul li', function() {
	$(this).parent().data('moveFlag', false);
}).on('touchmove', '.markul li', function() {
	$(this).parent().data('moveFlag', true);
}).on('touchend', '.markul li', function() {
	var createtime = $(this).attr('createtime'),
		$highlight = $('.highlight[createtime="' + createtime + '"]'),
		bMoveFlag = $(this).parent().data('moveFlag');

	if (!bMoveFlag) {
		$('.marklist').fadeOut('slow', function() {
			//重新定位当前元素
			$('.current').removeClass('current');
			oCur = $highlight.addClass('current');
			showDialog($highlight, "view");
		});
	}

	//赋值当前活动对象，防止当前对象错乱
	currentHL = $highlight.data('htObj');

	return false;
});
//--------------------------------用户便签列表点击结束！！----------------------------------------------------------


//弹出写便签的对话框
function showDialog($oCur, modifyNoteType) {
	//不足一屏，按一屏的高度计算top的值
	var left = $oCur.offset().left,
		top = $oCur.offset().top,
		width = $oCur.width(),
		height = $oCur.height(),
		$parent = $oCur.closest('[bodyChild]'),
		mark = $oCur.attr('mark'),
		htStartIndex = 0,
		content = null,
		o = {
			"cls": $oCur.removeClass('current').attr('class'),
			"htContent": $oCur.text(),
			"htParContent": $.trim($parent.text()),
			"left": left,
			"top": top,
			"width": width,
			"height": height,
			"modifyNoteType": modifyNoteType
		};

	//计算索引起始位置
	$parent.contents().each(function(k, v) {
		if ($(this).is(oCur) || $(this).find(oCur).length > 0) {
			return false;
		}
		if (this.nodeType == 3) {
			if (k == 0) {
				var l = this.nodeValue.replace(/^\s+/g, '').length;
				htStartIndex += l;
			} else {
				var l = this.length;
				htStartIndex += l;
			}
		} else {
			htStartIndex += $(this).text().length;
		}
	});

	o["htStartIndex"] = htStartIndex;

	if (mark !== undefined) {
		o["mark"] = mark;
	}

	sendData({
		"type": "showNoteRef",
		"content": encodeURIComponent(JSON.stringify(o))
	});
	hideOtherDiv('all');
}

//查找刚刚选中的文本区域
function getCurrentSel() {
	var aNewSel = $('.highlight').get(),
		aResult = [];

	//在aNewSel中过滤当前aSel,因为选区中有可能被html标签隔断
	//最新选区可能有1个以上
	$.each(aNewSel, function(k, v) {
		var n = $.inArray(v, aSel);

		if (n == -1) {
			aResult.push(v);
		}
	});

	return aResult;
}

//删除高亮并移除便签
function delHtAndMark($current) {
	//计算本段落中是否还有便签，没有则删除段落开始处标签列表
	var $parent = $current.closest('[bodyChild]');

	//删除多余属性和样式，方便高亮清除
	$('[createtime="' + $current.attr("createtime") + '"]').removeAttr('createtime mark').removeClass(aCls.join(' ') + " current");

	//连续的highlight替换，防止段落中有特殊样式间隔高亮移除
	//新创建的高亮tempHt有值，以前创建的高亮则tempHt为空
	var tempHt = $current.data('htObj');
	if (tempHt) {
		currentHL = tempHt;
	}

	highlighter.removeHighlights([currentHL]);

	//以mark值找到所有笔记，然后以createtime值进行过滤，值相等则认为是一个笔记
	var $mark = $parent.find('[mark]');

	if ($mark.length > 0) {
		var aRes = [$mark.eq(0)];
		$mark.slice(1).each(function(index, ele) {
			if (aRes[aRes.length - 1].attr("createtime") != $(ele).attr("createtime")) {
				aRes.push($(ele));
			}
		});

		var l = aRes.length;
		if (l > 0) {
			$parent.find('.square').text(l);
		} else {
			$parent.find('.square').remove();
		}
	} else {
		$parent.find('.square').remove();
	}

	//发送所有笔记和重点到app
	sendNotes();
}

//发送数据
function sendData(oJson) {
	var sendEngine = new JSBridgeObj();

	for (var k in oJson) {
		sendEngine.addObject(k, oJson[k]);
	}

	sendEngine.sendBridgeObject();
}

//获得所有笔记
function getAllNotes() {
	var obj = {};

	$('.highlight').each(function(index, ele) {
		var mark = $(ele).attr('mark'),
			createtime = $(ele).attr('createtime'),
			$parent = $(ele).closest('[bodyChild]'),
			htStartIndex = 0;

		//计算索引起始位置
		$parent.contents().each(function(k, v) {
			if ($(this).is(ele) || $(this).find(ele).length > 0) {
				return false;
			}

			if (this.nodeType == 3) {
				if (k == 0) {
					var l = this.nodeValue.replace(/^\s+/g, '').length;
					htStartIndex += l;
				} else {
					var l = this.length;
					htStartIndex += l;
				}
			} else {
				htStartIndex += $(this).text().length;
			}
		});

		//以ele+索引为key,以index【索引，页面中唯一值】,cls【高亮应用的样式】,mark【笔记】,createtime【创建时间】，htContent【高亮内容】，htParContent【所在段落】,htStartIndex【高亮起始位置】,left【在页面中距离左侧距离】,top【在页面中距离顶部距离】
		obj['ele' + index] = {};
		obj['ele' + index]["index"] = index;
		obj['ele' + index]["cls"] = $(ele).removeClass('current').attr('class');
		obj['ele' + index]["htContent"] = $(ele).text();
		obj['ele' + index]["htParContent"] = $.trim($parent.text());
		obj['ele' + index]["htStartIndex"] = htStartIndex;
		obj['ele' + index]["createtime"] = createtime;
		obj['ele' + index]["left"] = $(ele).offset().left;
		obj['ele' + index]["top"] = $(ele).offset().top;

		if (mark !== undefined) {
			obj['ele' + index]["mark"] = mark;
		}
	});

	return JSON.stringify(obj);
}

//向app发送所有的笔记和高亮
function sendNotes() {
	var serializedHighlights = highlighter.serialize(),
		notes = encodeURIComponent(getAllNotes()),
		founderDatas = {
			"htColor": htColor,
			"serializedHighlights": serializedHighlights,
			"founderNotes": notes
		};

	sendData({
		"type": "highLightsref",
		"content": encodeURIComponent(JSON.stringify(founderDatas))
	});
}



//---------------------------------------------供app调用开始--------------------------------------
//<便签>接口
function addNote() {
	setTimeout(function() {
		//高亮选区
		addHighLight();
		//得到当前选中的区域
		var o = getCurrentSel();

		if (o.length == 0) {
			o = $('.current').get(0);
		}

		oCur = o;

		showDialog($(oCur), "add");
	}, 30);
}

//<高亮>接口
function addHL() {
	setTimeout(function() {
		addHighLight();
		sendNotes();

		//高亮后弹出菜单@2015.2.5增加功能
		var o = getCurrentSel();
		//		$(o).trigger('touchend');
		if (o !== undefined)
			popHighlight($(o));
	}, 10);
}

//内部高亮
function addHighLight() {
	//记录高亮前的所有高亮
	aSel = $('.highlight').get();

	//高亮选区
	highlighter.highlightSelection("highlight");

	//-----------------高亮选区数组去除重复开始@防止选区中包含高亮！---------------------
	var l = highlighter.highlights.length,
		oRes = {};

	for (var i = l - 1; i >= 0; i--) {
		var obj = highlighter.highlights[i];
		var pos = obj.characterRange;
		var key = pos.start + '_' + pos.end;

		//记录所有出现过的位置，只记录最后出现的选区，之前重复的删除
		if (!oRes[key]) {
			oRes[key] = i;
		}
	}

	var aBak = [].concat(highlighter.highlights);

	for (var i = l - 1; i >= 0; i--) {
		var obj = highlighter.highlights[i];
		var pos = obj.characterRange;
		var key = pos.start + '_' + pos.end;

		if (oRes[key] != i) {
			aBak.splice(i, 1);
		}
	}
	highlighter.highlights = aBak;

	//-----------------高亮选区数组去除重复结束---------------------

	//Dom结构处理：高亮后增加创建日期,防止高亮中间包含高亮
	var aHt = getCurrentSel();
	if (aHt.length > 1) {
		var first = aHt[0],
			last = aHt[aHt.length - 1];

		$(first).nextUntil(last).removeAttr('mark').removeClass(aCls.join(' ')).add(aHt).attr({
			"createtime": Date.now()
		}).addClass(htColor).data('htObj', aBak[aBak.length - 1]);
	} else {
		$(aHt).attr({
			"createtime": Date.now()
		}).addClass(htColor).data('htObj', aBak[aBak.length - 1]);
	}

	//高亮中包括高亮笔记，所以本段落笔记个数需要重新计算
	//以mark值找到所有笔记，然后以createtime值进行过滤，值相等则认为是一个笔记
	var $bodyChild = $(aHt).closest('[bodyChild]');
	var $mark = $bodyChild.find('[mark]');
	if ($mark.length > 0) {
		var aRes = [$mark.eq(0)];
		$mark.slice(1).each(function(index, ele) {
			if (aRes[aRes.length - 1].attr("createtime") != $(ele).attr("createtime")) {
				aRes.push($(ele));
			}
		});

		var l = aRes.length;
		if (l > 0) {
			$bodyChild.find('.square').text(l);
		} else {
			$bodyChild.find('.square').remove();
		}
	} else {
		$bodyChild.find('.square').remove();
	}
}

/*
 * 加载高亮和便签
 * 参数值：oData = {
 	    htColor:htColor,
		serializedHighlights: null,
		founderNotes: null
	}
	说明：每个网页中的所有高亮保存在一个序列化的字符串中
	每个网页中的笔记都以json格式的字符串保存在founderNotes中
	例如：{'ele0':{
		"index":0,
		"cls":"highlight red1",
		"mark":"如果只是高亮没有笔记则没有该字段",
		"createtime":"创建时间"，
		"htContent":"高亮内容文本"，
		"htParContent":"所在段落文本",
		"htStartIndex":"高亮起始位置",
		"left":"当前高亮距离页面左边距",
		"top":"当前高亮距离页面顶部距离"
	}}
 */
function loadHighLightAndNote(oData) {
	oData = JSON.parse(decodeURIComponent(oData));

	if (oData["htColor"]) {
		htColor = oData.htColor;
	}

	if (oData["serializedHighlights"]) {
		highlighter.deserialize(oData.serializedHighlights);
	}

	var oMarks = JSON.parse(decodeURIComponent(oData.founderNotes));

	$('.highlight').each(function(index, ele) {
		var key = 'ele' + index;
		var oNotes = oMarks[key];
		var cls = oNotes["cls"],
			mark = oNotes["mark"],
			createtime = oNotes["createtime"];

		$(ele).addClass(cls).attr({
			'createtime': createtime
		});

		if (mark !== undefined) {
			var $bodyChild = $(ele).closest('[bodyChild]');

			if ($bodyChild.find('.square').length == 0) {
				$bodyChild.append('<span class="square"></span>');
			}

			$(ele).attr({
				'mark': mark
			});

			//设置笔记个数
			$bodyChild.find('.square').text($bodyChild.find('[mark]').length);
		}
	});
}

/*
 * 客户端赋便签值
 * 参数值：oData = {
 	    content:"笔记内容,如果没有值则此值不存在",
		modifyNoteType: "add或者view或者append"
	}
 */
function setNoteToCurrentHL(oData) {
	if (oData["content"] !== undefined) {
		//判断便签是否为空
		var txt = $.trim(oData["content"]);
		var $bodyChild = $(oCur).closest('[bodyChild]');

		//追加提示块
		if ($(oCur).closest('[bodyChild]').find('.square').length == 0) {
			$('<span class="square"></span>').appendTo($bodyChild);
		}

		//增加创建时间属性，方便找到此元素
		if (!$(oCur).attr('createtime')) {
			$(oCur).attr({
				"createtime": Date.now()
			});
		}

		//为所有时间戳一样的元素赋上相同的笔记
		$('[createtime="' + $(oCur).attr('createtime') + '"]').attr({
			"mark": txt
		});

		//以mark值找到所有笔记，然后以createtime值进行过滤，值相等则认为是一个笔记
		var $mark = $bodyChild.find('[mark]');
		var aRes = [$mark.eq(0)];
		$mark.slice(1).each(function(index, ele) {
			if (aRes[aRes.length - 1].attr("createtime") != $(ele).attr("createtime")) {
				aRes.push($(ele));
			}
		});

		var l = aRes.length;
		if (l > 0) {
			$bodyChild.find('.square').text(l);
		} else {
			$bodyChild.find('.square').remove();
		}

		//发送信息到app
		sendNotes();

		//清空内容并隐藏软键盘和便签对话框
		hideOtherDiv('all');
	} else {
		var $current = $(oCur);
		switch (oData["modifyNoteType"]) {
			case "add":
			case "view":
				delHtAndMark($current);
				break;
			case "append":
				//开始有笔记，删除笔记后高亮一同删除
				if ($(oCur).data('hasMark')) {
					delHtAndMark($current);
				}
				break;
			default:
				break;
		}
	}
}

/*
 * 客户端追加书签标识
 * n:0横向滚动，1纵向滚动
 * return {
 	    index:"书签在当前页面中的位置索引",
		left: "书签左边距",
		top:"书签上边距",
		content:"书签所在段落内容"
	}
 */

function setBookmark(n) {
	var obj = {},
		curScrollTop = $(window).scrollTop(),
		curScrollLeft = $(window).scrollLeft();

	$('[bodyChild="true"]').each(function() {
		var oPos = $(this).offset();
		if (n == 1) {
			if (oPos.top > curScrollTop) {
				$(this).attr('bookmark', true);
				obj.index = $(this).index('[bodyChild="true"]');
				obj.left = Math.round(oPos.left);
				obj.top = Math.round(oPos.top);
				obj.content = $(this).text().trim();
				return false;
			}
		} else {
			if (oPos.left > curScrollLeft) {
				$(this).attr('bookmark', true);
				obj.index = $(this).index('[bodyChild="true"]');
				obj.left = Math.round(oPos.left);
				obj.top = Math.round(oPos.top);
				obj.content = $(this).text().trim();
				return false;
			}
		}
	});

	return JSON.stringify(obj);
}

/*
 * 客户端获得书签内容
 */
function getBookmark(index) {
	var obj = {};

	var $bc = $('[bodyChild="true"]').eq(index);
	var oPos = $bc.offset();

	obj.index = index;
	obj.left = Math.round(oPos.left);
	obj.top = Math.round(oPos.top);
	obj.content = $bc.text().trim();

	return JSON.stringify(obj);
}


/*
 * 客户端删除书签标识
 */
function removeBookmark(index) {
	$('[bodyChild="true"]').eq(index).removeAttr('bookmark');
}

/*
 * 客户端加载书签标识
 * 参数：[index1,index2]所有标识索引(数字)组成的数组
 */
function loadBookmark(arr) {
	var l = arr.length;
	if (l > 0) {
		for (var i = 0; i < l; i++) {
			$('[bodyChild="true"]').eq(arr[i]).attr('bookmark', true);
		}
	}
}

//---------------------------------------------供app调用结束！！--------------------------------------


//---------------------------------------------设置字体大小功能开始--------------------------------------
/*
 * @2015.01.08修改功能
 * 设置字体大小功能
 * 参数散列值：0.6/0.7/0.8/0.9/1/1.1/1.2/1.3/1.4几个值
 * 其中1为初始化值
 */
var $bodySpecialChild = $("[bodyChild='true']"),
	oldFont = {};

$bodySpecialChild.each(function(index, ele) {
	oldFont["ele" + index] = [];
	oldFont["ele" + index].push($(this).css('fontSize'));
	oldFont["ele" + index].push($(this).css('lineHeight'));
});

function setFontSize(n) {
	$bodySpecialChild.each(function(index, ele) {
		var size = parseInt(oldFont["ele" + index][0], 10);
		$(ele).css('fontSize', Math.ceil(size * n) + 'px');
		//设置行高，避免层叠
		if (oldFont["ele" + index][1] != 'normal') {
			$(ele).css('line-height', 'normal');
		}
	});
}

//---------------------------------------------设置字体大小功能结束！！--------------------------------------
//---------------------------------------------修改背景色开始---------------------------------------------
/*
 * @2015.01.08增加功能
 * 修改背景色
 * 参数值：white/brown/black
 */
var bgColors = {
	'white': '#FFFFFF',
	'gray': '#69696B',
	'lightgray': '#EAEAEF',
	'orange': '#FAF9DE',
	'black': '#333333',
	'blue': '#B6D1D3',
	'green': '#E3EDCD',
	'brown': '#FFF2E2'
};

function setBgColor(colorName) {
	var $ele = $(':root').add($bodySpecialChild).add($bodySpecialChild.find("[class]")).filter(function() {
		return !$(this).is('td') && !$(this).is('tr');
	});

	//$ele.css('background-color', bgColors[colorName]);
	$(document.body).css('background-color', bgColors[colorName]);
	if ((colorName == 'black') || (colorName == 'gray')) {
		$ele.css({
			'color': '#FFFFFF',
			'background-color': bgColors[colorName]
		});
	} else {
		$ele.css({
			'color': '',
			'background-color': ''
		});
	}
}

//---------------------------------------------修改背景色结束！！-------------------------------------------


//---------------------------------------------修改行间距开始----------------------------------------------
/*
 * @2015.01.08增加功能
 * 修改行间距
 * 参数值：1.2/1.5/1.8/2
 */
function setLineHeight(n) {
    
	if (n != '1') {
		$bodySpecialChild.css('line-height', n);
	} else {
		//修改为默认值
		$bodySpecialChild.css('line-height', 'normal');
	}
}

//---------------------------------------------修改行间距结束！！----------------------------------------------


//---------------------------------------------修改超出body宽度图片开始-----------------------------------------
//$(document).on('touchmove', 'img', function() {
//	$(this).data('bMoved', true);
//}).on('touchend', 'img', function() {
//	var $this = $(this),
//		pos = $this.offset();
//
//	if ($this.data('bMoved')) {
//		$this.data('bMoved', false);
//	} else {
//		//如果图片有超链接则自动转到超链接，否则弹窗显示大图
//		if ($this.closest('a').length == 0) {
//			sendData({
//				"type": "pictureref",
//				"content": encodeURIComponent(JSON.stringify({
//					"src": $this.attr('src'),
//					"top": Math.round(pos.top),
//					"left": Math.round(pos.left),
//					"width": $this.width(),
//					"height": $this.height()
//				}))
//			});
//		}
//	}
//});

function setImageSize() {
	var bodyW = $(document.body).width() * 0.9;
	var winH = window.innerHeight - 50;
	$('image').each(function() {
		var src = $(this).attr('xlink:href');
		$(this).parent().replaceWith('<img src="' + src + '" />');
	});

	$('img').css('width', '').each(function() {
		//宽度处理
		var w = $(this).width();

		if (w > bodyW) {
			$(this).css({
				width: bodyW,
				height: 'auto'
			});
		}

		//高度处理
		var h = $(this).height();
		if (h > winH) {
			$(this).css({
				width: 'auto',
				height: winH
			});
		}

		$(this).data('bMoved', false);
	});
}

function setVideoSize() {
	var bodyW = $(document.body).width() * 0.9;
	var winH = window.innerHeight - 50;

	$('video').each(function() {
		//宽度处理
		var w = $(this).width();
		var h = $(this).height();

		if (w > bodyW || w == 0 || w == 'auto') {
			$(this).css({
				width: bodyW,
				height: h * bodyW / w
			});
		}

		//高度处理
		h = $(this).height();
		if (h > winH) {
			$(this).css({
				width: bodyW * winH / h,
				height: winH
			});
		}
	});
}

setImageSize();
setVideoSize();

window.onorientationchange = function() {
	setImageSize();
	setVideoSize();
};

//---------------------------------------------修改超出body宽度图片结束！！---------------------------------------


//---------------------------------------------【标注】开始-----------------------------------------
//所有标注默认隐藏
$('a[href^="#"]').each(function() {

	var $cur = $($(this).attr('href'));

	console.log('par', $cur.parent());
	if (!$cur.parent().is('sup')) {
		$cur.css('display', 'none');
	}
});



//---------------------------------------------【标注】结束-----------------------------------------

//---------------------------------------------获得页面高度开始-----------------------------------------
function getPageSize() {
	var $root = $(':root');
	return JSON.stringify({
		"width": $root.width(),
		"height": $root.height()
	});
}

function getPageHeight() {
	return JSON.parse(getPageSize()).height;
}

//---------------------------------------------获得页面高度结束！！---------------------------------------


//--------------------------------------根据字符串获得高亮颜色背景值开始------------------------------------
/* 这里颜色值对应founderEupb.css中颜色值
 * 颜色调整时勿忘css中颜色值也要修改！
 * 参数：str为颜色key
 */
var cols = {
	"highlight": "#ffeb6b",
	"red1": "#f64747",
	"pink1": "#ffb0ca",
	"blue1": "#add8ff",
	"green1": "#c0ed72",
	"yellow1": "#ffeb6b",
	"gray1": "#d9b2ff"
};

function getHTbg(str) {
	return cols[str];
}

//---------------------------------------字符串获得字体颜色值结束！！---------------------------------


//---------------------------------------------滚动条滚动开始-----------------------------------------
function setScrollTop(t) {
	return $(window).scrollTop(t);
}

function setBodyH(h) {
		$(document.body).height(h);
	}
	//---------------------------------------------滚动条滚动结束！！---------------------------------------


//---------------------------------------------锚点链接处理开始-----------------------------------------

function getAnchorPos(id) {
	var new_position = $(id).offset();
	var tempData = {
		"left": new_position.left,
		"top": new_position.top,
	};
	return JSON.stringify(tempData);
}

//---------------------------------------------锚点链接处理结束！！---------------------------------------


//---------------------------------------------字符串搜索处理开始-----------------------------------------
/*
 * 根据字符串关键字sKey返回网页中关键字的相关信息
 * @return {
 * 	"ele0_0":{
 * 		left:"距离左边距",
 * 		top:"距离上边距",
 * 		startIndex:"关键字在父级元素中的起始位置",
 * 		text:"所在字符串全文"
 * }
 * }
 */
var $bodyHTMLSearch = null;

function getResFromSearch(sKey) {
	var $bodychild = $("[bodyChild]"),
		bodyHTML = '',
		oRes = {},
		reg = new RegExp(sKey, "gi");

	$bodychild.each(function() {
		bodyHTML += $(this).text();
	});

	if (reg.test(bodyHTML)) {
		//每一个子元素进行遍历查看
		$bodychild.each(function(index, ele) {
			var $ele = $(ele),
				text = $ele.text(),
				reg = new RegExp(sKey, "gi"),
				matches = null;

			if (reg.test(text)) {
				//记忆索引位置,根据索引个数判断是否包含关键字
				var arr = [],
					reg = new RegExp(sKey, "gi");

				while ((matches = reg.exec(text)) != null) {
					arr.push(matches.index);
				}

				var l = arr.length;
				if (l > 0) {
					$ele.contents().each(function() {

						if (this.nodeType == 3) {
							$(this).replaceWith(this.nodeValue.replace(reg, '<span class="founderSearchKey">' + sKey + '</span>'));
						} else {
							$(this).replaceWith(this.innerText.replace(reg, '<span class="founderSearchKey">' + sKey + '</span>'));
						}
					});

					//当前元素中查询关键字
					var $fy = $ele.find('.founderSearchKey');

					//输出元素索引及位置信息
					for (var i = 0; i < l; i++) {
						var $this = $fy.eq(i),
							oPos = $this.offset();

						//创建位置标识，方便查询
						oPos.left = Math.round(oPos.left);
						oPos.top = Math.round(oPos.top);

						$this.attr('pos', oPos.left + '_' + oPos.top);

						oRes["ele" + index + '_' + i] = {
							"text": text,
							"startIndex": arr[i],
							"left": oPos.left,
							"top": oPos.top
						};
					}
				}
			}
		});
	}

	//备份一下,方便元素遍历时赋值定位
	$bodyHTMLSearch = $("[bodyChild]").clone();

	$(document.body).find('.foundersearchkey').replaceWith(function() {
		return $(this).contents();
	});

	return JSON.stringify(oRes);
}

/*
 * 根据字符串位置定位到相关元素并高亮
 * arg:1.left,2.top
 */
function toPosAndHt(left, top) {
	//body元素重新赋值
	$("[bodyChild]").remove();
	$bodyHTMLSearch.prependTo(document.body);


	//根据left_top的值找到元素
	var $ele = $("[pos='" + left + "_" + top + "']");

	$ele.replaceWith('<span class="highlight">' + $ele.text() + '</span>');

	//删除多余标签
	$(document.body).find('.foundersearchkey').replaceWith(function() {
		return $(this).contents();
	});
}
