// Modern Classic demo behavior. Keep legacy tab/add_tab mechanics intact.
(function ($) {
    $(function () {
        // This script is emitted before the legacy inline ready handlers. Defer
        // so pageLayout and the old ribbon bindings exist before replacing shell UI.
        window.setTimeout(function () {
            if (!document.getElementById('demo-modern-classic-css')) {
                $('<link>', {
                    id: 'demo-modern-classic-css',
                    rel: 'stylesheet',
                    type: 'text/css',
                    href: 'theme/demogiaodien/modern-classic.css'
                }).appendTo('head');
            }

            $('body').addClass('demo-modern-ui');

            // Root cause of the large blank header was the legacy 92px north pane.
            // Keep jquery.layout itself, only resize that pane for the demo shell.
            if (window.pageLayout && pageLayout.sizePane) {
                pageLayout.sizePane('north', 46);
                pageLayout.resizeAll();
            }

            var $ribbon = $('#ribbon');
            var $contents = $ribbon.find('div.tab-content');
            var $nav = $ribbon.find('ul.tab-navigation');
            var $navLinks = $nav.find('li a');

            $contents.hide();
            $nav.find('li').removeClass('active');

            // Legacy ready() attached a permanent ribbon switcher. Replace only
            // those link handlers; menu data and add_tab() remain source-of-truth.
            $navLinks.off('click').on('click.demoModern', function (event) {
                event.preventDefault();
                event.stopPropagation();

                var $link = $(this);
                var $li = $link.parent();
                var $panel = $($link.attr('href'));
                var wasOpen = $panel.is(':visible');

                $contents.hide();
                $nav.find('li').removeClass('active');

                if (!wasOpen) {
                    $li.addClass('active');

                    // Align dropdown with the selected top-level module when room permits.
                    var left = $li.position().left;
                    var maxLeft = Math.max(0, $(window).width() - $panel.outerWidth() - 16);
                    $panel.css('left', Math.min(116 + left, maxLeft) + 'px').show();
                }
            });

            $contents.off('click.demoModern', '.items').on('click.demoModern', '.items', function () {
                $contents.hide();
                $nav.find('li').removeClass('active');
            });

            $(document).off('click.demoModernRibbon').on('click.demoModernRibbon', function (event) {
                if ($(event.target).closest('#ribbon').length === 0) {
                    $contents.hide();
                    $nav.find('li').removeClass('active');
                }
            });

            $(window).off('resize.demoModern').on('resize.demoModern', function () {
                $contents.hide();
                $nav.find('li').removeClass('active');
            });
        }, 0);
    });
})(jQuery);
