// Modern Classic demo behavior. Keep legacy tab/add_tab mechanics intact.
(function ($) {
    $(function () {
        $('body').addClass('demo-modern-ui');

        var $ribbon = $('#ribbon');
        var $contents = $ribbon.find('div.tab-content');
        var $navLinks = $ribbon.find('ul.tab-navigation li a');

        // Legacy page shows the first ribbon section permanently. In demo mode
        // sections behave as dropdown panels and start closed.
        $contents.hide();
        $ribbon.find('ul.tab-navigation li').removeClass('active');

        $navLinks.off('click.demoModern').on('click.demoModern', function (event) {
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
