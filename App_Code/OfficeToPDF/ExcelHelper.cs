using System;
using System.Collections;
using System.IO;
using System.Threading;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.SS.Util;

namespace OfficeToPDF
{
    public class ExcelHelper
    {
        public String sourceFile { get; set; }
        public String outputFile { get; set; }
        public HSSFWorkbook workbook { get; set; }
        public ISheet sheet { get; set; }
        public ICellStyle cellBlank { get; set; }

        public ExcelHelper(HSSFWorkbook wsb, ISheet sht)
        {
            if (wsb != null)
                workbook = wsb;

            cellBlank = workbook.CreateCellStyle();
            sheet = sht == null ? workbook.GetSheetAt(0) : sht;
        }

        private static int LETTERS_IN_EN_ALFABET = 26;
        private static int BASE = LETTERS_IN_EN_ALFABET;
        private static int A_LETTER = 65;

        public static String updateFormula(String cellFormula, int columnIndex)
        {
            String existingColName = getReferenceForColumnIndex(columnIndex);
            String newColName = getReferenceForColumnIndex(columnIndex + 1);


            String newCellFormula = cellFormula.Replace(existingColName, newColName);

            return newCellFormula;
        }

        public static String getReferenceForColumnIndex(int columnIndex)
        {
            var sb = new System.Text.StringBuilder();

            while (columnIndex >= 0)
            {
                if (columnIndex == 0)
                {
                    sb.Append((char)A_LETTER);
                    break;
                }

                char code = (char)(columnIndex % BASE);
                char letter = (char)(code + A_LETTER);
                sb.Append(letter);

                columnIndex /= BASE;
                columnIndex -= 1;
            }

            return sb.ToString().Reverse().ToString();
        }

        public int getNumberOfRows(int sheetIndex)
        {
            int sheetNumber = workbook.NumberOfSheets;

            if (sheetIndex >= sheetNumber)
            {
                throw new Exception("Sheet index " + sheetIndex
                        + " invalid, we have " + sheetNumber + " sheets");
            }

            var sheet = workbook.GetSheetAt(sheetIndex);

            int rowNum = sheet.LastRowNum + 1;

            return rowNum;
        }

        public void deleteColumn(int sheetIndex, int columnIndex)
        {
            var evaluator = workbook.GetCreationHelper()
                    .CreateFormulaEvaluator();
            evaluator.ClearAllCachedResultValues();

            var sheet = workbook.GetSheetAt(sheetIndex);
            int nrRows = getNumberOfRows(sheetIndex);
            int nrCols = getNrColumns(sheetIndex);

            for (int row = 0; row < nrRows; row++)
            {
                var r = sheet.GetRow(row);

                if (r == null)
                {
                    continue;
                }

                // shift to right
                for (int col = columnIndex; col <= nrCols; col++)
                {
                    var rightCell = r.GetCell(col + 1);

                    if (rightCell != null)
                    {
                        var newCell = r.GetCell(col);
                        newCell.SetCellType(rightCell.CellType);
                        newCell = cloneCell(newCell, rightCell);

                        if (newCell.CellType == CellType.Formula)
                        {
                            newCell.SetCellFormula(updateFormula(newCell.CellFormula, columnIndex));
                            evaluator.NotifySetFormula(newCell);
                            CellValue cellValue = evaluator.Evaluate(newCell);
                            evaluator.EvaluateFormulaCell(newCell);
                        }

                        rightCell.SetCellValue("");
                        rightCell.SetCellType(CellType.Blank);
                        rightCell.CellStyle = cellBlank;
                    }
                }
            }

            // Adjust the column widths
            for (int col = columnIndex; col <= nrCols; col++)
            {
                sheet.SetColumnWidth(col, sheet.GetColumnWidth(col + 1));
            }

            // currently updates formula on the last cell of the moved column
            // TODO: update all cells if their formulas contain references to the moved cell
            //		Row specialRow = sheet.getRow(nrRows-1);
            //		Cell cellFormula = specialRow.createCell(nrCols - 1);
            //		cellFormula.setCellType(XSSFCell.CELL_TYPE_FORMULA);
            //		cellFormula.setCellFormula(formula);

            NPOI.XSSF.UserModel.XSSFFormulaEvaluator.EvaluateAllFormulaCells(workbook);
        }

