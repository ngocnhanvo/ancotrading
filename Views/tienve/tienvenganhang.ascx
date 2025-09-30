<%@ Control Language="C#" AutoEventWireup="true" CodeFile="tienvenganhang.ascx.cs" Inherits="Views_tienve_tienvenganhang" %>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="tienve-details-2">
<uc1:jqGrid  ID="grid_ds_tienvenganhang" 
    FilterToolbar="true"
    UrlFileAction="Views/tienve/Controller_TienVe_NganHang.ashx"
    RowNumbers="true"
    OndblClickRow = "function(){ $('#edit_grid_ds_tienvenganhang').click(); }"
    ColModel="
        [
            {
                name: 'md_taptin_id'
                , label: 'md_taptin_id'
                , index: 'md_taptin_id'
                , fixed:true 
                , width: 100
                , hidden: true 
                , editable:true
                , edittype: 'text'
                , key: true
            },
            {
                name: 'tentaptin'
                , label: 'Tên tập tin'
                , index: 'tt.tentaptin'
                , fixed:true 
                , width: 140
                , edittype: 'text'
                , editable: false
                , hidden: false
            },
            {
                name: 'mimetype'
                , label: 'Loại'
                , index: 'tt.mimetype'
                , editable: false
                , fixed:true 
                , width: 60
                , edittype: 'text'
                , align: 'center'
            },
            {
                name: 'size'
                , label: 'Kích thước'
                , index: 'tt.size'
                , editable: false
                , fixed:true 
                , width: 80
                , edittype: 'text'
                , editoptions:{ defaultValue: '0' }
                , editrules: { required:true, number:true, minValue: 0 }
                , align: 'right'
                , formatter: formatBytes
                , unformat: disable_formatter
            },
            {
                name: 'path'
                , label: 'Tải về'
                , index: 'tt.path'
                , editable: false
                , fixed:true 
                , width: 50
                , edittype: 'text'
                , align: 'center'
                , formatter: download
                , unformat: disable_formatter
            },
            {
                name: 'ngaytao'
                , label: 'Ngày tạo'
                , index: 'tt.ngaytao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoitao'
                , label: 'Người thêm file'
                , index: 'tt.nguoitao'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'ngaycapnhat'
                , label: 'Ngày cập nhật'
                , index: 'tt.ngaycapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: false
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                name: 'nguoicapnhat'
                , label: 'Người cập nhật'
                , index: 'tt.nguoicapnhat'
                , fixed:true 
                , width: 100
                , editable:false
                , edittype: 'text'
                , hidden: true 
                , editrules:{ edithidden : true }
                , align: 'center'
            },
            {
                fixed: true, name: 'mota'
                , label: 'Mô tả'
                , index: 'tt.mota'
                , width: 100
                , editable:true
                , edittype: 'textarea'
				, hidden: false
				, editrules:{ edithidden: true }
            },
            {
                fixed: true, name: 'hoatdong', hidden: true
                , label: 'Hoạt động'
                , index: 'tt.hoatdong'
                , width: 100
                , editable:true
                , edittype: 'checkbox'
                , align: 'center'
                , editoptions:{ value:'True:False', defaultValue: 'True' }
                , formatter: 'checkbox'
            }
        ]"
    GridBeforeRequest = "$('#grid_ds_tienvenganhang').jqGrid('getGridParam', 'postData').id = id_inc_tienve;"
    GridComplete = "var o = $(this).parent().parent().parent().parent().parent().parent().parent(); $(this).setGridHeight($(o).height() - 95);  $(this).setGridWidth($(o).width()); "
    Height = "150"
    MultiSelect = "false" 
    ShowAdd ="false"
    ShowEdit ="<%$ Code: DaoRules.GetRuleEdit(Context).ToString().ToLower() %>"
    ShowDel = "<%$ Code: DaoRules.GetRuleDel(Context).ToString().ToLower() %>"
    AddFormOptions=" 
    width: 400,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.tvid = id_inc_tienve;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_tienve')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    EditFormOptions ="
    width: 300,
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    },
    beforeSubmit:function(postdata, formid) {
        postdata.tvid = id_inc_tienve;
        return [true,''];
    },
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_tienve')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    ViewFormOptions="
    beforeShowForm: function (formid) {
    formid.closest('div.ui-jqdialog').dialogCenter(); 
    
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    }"
    DelFormOptions="
    beforeShowForm: function (formid) {
        formid.closest('div.ui-jqdialog').dialogCenter(); 
    },
    errorTextFormat:function(data) { 
        return 'Lỗi: ' + data.responseText 
    }, 
    afterSubmit: function(rs, postdata) {
        $('#grid_ds_tienve')[0].triggerToolbar();
        return showMsgDialog(rs);
    }
    "
    runat="server" />
