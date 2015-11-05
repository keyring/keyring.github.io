// https://github.com/ghiculescu/jekyll-table-of-contents
(function($) {

    $.fn.toc = function(options) {
        var defaults = {
                noBackToTopLinks: false,
                title: '',
                minimumHeaders: 2,
                headers: 'h1, h2, h3, h4, h5, h6',
                listType: 'ul', // values: [ol|ul]
                classes: 'anchor',
                showEffect: 'fadeIn', // values: [show|slideDown|fadeIn|none]
                showSpeed: 'slow' // set to 0 to deactivate effect
            },
            settings = $.extend(defaults, options);
        // since markdown render header into valid string, encodeURIComponenet is no longer necessary.
        function fixedEncodeURIComponent(str) {
            return encodeURI(str);
        }

        var headers = $(settings.headers).filter(function() {
                // get all headers with an ID
                var previousSiblingName = $(this).prev().attr("name");
                if (!this.id && previousSiblingName) {
                    this.id = $(this).attr("id", previousSiblingName.replace(/\./g, "-"));
                }
                return this.id;
            }),
            output = $(this);
        if (!headers.length || headers.length < settings.minimumHeaders || !output.length) {
            return;
        }

        if (0 === settings.showSpeed) {
            settings.showEffect = 'none';
        }

        var render = {
            show: function() {
                output.hide().html(html).show(settings.showSpeed);
            },
            slideDown: function() {
                output.hide().html(html).slideDown(settings.showSpeed);
            },
            fadeIn: function() {
                output.hide().html(html).fadeIn(settings.showSpeed);
            },
            none: function() {
                output.html(html);
            }
        };

        var get_level = function(ele) {
            return parseInt(ele.nodeName.replace("H", ""), 10);
        }
        var highest_level = headers.map(function(_, ele) {
            return get_level(ele);
        }).get().sort()[0];
        var return_to_top = '<i class="icon-arrow-up back-to-top"> </i>';

        var level = get_level(headers[0]),
            this_level,
            html = settings.title + " <" + settings.listType + " class = 'nav nav-pills nav-stacked'>";
        headers.on('click', function() {
                if (!settings.noBackToTopLinks) {
                    window.location.hash = this.id;
                }
            })
            .addClass(settings.classes)
            .addClass('clickable-header sub-level-header')
            .each(function(_, header) {
                this_level = get_level(header);
                if (!settings.noBackToTopLinks && this_level === highest_level) {
                    $(header).addClass('top-level-header').after(return_to_top);
                }
                if (this_level === level) // same level as before; same indenting
                    html += "<li><a href='#" + header.id + "'>" + header.innerHTML + "</a>";
                else if (this_level <= level) { // higher level than before; end parent ol
                    for (i = this_level; i < level; i++) {
                        html += "</li></" + settings.listType + ">"
                    }
                    html += "<li><a href='#" + header.id + "'>" + header.innerHTML + "</a>";
                } else if (this_level > level) { // lower level than before; expand the previous to contain a ol
                    for (i = this_level; i > level; i--) {
                        html += "<" + settings.listType + " class = 'nav nav-pills nav-stacked'><li>"
                    }
                    html += "<a href='#" + header.id + "'>" + header.innerHTML + "</a>";
                }
                level = this_level; // update for the next one
            });
        html += "</" + settings.listType + ">";
        if (!settings.noBackToTopLinks) {
            $(document).on('click', '.back-to-top', function() {
                $(window).scrollTop(0);
                window.location.hash = '';
            });
        }

        render[settings.showEffect]();
    /**
     * |<------------------------------w------------------------------>|
     * |       -----------     -----------------     -----------       |
     * |<--l-->|   nav   |<-d->|               |<-d->| outline |<--x-->|
     * |       |<---n--->|     |<------c------>|     |<---a--->|       |
     * |       -----------     |               |     -----------       |
     * |<----------m---------->|               |                       |
     * |                       -----------------                       |
     * -----------------------------------------------------------------
     * (w - c) / 2 = d + a + x
     *   => x = (w - c) / 2 - (a + d), where
     *     w = $(window).width(),
     *     c = $('#container').width(),
     *     a = $('h2outline').width(),
     *
     * m = l + n + d
     *   => d = m - (l + n), where
     *     m = $('#container').position().left,
     *     l = $('#real_nav').position().left,
     *     n = $('#real_nav').width()
     */

        jQuery.easing['jswing'] = jQuery.easing['swing'];
        jQuery.extend( jQuery.easing,
        {
            def: 'easeOutQuad',
            swing: function (x, t, b, c, d) {
            //alert(jQuery.easing.default);
            return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
                },
            easeOutQuad: function (x, t, b, c, d) {
            return -c *(t/=d)*(t-2) + b;
                },
            easeOutQuint: function (x, t, b, c, d) {
            return c*((t=t/d-1)*t*t*t*t + 1) + b;
                }
         });

        $(window).resize(function () {
        var w = $(window).width(),
                c = 600,
                a = $('#toc').width();
                d = 40; // #real_nav has left margin of -184.8px
                $('#toc').css('right',
                              (w - c) / 2 - (a + d));
            });
        $(window).resize();

        toplest=$('article').offset().top;
        animationSpeed=1500;
        animationEasing='easeOutQuint';       
        $(window).scroll(function(){ 

            var scrollAmount=$(document).scrollTop();
            if (scrollAmount < toplest) 
                scrollAmount = 0;
            else
                scrollAmount = scrollAmount-50;

            var newPosition=toplest+scrollAmount;
            $('#toc').stop().animate({top: newPosition}, animationSpeed, animationEasing);
            $('#toc').css("top",newPosition)
        });
    };
})(jQuery);