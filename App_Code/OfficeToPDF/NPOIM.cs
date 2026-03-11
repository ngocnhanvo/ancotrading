using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.XSSF.UserModel;
using NPOI.OpenXmlFormats.Dml.Spreadsheet;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;

public class NPOIM
{
    private readonly IWorkbook _workbook;
    private readonly ISheet _sheet;

    // Cache top position của từng row, tránh loop lại nhiều lần
    private double[] _rowTopCache;

    public NPOIM(IWorkbook workbook, ISheet sheet)
    {
        _workbook = workbook;
        _sheet = sheet;
    }

    /// <summary>
    /// Gọi hàm này 1 lần trước khi InsertImages nếu có nhiều ảnh,
    /// tránh tính lại rowTopCache cho từng ảnh.
    /// </summary>
    public void BuildRowTopCache()
    {
        int lastRow = _sheet.LastRowNum + 1;
        _rowTopCache = new double[lastRow + 1];
        double cumTop = 0;
        for (int i = 0; i <= lastRow; i++)
        {
            _rowTopCache[i] = cumTop;
            IRow r = _sheet.GetRow(i);
            double rowHeightPt = r != null ? r.HeightInPoints : 15;
            cumTop += PointsToPixels(rowHeightPt);
        }
    }

    /// <summary>
    /// Chèn danh sách ảnh vào sheet
    /// </summary>
    public void InsertImages(List<AvariablePrj.lstImage> lstImage)
    {
        // Build cache nếu chưa có
        if (_rowTopCache == null)
            BuildRowTopCache();

        IDrawing drawing = _sheet.CreateDrawingPatriarch();

        foreach (AvariablePrj.lstImage image in lstImage)
        {
            try
            {
                InsertSingleImage(drawing, image);
            }
            catch (Exception ex)
            {
                // Log lỗi từng ảnh, không để 1 ảnh lỗi làm hỏng cả batch
                Console.WriteLine("[InsertImages] Error at row=" + image.row + " col=" + image.column + ": " + ex.Message);
            }
        }
    }

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    private void InsertSingleImage(IDrawing drawing, AvariablePrj.lstImage image)
    {
        byte[] imageBytes = LoadImageBytes(image.link);

        // Detect loại ảnh
        PictureType pictureType = DetectPictureType(image.link, imageBytes);
        int pictureIdx = _workbook.AddPicture(imageBytes, pictureType);

        // Tính kích thước vùng merged (pixels)
        double areaWidth = GetAreaWidth(image.column, image.columnLast);
        double areaHeight = GetAreaHeight(image.row, image.rowLast);

        // Tính kích thước ảnh giữ tỉ lệ
        double widthImg, heightImg;
        using (MemoryStream ms = new MemoryStream(imageBytes))
        using (System.Drawing.Image pictureR = System.Drawing.Image.FromStream(ms))
        {
            float percent = (float)(areaHeight / pictureR.Height);
            widthImg = pictureR.Width * percent;
            heightImg = pictureR.Height * percent - 3.5;
            widthImg = widthImg > areaWidth ? areaWidth - 1 : widthImg;
        }

        // Căn giữa mặc định
        double offsetX = (areaWidth - widthImg) / 2;
        double offsetY = (areaHeight - heightImg) / 2;
        offsetX = offsetX <= 0 ? 0 : offsetX;
        offsetY = offsetY <= 0 ? 2 : offsetY;

        double left = GetLeftByCol(image.column) + offsetX;
        double top = GetTopByRow(image.row) + offsetY;

        // Override nếu có custom position/size
        if (image.leftIMG != null) left = GetLeftByCol(image.column) + image.leftIMG.GetValueOrDefault(0);
        if (image.topIMG != null) top = GetTopByRow(image.row) + image.topIMG.GetValueOrDefault(0);
        if (image.widthIMG != null) widthImg = image.widthIMG.GetValueOrDefault(0);
        if (image.heightIMG != null) heightImg = image.heightIMG.GetValueOrDefault(0);

        // Tìm col/row và offset EMU tương ứng với tọa độ tuyệt đối
        int col1, col2, row1, row2;
        int dx1, dx2, dy1, dy2;
        GetAnchorFromAbsolute(left, out col1, out dx1);
        GetAnchorFromAbsolute(left + widthImg, out col2, out dx2);
        GetAnchorFromAbsoluteRow(top, out row1, out dy1);
        GetAnchorFromAbsoluteRow(top + heightImg, out row2, out dy2);

        // Dùng HSSFClientAnchor cho file .xls, XSSFClientAnchor cho .xlsx
        IClientAnchor anchor;
        if (_workbook is HSSFWorkbook)
        {
            // HSSF constructor: (dx1, dy1, dx2, dy2, col1, row1, col2, row2)
            // dx: 0-1023, dy: 0-255
            anchor = new HSSFClientAnchor(dx1, dy1, dx2, dy2, col1, row1, col2, row2);
        }
        else
        {
            anchor = new XSSFClientAnchor(dx1, dy1, dx2, dy2, col1, row1, col2, row2);
        }
        anchor.AnchorType = 1; // 1 = Move but don't size

        drawing.CreatePicture(anchor, pictureIdx);
    }