</div>



<script type="text/javascript">
    function UploadTapTingrid_ds_tienvenganhang() {
        let data_js = new FormData();
        let $div, $frmGHDLH;
        $div = $(`
                <form  enctype="multipart/form-data" id="frm_File_grid_ds_tienvenganhang">
                    <div class="mess"></div>
                    <input type="button" onclick="$(this).next().click();" value="Chọn tập tin" />
                    <input type="file" style="display:none" multiple accept=".pdf" />
                </form>
            `);

        $div.dialog({
            title: `Tải lên "tập tin đính kèm"`,
            resizeable: false,
            modal: true,
            width: 400,
            height: 300,
            open: function (event, ui) {
                $frmGHDLH = $('#frm_File_grid_ds_tienvenganhang');
                let $fileInput = $frmGHDLH.find('input[type="file"]');
                let $mess = $frmGHDLH.find('.mess');
                let $table;

                $fileInput.change(function () {
                    let files = $(this)[0].files;
                    let messFile = '';
                    for (let i = 0; i < files.length; i++) {
                        let file = files[i];
                        let spanRemove = $(`span.btnVNN[fileN="${file.name}"]`);
                        if (spanRemove.attr('fileN') != null) {
                            spanRemove.click();
                        }

                        messFile += `
                                <tr class="rowFile" style="height: 25px;">
                                    <td>${file.name} (${file.size} Byte)</td>
                                    <td style="text-align:center"><span class="btnVNN" fileI="${i}" fileN="${file.name}">X</span></td>
                                </tr>`;

                        data_js.append('hinhanh' + i, file);
                    }

                    $table = $frmGHDLH.find('table');
                    if ($table.prop('tagName') == null) {
                        messFile = `
                                <table style="width:100%">
                                    <tr style="height: 25px;">
                                        <td style="font-weight:bold">Tên</td>
                                        <td style="font-weight:bold; text-align:center;"><a class="btnVNN">Xóa</a></td>
                                    </tr>
                                    ${messFile}
                                </table>
                            `;
                        $mess.html(messFile);
                        $table = $frmGHDLH.find('table');
                    }
                    else {
                        $table.append(messFile);
                    }

                    $('span.btnVNN').off('click');
                    $('span.btnVNN').click(function () {
                        let index = $(this).attr('fileI');
                        $(this).parent().parent().remove();
                        data_js.delete('hinhanh' + index);
                        if ($('tr.rowFile').length <= 0) {
                            $table.remove();
                        }
                    });

                    $('a.btnVNN').off('click');
                    $('a.btnVNN').click(function () {
                        let index = $(this).attr('fileI');
                        $(this).parent().parent().remove();
                        $('span.btnVNN').click();
                    });

                    $(this).val('');
                });
            },
            close: function (event, ui) {
                $(this).dialog('destroy').remove();
            },
            buttons: [
                {
                    text: "Tải lên",
                    id: "upload_File_grid_ds_tienvenganhang",
                    click: function () {
                        let $mess = $div.find('.mess');
                        let $btnUpload = $('#upload_File_grid_ds_tienvenganhang');
                        let id_parent = $('#grid_ds_tienve').jqGrid('getGridParam', 'selrow');
                        data_js.append("id_parent", id_parent);
                        $mess.html('<img style="width:30px; height:30px" src="iconcollection/loading.gif"/>');
                        $btnUpload.prop('disabled', true);
                        $.ajax({
                            url: 'Views/tienve/Controller_TienVe_NganHang.ashx?action=Upload',
                            type: 'POST',
                            data: data_js,
                            processData: false,
                            contentType: false,
                            success: function (data) {
                                $mess.html(data);
                                data_js = new FormData();
                                $btnUpload.prop('disabled', false);

                                if (data.lastIndexOf('error') <= -1) {
                                    $('#grid_ds_tienvenganhang')[0].triggerToolbar();
                                    $div.dialog("destroy").remove();
                                }
                            }
                        });
                    }
                },
                {
                    text: "Đóng",
                    click: function () {
                        $(this).dialog("destroy").remove();
                    }
                }
            ]
        });
    }

    $("#grid_ds_tienvenganhang").jqGrid('navButtonAdd', '#grid_ds_tienvenganhang-pager',
        {
            caption: "Tải lên tập tin",
            title: `Tải lên "tập tin"`,
            onClickButton: function () {
                UploadTapTingrid_ds_tienvenganhang();
            }
        }
    );
</script>