        public void insertNewColumnBefore(int sheetIndex, int columnIndex)
        {
            var evaluator = workbook.GetCreationHelper()
                    .CreateFormulaEvaluator();
            evaluator.ClearAllCachedResultValues();

            var sheet = workbook.GetSheetAt(sheetIndex);
            int nrRows = getNumberOfRows(sheetIndex);
            int nrCols = getNrColumns(sheetIndex);

            for (int row = 0; row < nrRows; row++)
            {
                var r = sheet.GetRow(row);

                if (r == null)
                {
                    continue;
                }

                // shift to right
                for (int col = nrCols; col > columnIndex; col--)
                {
                    //var rightCell = r.GetCell(col);
                    //if (rightCell != null)
                    //{
                    //    r.RemoveCell(rightCell);
                    //}

                    var leftCell = r.GetCell(col - 1);

                    if (leftCell != null)
                    {
                        var newCell = r.CreateCell(col, leftCell.CellType);
                        newCell = cloneCell(newCell, leftCell);

                        if (newCell.CellType == CellType.Formula)
                        {
                            newCell.SetCellFormula(updateFormula(newCell.CellFormula, columnIndex));
                            evaluator.NotifySetFormula(newCell);
                            CellValue cellValue = evaluator.Evaluate(newCell);
                            evaluator.EvaluateFormulaCell(newCell);
                        }
                    }
                }

                //// delete old column
                //var cellType = CellType.Blank;

                //var currentEmptyWeekCell = r.GetCell(columnIndex);
                //if (currentEmptyWeekCell != null)
                //{
                //    //				cellType = currentEmptyWeekCell.getCellType();
                //    r.RemoveCell(currentEmptyWeekCell);
                //}

                //// create new column
                //r.CreateCell(columnIndex, cellType);
            }

            // Adjust the column widths
            for (int col = nrCols; col > columnIndex; col--)
            {
                sheet.SetColumnWidth(col, sheet.GetColumnWidth(col - 1));
            }

            // currently updates formula on the last cell of the moved column
            // TODO: update all cells if their formulas contain references to the moved cell
            //		Row specialRow = sheet.getRow(nrRows-1);
            //		Cell cellFormula = specialRow.createCell(nrCols - 1);
            //		cellFormula.setCellType(XSSFCell.CELL_TYPE_FORMULA);
            //		cellFormula.setCellFormula(formula);

            NPOI.XSSF.UserModel.XSSFFormulaEvaluator.EvaluateAllFormulaCells(workbook);
        }

        /*
         * Takes an existing Cell and merges all the styles and forumla into the new
         * one
         */
        private ICell cloneCell(ICell cNew, ICell cOld)
        {
            cNew.CellComment = cOld.CellComment;
            cNew.CellStyle = cOld.CellStyle;

            switch (cOld.CellType)
            {
                case CellType.Boolean:
                    {
                        cNew.SetCellValue(cOld.BooleanCellValue);
                        break;
                    }
                case CellType.Numeric:
                    {
                        cNew.SetCellValue(cOld.NumericCellValue);
                        break;
                    }
                case CellType.String:
                    {
                        cNew.SetCellValue(cOld.StringCellValue);
                        break;
                    }
                case CellType.Error:
                    {
                        cNew.SetCellValue(cOld.ErrorCellValue);
                        break;
                    }
                case CellType.Formula:
                    {
                        cNew.SetCellFormula(cOld.CellFormula);
                        break;
                    }
            }

            return cNew;
        }

        public int getNrColumns(int sheetIndex)
        {
            var sheet = workbook.GetSheetAt(sheetIndex);

            // get header row
            var headerRow = sheet.GetRow(0);
            int nrCol = headerRow.LastCellNum;
            return nrCol;
        }

        private static void writeToFile(HSSFWorkbook workbook, String fileName)
        {
            using (var file = new FileStream(fileName, FileMode.Open, FileAccess.ReadWrite))
            {
                workbook.Write(file);
                file.Close();
            }
        }

        public void close()
        {
            try
            {
                writeToFile(workbook, this.outputFile);
            }
            catch (IOException e)
            {

            }
        }
    }
}
