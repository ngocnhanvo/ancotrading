<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inc-upload-image.aspx.cs" Inherits="inc_upload_image" %>
<script type="text/javascript">
    // Convert divs to queue widgets when the DOM is ready
    $(function() {
        $('#filelist').height($('#lay-center-upload').parent().height() - 70);
        $('.btn-action').button();
        $('#lay-center-upload').parent().layout({
            center: {
                onresize_end: function() { $('#filelist').height($('#lay-center-upload').parent().height() - 70); }
            }
        });
    });
</script>

<div class="ui-layout-center" id="lay-center-upload">
    <form method="post" action="Controllers/UploadFile.ashx" enctype="multipart/form-data">  
        <DIV class="ui-widget-header">            <div style="padding:10px">Upload Ảnh Sản Phẩm</div>        </DIV>        <div id="filelist" class="ui-layout-content" style="padding:0; background:#f0f0f0;"></div>        <DIV class="ui-widget-header">
            <div style="padding:3px">
                <span class="btn-action" id="pickfiles" href="#"><b>Chọn File</b></span>
                <span class="btn-action" id="resetall" href="#"><b>Bỏ Chọn Tất Cả</b></span>
                <span class="btn-action" id="uploadfiles" href="#"><b>Bắt Đầu Upload File</b></span>
            </div>
        </DIV>
    </form>
</div>

<script>
    $(function () {
        var uploaderApp = new plupload.Uploader({
            runtimes: 'gears,html5,flash,silverlight,browserplus',
            browse_button: 'pickfiles',
            container: 'lay-center-upload',
            url: 'Controllers/UploadFile.ashx',
            flash_swf_url: 'jQuery/FileUpload/plupload.flash.swf',
            silverlight_xap_url: 'jQuery/FileUpload/FileUpload/plupload.silverlight.xap',
            filters: [
			{ title: "Image files", extensions: "jpg,gif,png" }
		]
        });

        uploaderApp.bind('Init', function (up, params) {
            //$('#filelist').html("<div>Current runtime: " + params.runtime + "</div>");
        });

        $('#uploadfiles').click(function (e) {
            uploaderApp.start();
            e.preventDefault();
        });

        $('#resetall').click(function (e) {
            $('#filelist *').remove();
            uploaderApp.splice();
            uploaderApp.refresh();
        });

        $(".delete_pending_file").live('click', function () {
            var file_id = $(this).attr('id');
            var file = uploaderApp.getFile(file_id);

            if (file !== undefined) {
                uploaderApp.removeFile(file);
                $('#file_' + file_id).remove();
            }
            return false;
        });

        uploaderApp.init();

        uploaderApp.bind('FilesAdded', function (up, files) {
            $.each(files, function (i, file) {
                $('#filelist').append(
                '<div style="padding:8px" class="ui-widget ui-state-default ui-corner-all ui-button-text-only" id="file_' + file.id + '">' + file.name +
                '<div id="' + file.id + '" class="delete_pending_file" style="cursor:pointer; float:right; width:80px; text-align:center">&times;</div>' +
                '<div class="progress-container" style="float:right; width:80px; text-align:center">0%</div>' +
                '<div style="float:right; width:80px; text-align:center">' + plupload.formatSize(file.size) + '</div>' +
                '<div style="clear:both"></div>' +
                '</div>'
                );
            });

            up.refresh();
        });

        uploaderApp.bind('UploadProgress', function (up, file) {
            $('#file_' + file.id + " .progress-container").html(file.percent + "%");
        });

        uploaderApp.bind('Error', function (up, err) {
            alert(err.message);
            up.refresh();
        });

        uploaderApp.bind('FileUploaded', function (up, file, info) {
            let res = info.response.toString();
            if (res.startWiths('false#')) {
                alert(res.substr(6));
                $('#' + file.id + " b").html("error");
            }
            else {
                $('#' + file.id + " b").html("100%");
            }
        });
    });
</script>

