// Runtime sizing corrections for the Modern Classic P/O workspace.
// Keep legacy jqGrid/jquery.layout behavior; only fit the rendered chrome to each pane.
(function ($) {
    function fitGrid(gridId, width, availableHeight) {
        var $grid = $('#' + gridId);
        var $gbox = $('#gbox_' + gridId);
        if (!$grid.length || !$gbox.length) return;

        if (width > 100) {
            $grid.setGridWidth(Math.max(300, Math.floor(width)));
        }

        var $body = $gbox.find('.ui-jqgrid-bdiv').first();
        if (!$body.length || availableHeight <= 0) return;

        // jqGrid setGridHeight() only sizes the scrollable body. Measure all
        // header/filter/pager chrome from the live grid so the pager is never
        // pushed below an overflow:hidden pane.
        var bodyHeight = $body.height();
        var chromeHeight = Math.max(0, $gbox.outerHeight() - bodyHeight);
        var targetBodyHeight = Math.max(80, Math.floor(availableHeight - chromeHeight));
        $grid.setGridHeight(targetBodyHeight);
    }

    function fitPoWorkspace() {
        var $master = $('#lay-center-po.po-modern-master');
        var $detailLayout = $('#layout-south-po.po-modern-detail-layout');
        var $tabs = $('#tabs-donhang-details.po-modern-details');
        var $toolbar = $('#po-modern-toolbar');
        if (!$master.length || !$detailLayout.length || !$tabs.length || !$toolbar.length) return;

        // Use the real content box. The previous generic "-20" allowance left
        // a visible unused strip on the right side of the master workspace.
        var masterWidth = Math.max(300, $master.width() - 2);
        var masterAvailableHeight = $master.innerHeight() - $toolbar.outerHeight(true) - 1;
        fitGrid('grid_ds_po', masterWidth, masterAvailableHeight);

        // Preserve the product image east pane and fit the detail grids only to
        // the actual center pane occupied by #tabs-donhang-details.
        try {
            var detailLayout = $detailLayout.data('layout');
            if (detailLayout) {
                if (detailLayout.sizePane) detailLayout.sizePane('east', 220);
                if (detailLayout.open) detailLayout.open('east');
                if (detailLayout.resizeAll) detailLayout.resizeAll();
            }
        } catch (ignoreDetailLayout) { }

        var $tabNav = $tabs.children('.ui-tabs-nav').first();
        var detailWidth = Math.max(300, $tabs.width() - 2);
        var detailAvailableHeight = $tabs.innerHeight() - $tabNav.outerHeight(true);

        $.each(['grid_ds_chitietpo', 'grid_khoanphi', 'grid_ds_donhang_spdt'], function (_, gridId) {
            fitGrid(gridId, detailWidth, detailAvailableHeight);
        });
    }

    function scheduleFit() {
        window.setTimeout(fitPoWorkspace, 0);
        window.setTimeout(fitPoWorkspace, 120);
        window.setTimeout(fitPoWorkspace, 400);
    }

    $(function () {
        // Tighten only the small decorative padding that became visible after
        // moving CRUD actions above the grid. Do not alter the layout splitter.
        if (!document.getElementById('demo-po-spacing-fix-css')) {
            $('<style id="demo-po-spacing-fix-css">' +
                'body.demo-modern-ui #lay-center-po.po-modern-master{padding:6px 3px 1px !important;}' +
                'body.demo-modern-ui .po-modern-toolbar{margin-bottom:4px;}' +
                '</style>').appendTo('head');
        }

        window.setInterval(function () {
            if ($('#po-modern-toolbar').length) fitPoWorkspace();
        }, 700);

        $(window).off('resize.demoPoLayoutFix').on('resize.demoPoLayoutFix', scheduleFit);
        $('#tabs-main').off('tabsselect.demoPoLayoutFix').on('tabsselect.demoPoLayoutFix', scheduleFit);
        scheduleFit();
    });
})(jQuery);
