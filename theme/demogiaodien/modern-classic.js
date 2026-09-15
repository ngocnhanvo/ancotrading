// Modern Classic demo behavior. Keep legacy tab/add_tab mechanics intact.
(function ($) {
    $(function () {
        // Load the demo stylesheet last so it can safely override the legacy
        // jQuery UI / silver theme without modifying those production assets.
        if (!document.getElementById('demo-modern-classic-css')) {
            $('<link>', {
                id: 'demo-modern-classic-css',
                rel: 'stylesheet',
                type: 'text/css',
                href: 'theme/demogiaodien/modern-classic.css'
            }).appendTo('head');
        }

        $('body').addClass('demo-modern-ui');

        var $ribbon = $('#ribbon');
        var $contents = $ribbon.find('div.tab-content');
        var $navLinks = $ribbon.find('ul.tab-navigation li a');

        // Legacy page shows the first ribbon section permanently. In demo mode
        // sections behave as dropdown panels and start closed.
        $contents.hide();
        $ribbon.find('ul.tab-navigation li').removeClass('active');

        // The legacy handler is bound directly on these links. Remove it here,
        // then keep the existing href -> panel mapping as the source of truth.
        $navLinks.off('click').on('click.demoModern', function (event) {
            event.preventDefault();
            event.stopPropagation();

            var $link = $(this);
            var $li = $link.parent();
            var selector = $link.attr('href');
            var $panel = $(selector);
            var wasOpen = $panel.is(':visible');

            $contents.hide();
            $ribbon.find('ul.tab-navigation li').removeClass('active');

            if (!wasOpen) {
                $li.addClass('active');
                $panel.show();
            }
        });

        $contents.off('click.demoModern', '.items').on('click.demoModern', '.items', function () {
            $contents.hide();
            $ribbon.find('ul.tab-navigation li').removeClass('active');
        });

        $(document).off('click.demoModernRibbon').on('click.demoModernRibbon', function (event) {
            if ($(event.target).closest('#ribbon').length === 0) {
                $contents.hide();
                $ribbon.find('ul.tab-navigation li').removeClass('active');
            }
        });
    });
})(jQuery);
