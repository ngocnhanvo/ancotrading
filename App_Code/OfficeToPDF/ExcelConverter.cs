/**
 *  OfficeToPDF command line PDF conversion for Office 2007/2010/2013/2016
 *  Copyright (C) 2011-2018 Cognidox Ltd
 *  https://www.cognidox.com/opensource/
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
using System;
using System.Collections.Generic;
using System.IO;
using static PrintAnco2;

namespace OfficeToPDF
{
    /// <summary>
    /// Handle conversion of Excel files
    /// </summary>
    /// 

    public class ExcelConverter : Converter
    {
        public List<AvariablePrj.lstImage> lstImage { get; set; }
        public List<AvariablePrj.lstText> lstText { get; set; }
        public List<AvariablePrj.lstTextReplace> lstTextReplace { get; set; }
        public List<AvariablePrj.lstFormula> lstFormula { get; set; }
        public List<int> lstAutoSizeColumn { get; set; }
        public int? endRow { get; set; }
        public int? endColumn { get; set; }
        public float? sizeAddPDF { get; set; }

        public ExcelConverter()
        {

        }

        public string ConvertInterop(String inputFile, String outputFile, int endrow, int endColumn)
        {
            if (lstImage == null)
                lstImage = new List<AvariablePrj.lstImage>();

            if (lstText == null)
                lstText = new List<AvariablePrj.lstText>();

            if (lstTextReplace == null)
                lstTextReplace = new List<AvariablePrj.lstTextReplace>();

            if (lstFormula == null)
                lstFormula = new List<AvariablePrj.lstFormula>();

            if (lstAutoSizeColumn == null)
                lstAutoSizeColumn = new List<int>();

            string msg = "";
            var req = new AvariablePrj.ExportRequest
            {
                urlExcel = inputFile,
                urlFN = outputFile,
                lstImage = lstImage,
                lstTextReplace = lstTextReplace,
                lstAutoSizeColumn = lstAutoSizeColumn,
                lstText = lstText,
                endrow = endrow,
                endColumn = endColumn
            };
            string urlInterop = Helper.urlReportExcel;
            var request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(urlInterop);
            request.Method = "POST";
            request.ContentType = "application/json";

            request.Timeout = 120000;
            request.ReadWriteTimeout = 120000;

            // Convert object -> JSON
            string json = Newtonsoft.Json.JsonConvert.SerializeObject(req);
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(json);

            request.ContentLength = bytes.Length;

            // Write body
            using (var stream = request.GetRequestStream())
            {
                stream.Write(bytes, 0, bytes.Length);
            }

            // Read response
            using (var response = (System.Net.HttpWebResponse)request.GetResponse())
            using (var reader = new StreamReader(response.GetResponseStream()))
            {
                string result = reader.ReadToEnd();
                msg = result;
            }
            return msg;
        }
    }
}
