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

                    // The dropdown is absolutely positioned inside #ribbon, so use
                    // the button's real document offset minus the ribbon offset.
                    // The previous code added the 116px logo gutter twice, which
                    // caused the mega menu to drift to the right of the clicked tab.
                    var ribbonLeft = $ribbon.offset().left;
                    var buttonLeft = $li.offset().left;
                    var left = Math.max(0, buttonLeft - ribbonLeft);
                    var panelWidth = $panel.outerWidth() || 520;
                    var maxLeft = Math.max(0, $ribbon.innerWidth() - panelWidth - 8);

                    $panel.css('left', Math.min(left, maxLeft) + 'px').show();
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
