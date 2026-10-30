/* Real, read-only PO -> Invoice allocation grids. No deposit writes in this phase. */
window.ancoPhanBoCocPO = (function ($) {
    "use strict";
    var enabled = false, initialized = false, invoiceId = null, invoiceState = "";
    var selectedPo = null, poRows = [], detailRows = [], request = null, serial = 0;
    function num(v) { v = Number(v); return isFinite(v) ? Math.round(v * 100) / 100 : 0; }
    function money(v) { return num(v).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ","); }
    function safe(v) { return $("<div/>").text(v == null ? "" : String(v)).html(); }
    function notice(s, error) { $("#anco-pb-warning").text(s || "").css("color", error ? "#a02323" : "#59636e"); }
    function currentPo() { for (var i = 0; i < poRows.length; i++) if (poRows[i].id === selectedPo) return poRows[i]; return null; }
    function clear() {
        $("#anco-pb-po-grid,#anco-pb-detail-grid").each(function () { $(this).jqGrid("clearGridData"); });
        $("#anco-pb-current-po").text("Chi tiết phân bổ");
        $("#anco-pb-sum").text("0.00");
    }
    function createGrids() {
        if (!$.fn.jqGrid) return false;
        $("#anco-pb-po-grid").jqGrid({
            datatype:"local", height:100, rowNum:1000, gridview:true,
            colNames:["PO","Cọc gốc","Đã PB (hiệu lực)","Cọc còn"],
            colModel:[
                {name:"code",width:170,sortable:false},
                {name:"deposited",width:120,align:"right",sortable:false},
                {name:"allocated",width:125,align:"right",sortable:false},
                {name:"remaining",width:120,align:"right",sortable:false}
            ],
            onSelectRow:function(id) { selectedPo=id; drawDetails(); }
        });
        $("#anco-pb-detail-grid").jqGrid({
            datatype:"local", height:100, rowNum:1000, gridview:true,
            colNames:["STT","Tiền cọc trước PB","Tiền phân bổ","Tiền cọc sau PB","Ngày tạo","Người tạo"],
            colModel:[
                {name:"line",width:45,sortable:false,align:"center"},
                {name:"before",width:145,sortable:false,align:"right"},
                {name:"amount",width:145,sortable:false,align:"right"},
                {name:"after",width:145,sortable:false,align:"right"},
                {name:"createdAt",width:125,sortable:false},
                {name:"createdBy",width:100,sortable:false}
            ]
        });
        return true;
    }
    function drawDetails() {
        var g=$("#anco-pb-detail-grid"), po=currentPo();
        g.jqGrid("clearGridData");
        $("#anco-pb-current-po").text(po ? "Chi tiết phân bổ — "+po.code : "Chi tiết phân bổ");
        if (!po) return;
        // Effective Invoice's own amount is already included in the active sum.
        var balance=num(po.remaining) + (invoiceState==="HIEULUC" ? num(po.currentAllocated) : 0), idx=0;
        $.each(detailRows,function(i,row) {
            if (row.poId!==po.id) return;
            var before=balance, amount=num(row.amount); balance=num(balance-amount); idx++;
            g.jqGrid("addRowData",row.id,{
                line:idx,before:money(before),amount:money(amount),after:money(balance),
                createdAt:safe(row.createdAt),createdBy:safe(row.createdBy)
            });
        });
    }
    function draw() {
        var g=$("#anco-pb-po-grid"); g.jqGrid("clearGridData");
        $.each(poRows,function(i,po){
            g.jqGrid("addRowData",po.id,{
                code:safe(po.code),deposited:money(po.deposited),
                allocated:money(po.allocated),remaining:money(po.remaining)
            });
        });
        if (!currentPo()) selectedPo=poRows.length ? poRows[0].id : null;
        if (selectedPo) g.jqGrid("setSelection",selectedPo,false);
        drawDetails(); resize();
    }
    function load() {
        serial++; var ticket=serial;
        if(request && request.readyState!==4) request.abort();
        poRows=[];detailRows=[];selectedPo=null;invoiceState="";clear();
        if(!invoiceId || invoiceId==="0"){
            $("#anco-pb-invoice-label").text("Chưa chọn Invoice");
            $("#anco-pb-invoice-state").text("—");
            notice("Chọn Invoice ở lưới phía trên để xem dữ liệu.",false);return;
        }
        $("#anco-pb-invoice-label").text("Đang tải Invoice...");
        $("#anco-pb-invoice-state").text("Đang tải");
        notice("Đang tải dữ liệu từ SQL Server...",false);
        request=$.ajax({
            url:"Views/phanbococpo/Controller_PhanBoCocPO.ashx",
            type:"GET",dataType:"json",cache:false,
            data:{action:"load",invoiceId:invoiceId},
            success:function(data){
                if(ticket!==serial)return;
                if(!data || !data.ok){notice(data&&data.message ? data.message:"Dữ liệu trả về không hợp lệ.",true);return;}
                poRows=data.po||[]; detailRows=data.details||[];
                invoiceState=data.invoice&&data.invoice.status ? data.invoice.status:"";
                $("#anco-pb-invoice-state").text(invoiceState||"Không xác định");
                $("#anco-pb-invoice-label").text("Invoice: "+(data.invoice&&data.invoice.number ? data.invoice.number:invoiceId));
                var total=0; $.each(detailRows,function(i,r){total+=num(r.amount);});
                $("#anco-pb-sum").text(money(total));
                notice(poRows.length ? "":"Invoice này không có dòng hàng liên kết PO.",false);
                draw();
            },
            error:function(xhr,status){
                if(ticket!==serial||status==="abort")return;
                var data=xhr.responseJSON;
                if(!data){try{data=$.parseJSON(xhr.responseText);}catch(ignored){}}
                $("#anco-pb-invoice-label").text("Không tải được Invoice");
                $("#anco-pb-invoice-state").text("Lỗi");
                notice(data&&data.message ? data.message:"Không thể tải dữ liệu. Kiểm tra API và CSDL.",true);
            }
        });
    }
    function setInvoice(id) {
        if(!enabled||!initialized)return;
        var next=id==null?null:String(id);
        if(next===invoiceId)return;
        invoiceId=next;load();
    }
    function syncInvoice() {
        if(!enabled||!initialized)return;
        var id=null;
        try{
            var g=$("#grid_ds_ctxkNV");
            if(g[0]&&g[0].grid) id=g.jqGrid("getGridParam","selrow");
        }catch(ignored){}
        setInvoice(id);
    }
    function resize() {
        if(!enabled||!initialized)return;
        var panel=$("#nav-tabs-pklivn-pb"), tabs=$("#tabs-ctxkNV-details");
        if(!panel.is(":visible")||!tabs.length)return;
        var available=tabs.height()-tabs.children("ul.ui-tabs-nav").outerHeight(true);
        if(available>0)panel.css("height",Math.floor(available)+"px");
        panel.find(".anco-pb-grid-wrap").each(function(){
            var wrap=$(this),table=wrap.find("table.ui-jqgrid-btable").first();
            if(!table.length)return;
            var grid=table.closest(".ui-jqgrid"),head=grid.find(".ui-jqgrid-hdiv").first(),foot=grid.find(".ui-jqgrid-sdiv").first();
            var h=Math.max(0,Math.floor(wrap.innerHeight()-(head.length?head.outerHeight(true):0)-(foot.length?foot.outerHeight(true):0)-4));
            var w=Math.max(0,Math.floor(wrap.innerWidth())-2);
            if(w>0)table.jqGrid("setGridWidth",w);
            table.jqGrid("setGridHeight",h);
        });
    }
    function init() {
        enabled=/(?:\?|&)phanbococ_preview=1(?:&|$)/.test(window.location.search);
        if(!enabled||initialized||!$("#nav-tabs-pklivn-pb").length)return;
        initialized=createGrids();
        if(!initialized){notice("Không tải được jqGrid.",true);return;}
        $("#tabs-ctxkNV-details .anco-pb-preview-tab").css("display","list-item");
        $("#tabs-ctxkNV-details").bind("tabsshow.ancoPb tabsactivate.ancoPb",function(evt,ui){
            if(ui.panel&&ui.panel.id==="nav-tabs-pklivn-pb")syncInvoice();
            window.setTimeout(resize,0);
        });
        $("#anco-pb-add,#anco-pb-save").prop("disabled",true);
        syncInvoice();window.setTimeout(resize,0);
    }
    return {init:init,setInvoice:setInvoice,syncInvoice:syncInvoice,resize:resize};
}(jQuery));
