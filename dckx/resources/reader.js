


class Reader {
	
	constructor(options)
	{
		// Mandatory options
		if (!options.container || options.container.length == 0) {
			console.error('no container given in options');
			return;
		}
		this.gui = options.container;
		this.gui.data('reader',this);
		
		if (!options.imageSrc) {
			console.error('no imageSrc given in options');
			return;
		}
		this.imageSrc = options.imageSrc;
		this.num = options.num;
		this.date = options.date;
		this.altText = options.altText;

		if (!options.comicsJson || typeof options.comicsJson != 'object') {
			console.error('no comicsJson given in options, or not a javascript object');
			return;
		}
		this.comic = options.comicsJson;
		
		this.known_panels = options.known_panels ? options.known_panels : [];
		
		// init attributes
		this.currpage = 0;
		this.currpanel = 0;
		this.showInfo = false;
		this.debug = this.gui.hasClass('debug') || 'debug' in this.getHashInfo();
		if (this.debug)
			this.gui.addClass('debug');
		
		// add image sub-container
		this.container = $('<div class="container"/>');
		this.container.css({
			position: 'relative',
			width: '95%',
			height: '95%',
			margin: 'auto'
		});
		this.gui.append(this.container);
		var size = {
			w: this.container.parent().width(),
			h: this.container.parent().height()
		};
		console.log(size);

		if (options['controls'])
			this.add_controls();
		
		window.addEventListener('orientationchange', function () {
			setTimeout( function () { this.gotoPanel(this.currpanel); }.bind(this), 500);  // slight delay to make it work better, not sure why :)
		}.bind(this));
	}
	
