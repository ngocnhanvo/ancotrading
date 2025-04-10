using System;
namespace DataAcess
{
    public partial class md_xuatban_cdh
    {
        public string md_xuatban_cdh_id { get; set; }
        public string c_danhsachdathang_id { get; set; }
        public string md_sanpham_id { get; set; }
        public string md_xuatban_id { get; set; }
        public Decimal? sl_po { get; set; }
        public Decimal? sl_dathang { get; set; }
        public Decimal? sl_nhapthucte { get; set; }
        public Decimal? sl_conlai { get; set; }
    }
}
            