    /// <summary>
    /// Từ tọa độ tuyệt đối (pixels) theo chiều ngang,
    /// tìm col index và offset trong col đó
    /// </summary>
    private void GetAnchorFromAbsolute(double xPixels, out int colIndex, out int dxEmu)
    {
        double cumWidth = 0;
        for (int i = 0; i < 256; i++)
        {
            double colWidth = GetColumnWidthInPixels(i);
            if (cumWidth + colWidth > xPixels)
            {
                colIndex = i;
                double offsetPixels = xPixels - cumWidth;
                if (_workbook is HSSFWorkbook)
                    dxEmu = (int)(offsetPixels / colWidth * 1024); // HSSF: 1/1024 of cell
                else
                    dxEmu = (int)(offsetPixels * 9525); // XSSF: EMU
                return;
            }
            cumWidth += colWidth;
        }
        colIndex = 255;
        dxEmu = 0;
    }

    /// <summary>
    /// Từ tọa độ tuyệt đối (pixels) theo chiều dọc,
    /// tìm row index và offset trong row đó
    /// </summary>
    private void GetAnchorFromAbsoluteRow(double yPixels, out int rowIndex, out int dyEmu)
    {
        double cumHeight = 0;
        int lastRow = _sheet.LastRowNum;
        for (int i = 0; i <= lastRow; i++)
        {
            IRow r = _sheet.GetRow(i);
            double rowHeightPx = PointsToPixels(r != null ? r.HeightInPoints : 15);
            if (cumHeight + rowHeightPx > yPixels)
            {
                rowIndex = i;
                double offsetPixels = yPixels - cumHeight;
                if (_workbook is HSSFWorkbook)
                    dyEmu = (int)(offsetPixels / rowHeightPx * 256); // HSSF: 1/256 of cell height
                else
                    dyEmu = (int)(offsetPixels * 9525); // XSSF: EMU
                return;
            }
            cumHeight += rowHeightPx;
        }
        rowIndex = lastRow;
        dyEmu = 0;
    }

    private byte[] LoadImageBytes(string link)
    {
        if (link.StartsWith("http", StringComparison.OrdinalIgnoreCase))
        {
            using (WebClient wc = new WebClient())
            {
                return wc.DownloadData(link);
            }
        }
        return File.ReadAllBytes(link);
    }

    private PictureType DetectPictureType(string link, byte[] bytes)
    {
        // Detect qua magic bytes trước, fallback theo extension
        if (bytes.Length >= 4)
        {
            if (bytes[0] == 0xFF && bytes[1] == 0xD8) return PictureType.JPEG;
            if (bytes[0] == 0x89 && bytes[1] == 0x50) return PictureType.PNG;
        }

        string ext = Path.GetExtension(link).ToLower();
        if (ext == ".jpg" || ext == ".jpeg") return PictureType.JPEG;
        if (ext == ".wmf") return PictureType.WMF;
        if (ext == ".emf") return PictureType.EMF;
        return PictureType.PNG;
    }

    /// <summary>Tổng width (pixels) từ colStart đến colEnd (inclusive)</summary>
    private double GetAreaWidth(int? colStart, int? colEnd)
    {
        double width = 0;
        for (int i = colStart.GetValueOrDefault(0); i <= colEnd; i++)
            width += GetColumnWidthInPixels(i);
        return width;
    }

    /// <summary>Tổng height (pixels) từ rowStart đến rowEnd (inclusive)</summary>
    private double GetAreaHeight(int? rowStart, int? rowEnd)
    {
        double height = 0;
        for (int i = rowStart.GetValueOrDefault(0); i <= rowEnd; i++)
        {
            IRow r = _sheet.GetRow(i);
            double rowHeightPt = r != null ? r.HeightInPoints : 15;
            height += PointsToPixels(rowHeightPt);
        }
        return height;
    }

