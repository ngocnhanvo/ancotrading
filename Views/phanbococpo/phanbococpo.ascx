<%@ Control Language="C#" AutoEventWireup="true" CodeFile="phanbococpo.ascx.cs" Inherits="Views_phanbococpo_phanbococpo" %>
<%-- Preview-only UI until the server allocation workflow and checks are complete. --%>
<link rel="stylesheet" type="text/css" href="Views/phanbococpo/phanbococpo.css?v=20261030" />
<script type="text/javascript" src="Views/phanbococpo/phanbococpo.js?v=20261030"></script>
<div id="nav-tabs-pklivn-pb" class="anco-pb" role="region" aria-label="Phân bổ tiền cọc theo PO">
    <div class="anco-pb-titlebar">
        <strong>Phân bổ tiền đặt cọc từ PO vào Invoice</strong>
        <span id="anco-pb-invoice-label">Chưa chọn Invoice</span>
        <label>Trạng thái thử nghiệm:
            <select id="anco-pb-preview-state"><option value="SOANTHAO">Soạn thảo</option><option value="HIEULUC">Hiệu lực</option></select>
        </label>
    </div>
    <div class="anco-pb-preview-alert" role="status">
        <strong>BẢN XEM TRƯỚC.</strong> Dữ liệu PO và tiền cọc bên dưới chỉ minh họa, không lấy từ cơ sở dữ liệu.
        Các thay đổi không lưu; chưa kết nối chức năng phân bổ thật.
    </div>
    <div class="anco-pb-main">
        <section class="anco-pb-panel anco-pb-left" aria-label="Danh sách PO có cọc">
            <div class="anco-pb-panel-title">Danh sách PO thuộc Invoice</div>
            <div class="anco-pb-grid-wrap"><table id="anco-pb-po-grid"></table></div>
        </section>
        <section class="anco-pb-panel anco-pb-right" aria-label="Chi tiết dòng phân bổ">
            <div class="anco-pb-panel-title">
                <span id="anco-pb-current-po">Chi tiết phân bổ</span>
                <button type="button" id="anco-pb-add" disabled="disabled">+ Thêm dòng</button>
            </div>
            <div class="anco-pb-grid-wrap"><table id="anco-pb-detail-grid"></table></div>
            <div id="anco-pb-warning" role="alert" aria-live="polite"></div>
        </section>
    </div>
    <div class="anco-pb-bottom">
        <span>Tổng phân bổ vào Invoice (dự kiến): <strong id="anco-pb-sum">0.00</strong></span>
        <button type="button" id="anco-pb-save" disabled="disabled" title="Chỉ bật sau khi hoàn thành API và kiểm tra nghiệp vụ">Lưu (PB) — chưa kết nối</button>
    </div>
</div>
