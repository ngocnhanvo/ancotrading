/* PO -> Invoice deposit allocation: UI preview only.
 * This module MUST NOT send writes or treat example rows as business data.
 * Server validation, draft persistence, activation and reversal are future phases.
 */
window.ancoPhanBoCocPO = (function ($) {
    "use strict";
    var initialized = false, enabled = false, invoiceId = null, selectedPo = null, state = "SOANTHAO";
    var sample = [
        { id: "demo1", code: "PO-DEMO-001", deposited: 10000, allocated: 4000, rows: [{ id: 1, amount: 1000 }, { id: 2, amount: 1500 }] },
        { id: "demo2", code: "PO-DEMO-002", deposited: 8000, allocated: 1000, rows: [{ id: 3, amount: 2000 }] },
        { id: "demo3", code: "PO-DEMO-003", deposited: 5000, allocated: 5000, rows: [] }
    ];
    var nextRow = 4;
    function money(value) { return (Math.round(Number(value) * 100) / 100).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ","); }
    function rounded(value) { return Math.round(Number(value) * 100) / 100; }
    function currentPO() {
        for (var i = 0; i < sample.length; i++) if (sample[i].id === selectedPo) return sample[i];
        return null;
    }
    function remaining(po) { return rounded(po.deposited - po.allocated); }
    function sumRows(po) {
        var sum = 0;
        $.each(po.rows, function (i, row) { sum += row.amount; });
        return rounded(sum);
    }
    function warning(message) { $("#anco-pb-warning").text(message || ""); }
    function hasInvoice() { return invoiceId !== null && invoiceId !== "" && invoiceId !== "0"; }
    function buildGrids() {
        if (!$.fn.jqGrid) { warning("Không tải được jqGrid. Vui lòng kiểm tra thư viện."); return false; }
        $("#anco-pb-po-grid").jqGrid({
            datatype: "local", height: 180, rowNum: 1000, viewrecords: false, gridview: true,
            colNames: ["PO", "Cọc gốc", "Đã phân bổ", "Cọc còn"],
            colModel: [
                { name: "code", index: "code", width: 124, sortable: false },
                { name: "deposited", width: 94, align: "right", sortable: false },
                { name: "allocated", width: 94, align: "right", sortable: false },
                { name: "remaining", width: 94, align: "right", sortable: false }
            ],
            onSelectRow: function (id) { selectedPo = id; warning(""); drawDetails(); }
        });
        $("#anco-pb-detail-grid").jqGrid({
            datatype: "local", height: 180, rowNum: 1000, viewrecords: false, gridview: true,
            colNames: ["STT", "Cọc trước PB", "Tiền phân bổ", "Cọc sau PB", "Thao tác"],
            colModel: [
                { name: "line", width: 44, sortable: false, align: "center" },
                { name: "before", width: 127, sortable: false, align: "right" },
                { name: "amount", width: 145, sortable: false, align: "right" },
                { name: "after", width: 127, sortable: false, align: "right" },
                { name: "actions", width: 65, sortable: false, align: "center" }
            ]
        });
        return true;
    }
    function drawPOs() {
        var $grid = $("#anco-pb-po-grid"), total = 0;
        $grid.jqGrid("clearGridData");
        if (!hasInvoice()) {
            selectedPo = null;
            $("#anco-pb-sum").text("0.00");
            drawDetails();
            return;
        }
        $.each(sample, function (i, po) {
            total += sumRows(po);
            $grid.jqGrid("addRowData", po.id, {
                code: po.code, deposited: money(po.deposited), allocated: money(po.allocated), remaining: money(remaining(po))
            });
        });
        if (!selectedPo) selectedPo = sample[0].id;
        $grid.jqGrid("setSelection", selectedPo, false);
        $("#anco-pb-sum").text(money(total));
        drawDetails();
    }
    function drawDetails() {
        var $grid = $("#anco-pb-detail-grid"), po = currentPO();
        $grid.jqGrid("clearGridData");
        $("#anco-pb-current-po").text(po && hasInvoice() ? "Chi tiết phân bổ — " + po.code : "Chi tiết phân bổ");
        $("#anco-pb-add").prop("disabled", !po || !hasInvoice() || state !== "SOANTHAO" || sumRows(po) >= remaining(po));
        if (!po || !hasInvoice()) return;
        var before = remaining(po);
        $.each(po.rows, function (i, row) {
            var after = rounded(before - row.amount);
            var field = state === "SOANTHAO"
                ? '<input type="text" class="anco-pb-cell-input" data-row="' + row.id + '" value="' + money(row.amount) + '" aria-label="Tiền phân bổ dòng ' + (i + 1) + '"/>'
                : money(row.amount);
            var action = state === "SOANTHAO"
                ? '<button type="button" class="anco-pb-delete" data-row="' + row.id + '">Xóa</button>'
                : "Đã khóa";
            $grid.jqGrid("addRowData", "line" + row.id, {
                line: i + 1, before: money(before), amount: field, after: money(after), actions: action
            });
            before = after;
        });
    }
    function setInvoice(id) {
        if (!enabled || !initialized) return;
        invoiceId = (id === undefined || id === null) ? null : String(id);
        selectedPo = null;
        var label = "Chưa chọn Invoice";
        if (hasInvoice()) {
            try {
                var data = $("#grid_ds_ctxkNV").jqGrid("getRowData", invoiceId);
                label = "Invoice: " + (data.so_inv || data.so_pkl || invoiceId);
            } catch (e) { label = "Invoice đã chọn"; }
        }
        $("#anco-pb-invoice-label").text(label);
        warning("");
        drawPOs();
    }
    function resize() {
        if (!enabled || !initialized) return;
        var $panel = $("#nav-tabs-pklivn-pb"), $tabs = $("#tabs-ctxkNV-details");
        if (!$panel.is(":visible") || !$tabs.length) return;

        // The jQuery Layout center height includes the tabs navigation bar.
        // The content panel must consume only the space BELOW that bar;
        // height:100% alone would push the summary/buttons underneath the footer.
        var $navigation = $tabs.children("ul.ui-tabs-nav");
        var available = $tabs.height() - $navigation.outerHeight(true);
        if (available > 0) $panel.css("height", Math.floor(available) + "px");

        // The flex middle section now fills whatever remains after the header,
        // preview notice, warning and summary. Only jqGrid's BODY scrolls.
        $panel.find(".anco-pb-grid-wrap").each(function () {
            var $wrap = $(this), $table = $wrap.find("table.ui-jqgrid-btable").first();
            if (!$table.length) return;
            var width = Math.max(0, Math.floor($wrap.innerWidth()) - 2);
            var $grid = $table; // jqGrid body table, not the header's table
            var $wrapper = $grid.closest(".ui-jqgrid");
            var $header = $wrapper.find(".ui-jqgrid-hdiv").first();
            var $footer = $wrapper.find(".ui-jqgrid-sdiv").first();
            var headerHeight = $header.length ? $header.outerHeight(true) : 0;
            var footerHeight = $footer.length ? $footer.outerHeight(true) : 0;
            var height = Math.max(0, Math.floor($wrap.innerHeight() - headerHeight - footerHeight - 4));
            if (width > 0) $grid.jqGrid("setGridWidth", width);
            $grid.jqGrid("setGridHeight", height);
        });
    }
    function init() {
        enabled = /(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search);
        if (!enabled || initialized || !$("#nav-tabs-pklivn-pb").length) return;
        initialized = buildGrids();
        if (!initialized) return;
        $("#tabs-ctxkNV-details .anco-pb-preview-tab").css("display", "list-item");
        var $tabs = $("#tabs-ctxkNV-details");
        $tabs.bind("tabsshow.ancoPb tabsactivate.ancoPb", function () { window.setTimeout(resize, 0); });
        $("#anco-pb-preview-state").bind("change.ancoPb", function () {
            state = $(this).val();
            warning("");
            drawDetails();
        });
        $("#anco-pb-add").bind("click.ancoPb", function () {
            var po = currentPO();
            if (!po || !hasInvoice() || state !== "SOANTHAO" || sumRows(po) >= remaining(po)) return;
            po.rows.push({ id: nextRow++, amount: 0 });
            warning("");
            drawDetails();
            $("#anco-pb-detail-grid .anco-pb-cell-input").last().focus();
        });
        $("#anco-pb-detail-grid").delegate(".anco-pb-cell-input", "change.ancoPb", function () {
            if (state !== "SOANTHAO") return;
            var po = currentPO(), rowId = Number($(this).attr("data-row"));
            if (!po) return;
            var raw = $.trim($(this).val()).replace(/,/g, "");
            var amount = Number(raw), row = null;
            for (var i = 0; i < po.rows.length; i++) if (po.rows[i].id === rowId) { row = po.rows[i]; break; }
            if (!row) return;
            var withoutCurrent = rounded(sumRows(po) - row.amount);
            if (!/^\d+(\.\d{1,2})?$/.test(raw) || !isFinite(amount) || rounded(withoutCurrent + amount) > remaining(po)) {
                warning("Số tiền phân bổ phải không âm, tối đa 2 số lẻ và không vượt số cọc còn lại của PO.");
                drawDetails(); return;
            }
            row.amount = rounded(amount);
            warning("");
            drawPOs();
        });
        $("#anco-pb-detail-grid").delegate(".anco-pb-delete", "click.ancoPb", function () {
            if (state !== "SOANTHAO") return;
            var po = currentPO(), rowId = Number($(this).attr("data-row"));
            if (!po) return;
            po.rows = $.grep(po.rows, function (row) { return row.id !== rowId; });
            warning("");
            drawPOs();
        });
        drawPOs();
        var selectedInvoice = null;
        try {
            if ($("#grid_ds_ctxkNV")[0] && $("#grid_ds_ctxkNV")[0].grid)
                selectedInvoice = $("#grid_ds_ctxkNV").jqGrid("getGridParam", "selrow");
        } catch (e) { selectedInvoice = null; }
        setInvoice(selectedInvoice);
        window.setTimeout(resize, 0);
    }
    return { init: init, setInvoice: setInvoice, resize: resize };
}(jQuery));
