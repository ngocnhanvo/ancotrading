// Modern Classic demo behavior. Keep legacy tab/add_tab mechanics intact.
(function ($) {
    function closeRibbonMenus() {
        var $ribbon = $('#ribbon');
        $ribbon.find('div.tab-content').hide();
        $ribbon.find('ul.tab-navigation li').removeClass('active');
    }

    function getPagerButtons(gridId) {
        var $pager = $('#' + gridId + '-pager');
        return $pager.find('.ui-pg-button').filter(function () {
            return $(this).attr('id') || $(this).attr('title');
        });
    }

    function clickGridAction(gridId, action) {
        var selector = '#' + action + '_' + gridId;
        var $button = $(selector);
        if ($button.length) {
            $button.trigger('click');
            return true;
        }
        return false;
    }

    function buildMoreMenu($host, gridId, excludedIds) {
        var $menu = $('<div class="po-modern-more-menu"></div>').hide();
        var used = {};
        var excluded = excludedIds || {};

        getPagerButtons(gridId).each(function () {
            var $button = $(this);
            var id = $button.attr('id') || '';
            var title = $.trim($button.attr('title') || $button.text() || '');

            if (!title || excluded[id] || used[id || title]) {
                return;
            }

            used[id || title] = true;

            var $item = $('<button type="button" class="po-modern-more-item"></button>').text(title);
            $item.on('click.demoPo', function (event) {
                event.preventDefault();
                event.stopPropagation();
                $button.trigger('click');
                $menu.hide();
            });
            $menu.append($item);
        });

        if (!$menu.children().length) {
            $menu.append('<div class="po-modern-more-empty">Không có chức năng khác</div>');
        }

        $host.append($menu);
        return $menu;
    }

    function formatPoCaption(text) {
        var value = $.trim(text || '');
        if (!value || value.toLowerCase() === 'đơn hàng' || value.toLowerCase() === 'đang tải...') {
            return '<span class="po-summary-label">Đơn hàng:</span><strong class="po-summary-primary">Chưa chọn</strong>';
        }

        // Caption data is formatted like:
        // Đơn hàng:..., CBM:..., Amount:11,728.80, Quantity:..., Đặt cọc:...
        // Do not split on every comma because Amount may contain a thousands
        // separator. Split only when the next token is another "label:" pair.
        var parts = value.split(/,\s*(?=[^,:]+\s*:)/);
        var html = [];
        $.each(parts, function (index, item) {
            var part = $.trim(item);
            if (!part) return;

            var colon = part.indexOf(':');
            if (colon > -1) {
                var label = $.trim(part.substring(0, colon));
                var val = $.trim(part.substring(colon + 1));
                if (index === 0) {
                    html.push('<span class="po-summary-label">' + label + ':</span><strong class="po-summary-primary">' + val + '</strong>');
                } else {
                    html.push('<span class="po-summary-sep"></span><span class="po-summary-label">' + label + '</span><strong>' + val + '</strong>');
                }
            } else {
                html.push('<span class="po-summary-sep"></span><strong>' + part + '</strong>');
            }
        });

        return html.join('');
    }

    function syncPoSummary() {
        var $caption = $('#gbox_grid_ds_po .ui-jqgrid-title').first();
        var $summary = $('#po-modern-summary');
        if (!$caption.length || !$summary.length) return;

        var text = $.trim($caption.text());
        if ($summary.data('sourceText') !== text) {
            $summary.data('sourceText', text);
            $summary.html(formatPoCaption(text));
        }
    }

    function hidePrimaryPagerActions(gridId) {
        var ids = [
            '#add_' + gridId,
            '#edit_' + gridId,
            '#del_' + gridId,
            '#refresh_' + gridId
        ];
        $(ids.join(',')).hide();

        // Export/print is intentionally moved out of the crowded pager. It remains
        // available from the three-dot menu because that menu proxies the old button.
        $('#' + gridId + '-pager .ui-pg-button[title="Trích Xuất Dữ Liệu"]').hide();
    }

    function createMasterActions() {
        var $actions = $('<div class="po-modern-actions"></div>');
        var $add = $('<button type="button" class="po-modern-action po-modern-action-primary"><span>＋</span> Thêm</button>');
        var $edit = $('<button type="button" class="po-modern-action">Sửa</button>');
        var $del = $('<button type="button" class="po-modern-action">Xóa</button>');
        var $moreWrap = $('<div class="po-modern-more-wrap"></div>');
        var $more = $('<button type="button" class="po-modern-action po-modern-more-button" title="Chức năng khác">•••</button>');

        $add.on('click.demoPo', function () { clickGridAction('grid_ds_po', 'add'); });
        $edit.on('click.demoPo', function () { clickGridAction('grid_ds_po', 'edit'); });
        $del.on('click.demoPo', function () { clickGridAction('grid_ds_po', 'del'); });

        $moreWrap.append($more);
        $actions.append($add, $edit, $del, $moreWrap);

        var excluded = {};
        excluded['add_grid_ds_po'] = true;
        excluded['edit_grid_ds_po'] = true;
        excluded['del_grid_ds_po'] = true;
        excluded['grid_ds_po-pager_center'] = true;
        var $menu = buildMoreMenu($moreWrap, 'grid_ds_po', excluded);

        $more.on('click.demoPo', function (event) {
            event.preventDefault();
            event.stopPropagation();
            $('.po-modern-more-menu').not($menu).hide();
            $menu.toggle();
        });

        return $actions;
    }

    function currentDetailGridId() {
        var index = $('#tabs-donhang-details').tabs('option', 'selected');
        if (index === 1) return 'grid_khoanphi';
        if (index === 2) return 'grid_ds_donhang_spdt';
        return 'grid_ds_chitietpo';
    }

    function rebuildDetailMoreMenu($wrap) {
        var gridId = currentDetailGridId();
        $wrap.find('.po-modern-more-menu').remove();
        var excluded = {};
        excluded['add_' + gridId] = true;
        excluded['edit_' + gridId] = true;
        excluded['del_' + gridId] = true;
        return buildMoreMenu($wrap, gridId, excluded);
    }

    function createDetailActions() {
        var $actions = $('<div class="po-modern-detail-actions"></div>');
        var $add = $('<button type="button" class="po-modern-action po-modern-action-primary"><span>＋</span> Thêm</button>');
        var $edit = $('<button type="button" class="po-modern-action">Sửa</button>');
        var $del = $('<button type="button" class="po-modern-action">Xóa</button>');
        var $moreWrap = $('<div class="po-modern-more-wrap"></div>');
        var $more = $('<button type="button" class="po-modern-action po-modern-more-button" title="Chức năng khác">•••</button>');

        $add.on('click.demoPo', function () { clickGridAction(currentDetailGridId(), 'add'); });
        $edit.on('click.demoPo', function () { clickGridAction(currentDetailGridId(), 'edit'); });
        $del.on('click.demoPo', function () { clickGridAction(currentDetailGridId(), 'del'); });

        $moreWrap.append($more);
        $actions.append($add, $edit, $del, $moreWrap);

        $more.on('click.demoPo', function (event) {
            event.preventDefault();
            event.stopPropagation();
            var $menu = rebuildDetailMoreMenu($moreWrap);
            $('.po-modern-more-menu').not($menu).hide();
            $menu.show();
        });

        return $actions;
    }

    function resizePoWorkspace() {
        var $master = $('#lay-center-po');
        var $details = $('#layout-south-po');
        if (!$master.length || !$details.length) return;

        try {
            var outerLayout = $master.parent().data('layout');
            if (outerLayout && outerLayout.sizePane) {
                var total = $master.parent().height();
                if (total > 300) {
                    outerLayout.sizePane('south', Math.round(total * 0.58));
                    outerLayout.resizeAll();
                }
            }
        } catch (ignoreOuter) { }

        try {
            var detailLayout = $details.data('layout');
            if (detailLayout && detailLayout.close) {
                detailLayout.close('east');
                if (detailLayout.resizeAll) detailLayout.resizeAll();
            }
        } catch (ignoreInner) { }

        var masterHeight = $master.height();
        if (masterHeight > 120 && $('#grid_ds_po').length) {
            $('#grid_ds_po').setGridHeight(Math.max(110, masterHeight - 72));
            $('#grid_ds_po').setGridWidth($master.width());
        }

        var $tabs = $('#tabs-donhang-details');
        var detailHeight = $tabs.height();
        var detailWidth = $tabs.width();
        if (detailHeight > 120 && detailWidth > 100) {
            $.each(['grid_ds_chitietpo', 'grid_khoanphi', 'grid_ds_donhang_spdt'], function (_, gridId) {
                var $grid = $('#' + gridId);
                if ($grid.length) {
                    $grid.setGridWidth(detailWidth);
                    $grid.setGridHeight(Math.max(110, detailHeight - 84));
                }
            });
        }
    }

    function enhancePoWorkspace() {
        var $grid = $('#grid_ds_po');
        var $gbox = $('#gbox_grid_ds_po');
        if (!$grid.length || !$gbox.length || $('#po-modern-toolbar').length) return false;

        $('#lay-center-po').addClass('po-modern-master');
        $('#layout-south-po').addClass('po-modern-detail-layout');
        $('#tabs-donhang-details').addClass('po-modern-details');

        var $toolbar = $('<div id="po-modern-toolbar" class="po-modern-toolbar"></div>');
        var $summary = $('<div id="po-modern-summary" class="po-modern-summary"></div>');
        $toolbar.append($summary, createMasterActions());
        $gbox.before($toolbar);

        $gbox.find('.ui-jqgrid-titlebar').hide();
        hidePrimaryPagerActions('grid_ds_po');

        var $detailActions = createDetailActions();
        $('#tabs-donhang-details').append($detailActions);

        $.each(['grid_ds_chitietpo', 'grid_khoanphi', 'grid_ds_donhang_spdt'], function (_, gridId) {
            hidePrimaryPagerActions(gridId);
        });

        $('#tabs-donhang-details').on('tabsshow.demoPo tabsselect.demoPo', function () {
            $('.po-modern-more-menu').hide();
            window.setTimeout(resizePoWorkspace, 0);
        });

        syncPoSummary();
        resizePoWorkspace();
        window.setTimeout(resizePoWorkspace, 150);
        window.setTimeout(resizePoWorkspace, 500);
        return true;
    }

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

                    var ribbonLeft = $ribbon.offset().left;
                    var buttonLeft = $li.offset().left;
                    var left = Math.max(0, buttonLeft - ribbonLeft);
                    var panelWidth = $panel.outerWidth() || 520;
                    var maxLeft = Math.max(0, $ribbon.innerWidth() - panelWidth - 8);

                    $panel.css('left', Math.min(left, maxLeft) + 'px').show();
                }
            });

            $contents.off('click.demoModern', '.items').on('click.demoModern', '.items', function () {
                closeRibbonMenus();
            });

            $(document).off('click.demoModernRibbon').on('click.demoModernRibbon', function (event) {
                if ($(event.target).closest('#ribbon').length === 0) {
                    closeRibbonMenus();
                }
                if ($(event.target).closest('.po-modern-more-wrap').length === 0) {
                    $('.po-modern-more-menu').hide();
                }
            });

            // P/O is Ajax-loaded into a workspace tab. A light polling hook keeps
            // this demo isolated from the legacy page and enhances the module once.
            window.setInterval(function () {
                if ($('#grid_ds_po').length) {
                    enhancePoWorkspace();
                    syncPoSummary();
                }
            }, 300);

            $(window).off('resize.demoModern').on('resize.demoModern', function () {
                closeRibbonMenus();
                $('.po-modern-more-menu').hide();
                window.setTimeout(resizePoWorkspace, 50);
            });
        }, 0);
    });
})(jQuery);
