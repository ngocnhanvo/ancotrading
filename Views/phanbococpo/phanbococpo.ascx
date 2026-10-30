<%@ Control Language="C#" AutoEventWireup="true" CodeFile="phanbococpo.ascx.cs" Inherits="Views_phanbococpo_phanbococpo" %>
<%-- Preview-only UI until the server allocation workflow and checks are complete. --%>
<link rel="stylesheet" type="text/css" href="Views/phanbococpo/phanbococpo.css?v=20261030e" />
<%-- JS is explicitly loaded by inc-ctxkNV.aspx after the AJAX tab has been inserted. --%>
<div id="nav-tabs-pklivn-pb" class="anco-pb" role="region" aria-label="Phân bổ tiền cọc theo PO">
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
                    <span class="anco-pb-invoice-state">Trạng thái: <strong id="anco-pb-invoice-state">—</strong></span>
                    <button type="button" id="anco-pb-add" disabled="disabled">+ Thêm dòng</button>
                </span>
            </div>
            <div class="anco-pb-grid-wrap"><table id="anco-pb-detail-grid"></table></div>
            <div id="anco-pb-warning" role="alert" aria-live="polite"></div>
        </section>
    </div>
    <div class="anco-pb-bottom">
        <span>Tổng phân bổ vào Invoice (dự kiến): <strong id="anco-pb-sum">0.00</strong></span>
        <button type="button" id="anco-pb-save" disabled="disabled" title="Chưa triển khai ghi dữ liệu và kiểm tra số dư khi hiệu lực">Lưu (PB) — chưa kết nối</button>
    </div>
</div>
