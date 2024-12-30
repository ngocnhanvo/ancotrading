
public class AvariablePrj
{
    public partial class lstImage
    {
        public string id { get; set; }
        public int? dx1 { get; set; }
        public int? dx2 { get; set; }
        public int? dy1 { get; set; }
        public int? dy2 { get; set; }
        public int row { get; set; }
        public int? rowLast { get; set; }
        public int column { get; set; }
        public int? columnLast { get; set; }
        public string link { get; set; }
        public float? heightCell { get; set; }
        public float? widthCell { get; set; }
        public float? topIMG { get; set; }
        public float? leftIMG { get; set; }
        public float? widthIMG { get; set; }
        public float? heightIMG { get; set; }
        public double? zoom { get; set; }
        public bool? keepSize { get; set; }
    }

    public partial class lstText
    {
        public int row { get; set; }
        public int? columnFPrev { get; set; }
        public int? columnTPrev { get; set; }
        public int columnF { get; set; }
        public int columnT { get; set; }
        public double? minWidth { get; set; }
        public string value { get; set; }
        public float left { get; set; }
        public float top { get; set; }
        public bool? bold { get; set; }
    }

    public partial class lstTextReplace
    {
        public string oldT { get; set; }
        public string newT { get; set; }
        public int row { get; set; }
        public int column { get; set; }
        public bool? wrap_Mer { get; set; }
        public int? column_Mer { get; set; }
        public bool check { get; set; }
    }

    public partial class lstFormula
    {
        public int col { get; set; }
        public int row { get; set; }
        public string formula { get; set; }
        public int levelFML { get; set; }
        public string format { get; set; }
        public float? defaultHeight { get; set; }
    }

    public partial class lstFontSize
    {
        public int col { get; set; }
        public int row { get; set; }
        public float fontSize { get; set; }
    }

    public partial class OutPutInnerOuter
    {
        public string packingText { get; set; }
        public string sizeText { get; set; }
        public string inner { get; set; }
        public string outer { get; set; }
        public string quantity { get; set; }
    }
}
