/* Real, read-only PO -> Invoice allocation grids. No deposit writes in this phase. */
window.ancoPhanBoCocPO = (function ($) {
    "use strict";
    var enabled = false, initialized = false, invoiceId = null, invoiceState = "";
    var selectedPo = null, poRows = [], detailRows = [], request = null, serial = 0;
    var mountedGridNode = null;
    var editableRows = [], version = "", dirty = false, saving = false, tempId = 0;
    function saveAllowed() {
        return $("#anco-pb-write-enabled").val() === "true" && invoiceState === "SOANTHAO";
    }
    function totalForPo(id) {
        var sum = 0;
        $.each(editableRows, function(i,r) { if(r.poId===id) sum += num(r.amount); });
        return num(sum);
    }
    function sumAll() {
        var total = 0;
        $.each(editableRows, function(i,r) { total += num(r.amount); });
        $("#anco-pb-sum").text(money(total));
    }
    function refreshButtons() {
        var po = currentPo(), eligible = saveAllowed() && !saving;
        $("#anco-pb-add").prop("disabled", !eligible || !po || totalForPo(po.id) >= num(po.remaining) || editableRows.length >= 100);
        $("#anco-pb-save").prop("disabled", !eligible || !dirty);
        $("#anco-pb-save").text(saving ? "Đang lưu..." : "Lưu (PB)");
    }
    function num(v) { v = Number(v); return isFinite(v) ? Math.round(v * 100) / 100 : 0; }
    function money(v) { return num(v).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ","); }
    function safe(v) { return $("<div/>").text(v == null ? "" : String(v)).html(); }
    function notice(s, error) { $("#anco-pb-warning").text(s || "").css("color", error ? "#a02323" : "#59636e"); }
    function currentPo() { for (var i = 0; i < poRows.length; i++) if (poRows[i].id === selectedPo) return poRows[i]; return null; }
    function clear() {
        $("#anco-pb-po-grid,#anco-pb-detail-grid").each(function () { $(this).jqGrid("clearGridData"); });
        $("#anco-pb-current-po").text("Chi tiết phân bổ");
        $("#anco-pb-sum").text("0.00");
        refreshButtons();
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
            colNames:["STT","Tiền cọc trước PB","Tiền phân bổ","Tiền cọc sau PB","Ngày tạo","Người tạo","Thao tác"],
            colModel:[
                {name:"line",width:45,sortable:false,align:"center"},
                {name:"before",width:145,sortable:false,align:"right"},
                {name:"amount",width:145,sortable:false,align:"right"},
                {name:"after",width:145,sortable:false,align:"right"},
                {name:"createdAt",width:125,sortable:false},
                {name:"createdBy",width:100,sortable:false},
                {name:"actions",width:74,sortable:false,align:"center"}
            ]
        });
        return true;
    }
    function drawDetails() {
        var g=$("#anco-pb-detail-grid"), po=currentPo();
        g.jqGrid("clearGridData");
        $("#anco-pb-current-po").text(po ? "Chi tiết phân bổ — "+po.code : "Chi tiết phân bổ");
        if (!po) { refreshButtons(); return; }
        var balance=num(po.remaining) + (invoiceState==="HIEULUC" ? num(po.currentAllocated) : 0), idx=0;
        $.each(editableRows,function(i,row) {
            if (row.poId!==po.id) return;
            var amount=num(row.amount), before=balance, editable=saveAllowed();
            balance=num(balance-amount); idx++;
            var input = editable
                ? '<input class="anco-pb-cell-input" data-row="'+safe(row.id)+'" type="text" value="'+amount.toFixed(2)+'" aria-label="Tiền phân bổ dòng '+idx+'"/>'
                : money(amount);
            var remove = editable
                ? '<button type="button" class="anco-pb-delete" data-row="'+safe(row.id)+'">Xóa</button>' : "";
            g.jqGrid("addRowData",row.id,{
                line:idx,before:money(before),amount:input,after:money(balance),
                createdAt:safe(row.createdAt||""),createdBy:safe(row.createdBy||""),actions:remove
            });
        });
        refreshButtons();
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
        drawDetails(); sumAll(); resize();
    }
    function load() {
        serial++; var ticket=serial;
        if(request && request.readyState!==4) request.abort();
        poRows=[];detailRows=[];editableRows=[];selectedPo=null;invoiceState="";dirty=false;version="";clear();
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
            data:{action:"load",invoiceId:invoiceId,diagnostic:1},
            success:function(data){
                if(ticket!==serial)return;
                if(!data || !data.ok){notice(data&&data.message ? data.message:"Dữ liệu trả về không hợp lệ.",true);return;}
                poRows=data.po||[]; detailRows=data.details||[];
                editableRows=$.map(detailRows,function(r){return $.extend({},r);});
                version=data.version||""; dirty=false;
                invoiceState=data.invoice&&data.invoice.status ? data.invoice.status:"";
                $("#anco-pb-invoice-state").text(invoiceState||"Không xác định");
                $("#anco-pb-invoice-label").text(data.invoice&&data.invoice.number ? data.invoice.number:invoiceId);
                sumAll();
                notice(poRows.length ? "":"Invoice này không có dòng hàng liên kết PO.",false);
                draw();
            },
            error:function(xhr,status){
                if(ticket!==serial||status==="abort")return;
                var data=xhr.responseJSON;
                if(!data){try{data=$.parseJSON(xhr.responseText);}catch(ignored){}}
                $("#anco-pb-invoice-label").text("Không tải được Invoice");
                $("#anco-pb-invoice-state").text("Lỗi");
                var detail=data&&data.diagnostic;
                var suffix=detail ? " [bước: "+detail.stage+"; SQL #"+detail.sqlNumber+"]" : "";
                notice((data&&data.message ? data.message:"Không thể tải dữ liệu. Kiểm tra API và CSDL.")+suffix,true);
            }
        });
    }
    function setInvoice(id) {
        if(!initialized)init();
        if(!enabled||!initialized)return;
        var next=id==null?null:String(id);
        if(next===invoiceId)return;
        if(dirty && !window.confirm("Phân bổ chưa lưu sẽ bị hủy khi chuyển Invoice. Tiếp tục?")) {
            try { $("#grid_ds_ctxkNV").jqGrid("setSelection",invoiceId,false); } catch(ignored) {}
            return;
        }
        invoiceId=next;load();
    }
    function syncInvoice() {
        if(!initialized)init();
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
        var currentNode = $("#anco-pb-po-grid")[0];
        if(!enabled||!currentNode||!$("#nav-tabs-pklivn-pb").length)return;
        // The outer AJAX tab may be closed and reopened: the old jqGrid node
        // is gone even though the JS module still exists on window.
        if(initialized && mountedGridNode===currentNode)return;
        if(request && request.readyState!==4) request.abort();
        initialized=false;invoiceId=null;selectedPo=null;poRows=[];detailRows=[];editableRows=[];dirty=false;version="";
        mountedGridNode=currentNode;
        initialized=createGrids();
        if(!initialized){notice("Không tải được jqGrid.",true);return;}
        $("#tabs-ctxkNV-details .anco-pb-preview-tab").css("display","list-item");
        $("#tabs-ctxkNV-details").bind("tabsshow.ancoPb tabsactivate.ancoPb",function(evt,ui){
            if(ui.panel&&ui.panel.id==="nav-tabs-pklivn-pb")syncInvoice();
            window.setTimeout(resize,0);
        });
        // All edits are local until one atomic server-side draft save succeeds.
        $("#anco-pb-add,#anco-pb-save").prop("disabled",true);
        $("#anco-pb-add").off("click.ancoPb").on("click.ancoPb",function() {
            var po=currentPo();
            if(!saveAllowed()||!po||editableRows.length>=100)return;
            if(totalForPo(po.id)>=num(po.remaining)){notice("PO đã hết tiền cọc.",true);return;}
            editableRows.push({id:"tmp-"+(++tempId),poId:po.id,amount:0,createdAt:"",createdBy:""});
            dirty=true;drawDetails();sumAll();
            $("#anco-pb-detail-grid input.anco-pb-cell-input").last().focus();
        });
        $("#anco-pb-detail-grid").off("change.ancoPb").on("change.ancoPb","input.anco-pb-cell-input",function(){
            if(!saveAllowed())return;
            var id=$(this).attr("data-row"),str=$.trim($(this).val()).replace(/,/g,"");
            if(!/^\d+(\.\d{1,2})?$/.test(str)||Number(str)<=0){notice("Số tiền phân bổ phải lớn hơn 0, tối đa 2 số lẻ.",true);return;}
            var row=null;
            $.each(editableRows,function(i,r){if(r.id===id){row=r;return false;}});
            if(!row)return;
            var po=currentPo(),amount=num(str);
            if(totalForPo(po.id)-num(row.amount)+amount>num(po.remaining)){
                notice("Tiền phân bổ vượt cọc còn lại của PO.",true);return;
            }
            row.amount=amount;dirty=true;notice("",false);drawDetails();sumAll();
        });
        $("#anco-pb-detail-grid").off("click.ancoPb").on("click.ancoPb","button.anco-pb-delete",function(){
            if(!saveAllowed())return;
            var id=$(this).attr("data-row");
            editableRows=$.grep(editableRows,function(r){return r.id!==id;});
            dirty=true;notice("",false);drawDetails();sumAll();
        });
        $("#anco-pb-save").off("click.ancoPb").on("click.ancoPb",function(){
            if(!saveAllowed()||!dirty||saving)return;
            var totals={},valid=true;
            $.each(editableRows,function(i,r){
                var po=null;
                $.each(poRows,function(j,p){if(p.id===r.poId){po=p;return false;}});
                if(!po||num(r.amount)<=0||num(r.amount)!==Number(r.amount)){valid=false;return false;}
                totals[r.poId]=num((totals[r.poId]||0)+num(r.amount));
                if(totals[r.poId]>num(po.remaining)){valid=false;return false;}
            });
            if(!valid){notice("Có dòng phân bổ chưa nhập đúng số tiền hoặc vượt số dư PO.",true);return;}
            if(!window.confirm("Lưu "+editableRows.length+" dòng phân bổ bản nháp cho Invoice này?"))return;
            saving=true;refreshButtons();notice("Đang lưu bản nháp...",false);
            $.ajax({
                url:"Views/phanbococpo/Controller_PhanBoCocPO.ashx",
                type:"POST",dataType:"json",
                data:{action:"save",invoiceId:invoiceId,version:version,
                    csrf:$("#anco-pb-csrf").val(),
                    rows:JSON.stringify($.map(editableRows,function(r){return {id:r.id,poId:r.poId,amount:num(r.amount)};}))},
                success:function(result){
                    saving=false;
                    if(result&&result.ok){notice("Đã lưu bản nháp thành công.",false);load();}
                    else {refreshButtons();notice(result&&result.message||"Không thể lưu bản nháp.",true);}
                },
                error:function(xhr){
                    saving=false;refreshButtons();
                    var result=xhr.responseJSON;
                    if(!result){try{result=$.parseJSON(xhr.responseText);}catch(e){}}
                    notice(result&&result.message ? result.message:"Không thể lưu bản nháp. Kiểm tra server.",true);
                    if(result&&result.code==="stale_allocation")load();
                }
            });
        });
        syncInvoice();window.setTimeout(resize,0);
    }
    return {init:init,setInvoice:setInvoice,syncInvoice:syncInvoice,resize:resize};
}(jQuery));
