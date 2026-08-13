<%@ Control Language="C#" AutoEventWireup="true" CodeFile="solanbosung.ascx.cs" Inherits="Views_hosochungtu_solanbosung" %>


<%--<%@ Control Language="C#" AutoEventWireup="true" CodeFile="solanbosung.ascx.cs" Inherits="Views_hosochungtu_solanbosung" %>--%>
<%@ Register src="~/jqGrid.ascx" tagname="jqGrid" tagprefix="uc1" %>

<div id="hosochungtu-details-3">
    <uc1:jqGrid ID="grid_solanbosung"
        Caption="Lịch sử bổ sung"
        SortName="log.sothutu"
        SortOrder="DESC"
        UrlFileAction="Views/hosochungtu/Controller_HoSoChungTu_SoLan.ashx"
        RowNumbers="true"
        ColModel="
        [
            {
                name: 'id',
                label: 'id',
                index: 'log.id',
                key: true,
                hidden: true
            },
            {
                name: 'sothutu',
                label: 'Số lần',
                index: 'log.sothutu',
                width: 70,
                fixed: true,
                align: 'right'
            },
            {
                name: 'sochungtu',
                label: 'Số PO',
                index: 'log.sochungtu',
                width: 120,
                fixed: true
            },
            {
                name: 'ngaydieuchinh',
                label: 'NXH Điều Chỉnh',
                index: 'log.ngaydieuchinh',
                width: 120,
                fixed: true,
                align: 'center'
            },
            {
                name: 'cont20',
                label: 'Cont 20',
                index: 'log.cont20',
                width: 80,
                fixed: true,
                align: 'right'
            },
            {
                name: 'cont40',
                label: 'Cont 40DC',
                index: 'log.cont40',
                width: 90,
                fixed: true,
                align: 'right'
            },
            {
                name: 'cont40hc',
                label: 'Cont 40HC',
                index: 'log.cont40hc',
                width: 90,
                fixed: true,
                align: 'right'
            },
            {
                name: 'cont45',
                label: 'Cont 45',
                index: 'log.cont45',
                width: 80,
                fixed: true,
                align: 'right'
            },
            {
                name: 'contLCL',
                label: 'Cont LCL',
                index: 'log.contLCL',
                width: 80,
                fixed: true,
                align: 'right'
            },
            {
                name: 'mota',
                label: 'Ghi chú',
                index: 'log.mota',
                width: 220
            },
            {
                name: 'ngaygui',
                label: 'Ngày gửi',
                index: 'log.ngaygui',
                width: 130,
                fixed: true,
                align: 'center'
            },
            {
                name: 'nguoigui',
                label: 'Người gửi',
                index: 'log.nguoigui',
                width: 100,
                fixed: true
            }
        ]"
        GridComplete="let o = $('#tabs-hosochungtu-details'); $(this).setGridHeight($(o).height() - 97);$(this).setGridWidth($(o).width())"
        FilterToolbar="true"
        Height="150"
        MultiSelect="false"
        ShowAdd="false"
        ShowEdit="false"
        ShowDel="false"
        runat="server" />
</div>
