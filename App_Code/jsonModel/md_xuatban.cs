using System;
namespace DataAcess
{
    public partial class md_xuatban
    {             
        public string md_xuatban_id { get; set; }				
        public string sochungtu { get; set; }
        public DateTime? ngaychuyen { get; set; }
        public string so_cont { get; set; }
        public string so_seal { get; set; }
        public string loai_cont { get; set; }
        public decimal? tongsl { get; set; }
    }
}