    /// <summary>Left offset (pixels) tính từ col 0 đến colIndex</summary>
    private double GetLeftByCol(int colIndex)
    {
        double left = 0;
        for (int i = 0; i < colIndex; i++)
            left += GetColumnWidthInPixels(i);
        return left;
    }

    /// <summary>Top offset (pixels) tính từ row 0 đến rowIndex — dùng cache</summary>
    private double GetTopByRow(int rowIndex)
    {
        if (_rowTopCache != null && rowIndex < _rowTopCache.Length)
            return _rowTopCache[rowIndex];

        // Fallback nếu chưa build cache
        double top = 0;
        for (int i = 0; i < rowIndex; i++)
        {
            IRow r = _sheet.GetRow(i);
            double rowHeightPt = r != null ? r.HeightInPoints : 15;
            top += PointsToPixels(rowHeightPt);
        }
        return top;
    }

    /// <summary>Đổi points -> pixels (96 DPI)</summary>
    private static double PointsToPixels(double points)
    {
        return points * 96.0 / 72.0;
    }

    // Thay thế GetColumnWidthInPixels(i)
    private double GetColumnWidthInPixels(int colIndex)
    {
        // NPOI GetColumnWidth trả về đơn vị 1/256 của character width
        // 1 character width ~ 7 pixels ở 96 DPI
        int columnWidth = _sheet.GetColumnWidth(colIndex); // đơn vị: 1/256 char
        return columnWidth / 2048.0 * 64.0 + 5;
    }

    public float CalculateRowHeight(ISheet sheet, int rowIndex, float templateHeight)
    {
        IRow row = sheet.GetRow(rowIndex);
        if (row == null) return templateHeight;

        float maxHeightNeeded = 0;

        foreach (ICell cell in row)
        {
            if (cell.CellType != CellType.String)
                continue;

            ICellStyle style = cell.CellStyle;
            if (!style.WrapText) continue;

            string content = cell.StringCellValue;
            if (string.IsNullOrEmpty(content)) continue;

            IFont font = sheet.Workbook.GetFontAt(style.FontIndex);
            float fontSizePt = font.FontHeightInPoints;

            double colWidthPx = sheet.GetColumnWidth(cell.ColumnIndex) / 256.0 * 7.0;
            double colWidthPt = colWidthPx * 72.0 / 96.0;

            // Tính số dòng cho từng đoạn (split theo \n)
            int totalLines = 0;
            foreach (string line in content.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
            {
                double charWidthFactor = GetCharWidthFactor(line);
                double charsPerLine = colWidthPt / (fontSizePt * charWidthFactor);
                charsPerLine = charsPerLine < 1 ? 1 : charsPerLine;

                int linesForSegment = (int)Math.Ceiling((line.Length * 1.15) / charsPerLine);
                totalLines += linesForSegment < 1 ? 1 : linesForSegment;
            }
            totalLines = totalLines < 1 ? 1 : totalLines;

            float heightNeeded = totalLines * fontSizePt * 1.3f;
            if (heightNeeded > maxHeightNeeded)
                maxHeightNeeded = heightNeeded;
        }

        float finalHeight = Math.Max(templateHeight, maxHeightNeeded);
        return Math.Max(finalHeight, 20);
    }

    /// <summary>
    /// Tính hệ số width trung bình của ký tự dựa trên ngôn ngữ trong chuỗi.
    /// Tiếng Việt/CJK: ký tự rộng hơn tiếng Anh.
    /// </summary>
    private double GetCharWidthFactor(string text)
    {
        if (string.IsNullOrEmpty(text)) return 0.6;

        int total = text.Length;
        int vietnamese = 0;
        int english = 0;

        foreach (char c in text)
        {
            if (IsVietnamese(c))
                vietnamese++;
            else if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'))
                english++;
        }

        double vietRatio = (double)vietnamese / total;
        double englishRatio = (double)english / total;

        // Tiếng Việt: ký tự có dấu rộng hơn ~0.55
        // Tiếng Anh: ký tự hẹp hơn ~0.5
        // Mix hoặc số/ký tự đặc biệt: ~0.6
        if (vietRatio > 0.3)
            return 0.55;
        if (englishRatio > 0.5)
            return 0.50;
        return 0.60;
    }

    /// <summary>
    /// Kiểm tra ký tự có phải tiếng Việt có dấu không
    /// </summary>
    private bool IsVietnamese(char c)
    {
        // Unicode ranges cho tiếng Việt có dấu
        string viet = "àáâãèéêìíòóôõùúýăđơưạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ"
                    + "ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝĂĐƠƯẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼẾỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪỬỮỰỲỴỶỸ";
        return viet.IndexOf(c) >= 0;
    }
}