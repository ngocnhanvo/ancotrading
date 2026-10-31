<%@ Control Language="C#" AutoEventWireup="true" CodeFile="phanbococpo.ascx.cs" Inherits="Views_phanbococpo_phanbococpo" %>
<link rel="stylesheet" type="text/css" href="Views/phanbococpo/phanbococpo.css?v=20261031-write" />
<%-- JS is explicitly loaded by inc-ctxkNV.aspx after the AJAX tab has been inserted. --%>
<div id="nav-tabs-pklivn-pb" class="anco-pb" role="region" aria-label="Phân bổ tiền cọc theo PO">
    <input type="hidden" id="anco-pb-csrf" value="<%= HttpUtility.HtmlAttributeEncode(AllocationToken) %>" />
    <div class="anco-pb-main">
        <section class="anco-pb-panel anco-pb-left" aria-label="Danh sách PO có cọc">
            <div class="anco-pb-panel-title">
                <span>Danh sách PO thuộc Invoice: <strong id="anco-pb-invoice-label">Chưa chọn</strong></span>
            </div>
            <div class="anco-pb-grid-wrap"><table id="anco-pb-po-grid"></table></div>
        </section>
        <section class="anco-pb-panel anco-pb-right" aria-label="Chi tiết dòng phân bổ">
            <div class="anco-pb-panel-title">
                <span id="anco-pb-current-po">Chi tiết phân bổ</span>
                <span class="anco-pb-header-actions">
                    <span class="anco-pb-po-summary">Dự kiến PB PO: <strong id="anco-pb-po-sum">0.00</strong></span>
                    <span class="anco-pb-invoice-state">Trạng thái: <strong id="anco-pb-invoice-state">—</strong></span>
                    <button type="button" id="anco-pb-add" disabled="disabled">+ Thêm dòng</button>
                </span>
            </div>
            <div class="anco-pb-grid-wrap"><table id="anco-pb-detail-grid"></table></div>
            <div id="anco-pb-lock-reason" role="status" aria-live="polite" style="display:none"></div>
            <div id="anco-pb-warning" role="alert" aria-live="polite"></div>
        </section>
    </div>
    <div class="anco-pb-bottom">
        <button type="button" id="anco-pb-save" disabled="disabled" title="Chỉ lưu bản nháp, chưa ghi nhận hiệu lực">Lưu (PB)</button>
    </div>
</div>