	getHashInfo ()
	{
		var hash = window.location.hash.replace(/^#/,'').split(',');
		var info = {};
		for (var i in hash)
		{
			var h = hash[i].split('=');
			info[h[0]] = h[1];
		}
		return info;
	}
	
	setHashInfo (newinfo)
	{
		var info = this.getHashInfo();
		for (var i in newinfo)
			info[i] = newinfo[i];
		info = Object.entries(info).map(function (kv) {
			if (kv[1] === null)
				return '';
			return kv[0] + (kv[1] ? '=' + kv[1] : '');
		}).filter(function(v){return v?true:false});
		window.location.hash = info.join(',');
		
	}
	
	start ()
	{
		var page = this.getHashInfo()['page'];
		if (!page)
			page = 0;
		this.loadPage(page);
	}
	
	next()
	{
		if (this.container.is('.zoomed'))
			this.nextPanel();
		else
			this.loadNextPage();
	}
	prev()
	{
		if (this.container.is('.zoomed'))
			this.prevPanel();
		else
			this.loadPrevPage();
	}
	
	loadNextPage() { return this.loadPage(this.currpage+1); }
	loadPrevPage() { return this.loadPage(this.currpage-1); }
	loadPage(page=0)
	{
		page = parseInt(page);
		
		// don't go to a page below 0, or above the number of pages in this comic
		if (page < 0) {
			this.dezoom();
			return false;
				
		} else if (page >= this.comic.length) {	
			var imginfo = this.comic[this.comic.length-1];
			
			if (this.currpanel == imginfo['panels'].length) {
				this.dezoom();
			} else {
				var newPanel = $('.panel').eq(0);

				if (newPanel.length > 0) {
					this.currpanel = 0;
					this.zoomOn(newPanel);
				}
			}
			return false;
		}
		
		this.currpage = page;
		this.setHashInfo({page: page ? page : null});
		
		var imginfo = this.comic[page];
		var img = $('<img class="pageimg" src="'+this.imageSrc+'"/>');
		img.css({
			position: 'absolute',
			width: '100%',
			height: '100%'
		});
		
		this.container.children('img').remove();
		this.container.prepend(img);
		
		var was_zoomed = this.container.is('.zoomed');
		this.drawPanels(imginfo);
		this.dezoom();
		
		if (this.currpanel == 'last')
			this.currpanel = $('.panel').length-1;
		else
			this.currpanel = 0;
		
		if (was_zoomed)
			this.gotoPanel(this.currpanel);
		
		return true;
	}
	
	zoomOn (panel)
	{
		var growth = this.container.parent().width() / panel.width();
		var max = 'x';
		var ygrowth =  this.container.parent().height() / panel.height();
		
		if (ygrowth < growth) {
			growth = ygrowth;
			max = 'y';
		}
		
		var newcss = {
			top:  - panel.position().top  * growth,
			left: - panel.position().left * growth,
			height: this.container.height() * growth,
			width:  this.container.width()  * growth
		};
		
		// center panel horizontally or vertically within container's parent
		if (max == 'x')
			newcss.top  += (this.container.parent().height() - panel.height() * growth) / 2;
		else
			newcss.left += (this.container.parent().width()  - panel.width()  * growth) / 2;
		
		$('.panel.zoomTarget').removeClass('zoomTarget');
		panel.addClass('zoomTarget');
		
		this.container.addClass('zoomed');
		this.container.animate(newcss,300);
	}
	
	dezoom ()
	{
		var size = this.getImgSize();
		
		var newcss = {
			width: size.w,
			height: size.h,
			left: 0,//(this.container.parent().width() - size.w) / 2, // center horizontally,
			top: (this.container.parent().height() - size.h) / 2,  // center vertically
			color: 'var(--color)',
    		'background-color': 'var(--background)'
		};
		this.container.removeClass('zoomed');
		this.container.css(newcss);
	}
	
	getImgSize ()
	{
		var size = {
			w: this.container.parent().width(),
			h: this.container.parent().height()
		};
		
		var imgsize = [0, 0]

		if (!('size' in this.comic[this.currpage])) {
			const img = new Image();
			img.src = this.imageSrc
			imgsize[0] = img.width
			imgsize[1] = img.height
		} else {
			imgsize = this.comic[this.currpage]['size'];
		}

		var ratio = imgsize[0] / imgsize[1];
		if (size.w > size.h * ratio)
			size.w = size.h * ratio;
		else if (size.h > size.w / ratio)
			size.h = size.w / ratio;
		
		return size;
	}
	
	gotoPanel (i)
	{
		if (i < 0) {
			this.currpanel = 'last';
			var prevpage = this.loadPrevPage();
			if (!prevpage) {
				this.currpanel = 0;
			}	
			return;
		}

		var newPanel = $('.panel').eq(i);
		if (newPanel.length > 0)
			this.zoomOn(newPanel);
		else {
			var nextpage = this.loadNextPage();
			if (!nextpage)
				this.currpanel--;
		}
	}
	nextPanel () { this.currpanel++; this.gotoPanel(this.currpanel); }
	prevPanel () { this.currpanel--; this.gotoPanel(this.currpanel); }
	
	drawPanels (imginfo)
	{
		if (!('size' in imginfo)) {
			var panel = $('<div class="panel"><!-- --></div>');
			panel.addClass('unknown');
			var panelcss = {
				top: '0',
				left: '0',
				height: '100%',
				width: '100%'
			};
			panel.css(panelcss);
			
			this.container.append(panel);
			return;
		}

		this.container.children('*:not(.pageimg)').remove();
		
		var [imgw,imgh] = imginfo['size'];
		
		var i = 1;
		for (var p in imginfo['panels'])
		{
			var unknown = !this.known_panels.includes(parseInt(p));
			p = imginfo['panels'][p];
			var [x,y,w,h] = p;
			
			var panel = $('<div class="panel"><!-- --></div>');
			if (unknown)
				panel.addClass('unknown');
			var panelcss = {
				top: '' + y/imgh*100 + '%',
				left: '' + x/imgw*100 + '%',
				height: '' + h/imgh*100 + '%',
				width: '' + w/imgw*100 + '%'
			};
			panel.css(panelcss);
			
			this.container.append(panel);
		}
	}
	
	add_controls()
	{
		var _reader = this;

		// TODO: don't add controls if we only have 1 panel
		var imginfo = this.comic[this.comic.length-1];

		if (!$.isEmptyObject(imginfo) && imginfo['panels'].length > 1) {

			var btprev = $('<i class="prev"><div class="center">←</div></i>');
			btprev.data('reader',this);
			btprev.on('click touch', function (e) { $(this).data('reader').prev(); });
			this.gui.append(btprev);

			var btnext = $('<i class="next"><div class="center">→</div></i>');
			btnext.data('reader',this);
			btnext.on('click touch', function (e) { $(this).data('reader').next(); });
			this.gui.append(btnext);
		}
		$(document).ready( function () {
			_reader.dezoom();
			_reader.container.focus();
		});
	}

	toggleShowInfo() {
		this.showInfo = !this.showInfo;

		if (this.showInfo == true) {
			var leftText = $('<i class="leftText"><div>'+this.num+'</div></i>');
			this.gui.append(leftText);
			var rightText = $('<i class="rightText"><div>'+this.date+'</div></i>');
			this.gui.append(rightText);
			var altText = $('<i class="altText"><div>'+this.altText+'</div></i>');
			this.gui.append(altText);
		} else {
			const array1 = ['leftText', 'rightText', 'altText'];

			array1.forEach(function(item) {
				var thingToRemove = document.querySelectorAll("."+item)[0];
				thingToRemove.parentNode.removeChild(thingToRemove);
			})
		}
	}
}


// Change view mode
$(document).delegate( 'input[name=viewmode]', 'change', function () {
	if (!$(this).is(':checked'))
		return;
	
	var reader = $(this).parents('.kumiko-reader:eq(0)').data('reader');
	switch ($(this).val()) {
		case 'page':
			reader.dezoom();
			break;
		case 'panel':
			reader.gotoPanel(0);
			break;
	}
	reader.container.focus();
});

// Next panel on simple click
$(document).delegate( '.kumiko-reader', 'click touch', function (e) {
	if ($(e.target).is('.panel,.kumiko-reader'))
		$(this).data('reader').toggleShowInfo();
});

// Prevent click on page when clicking on license links
$(document).delegate( '.license a', 'click touch', function (e) {
	e.stopPropagation();
});


/**** KEYBOARD NAVIGATION ****/

$(document).keydown(function(e) {
	if (e.altKey)  // alt+left is shortcut for previous page, don't  prevent it
		return;
	
	switch(e.which) {
		case 37: // left
		case 38: // up
			reader.prev();
			break;
			
		case 39: // right
		case 40: // down
			reader.next();
			break;
		
		case 68: // 'd' debug (show panels)
			var d = $('input.toggleDebug');
			d.prop('checked',!d.is(':checked')).change();
			break;
		
		// case 77: // 'm' key: toggle menu
		// 	reader.showMenu('toggle');
		// 	break;
		
		case 80: // 'p' key: switch between page and panel reading
			$('input[name=viewmode]:not(:checked)').prop('checked',true).change();
			break;
		
		default:
			return; // exit this handler for other keys
	}
	e.preventDefault();
});
