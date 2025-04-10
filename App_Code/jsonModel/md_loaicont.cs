using System.Collections.Generic;
namespace DataAcess
{
    public partial class md_loaicont
    {             
        public string ma { get; set; }				
        public string ten { get; set; }

        public List<md_loaicont> get()
        {
            var lst = new List<md_loaicont>();
            lst.Add(new md_loaicont() { ma = "CONT20", ten = "Cont 20" });
            lst.Add(new md_loaicont() { ma = "CONT40", ten = "Cont 40" });
            lst.Add(new md_loaicont() { ma = "CONT45", ten = "Cont 45" });
            lst.Add(new md_loaicont() { ma = "40HC", ten = "40HC" });
            lst.Add(new md_loaicont() { ma = "LE", ten = "Cont Lẻ" });
            return lst;
        }
    }
}