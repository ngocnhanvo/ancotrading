
public class AvariablePrj
{
    public partial class lstIamge
    {
        public int row { get; set; }
        public int column { get; set; }
        public string link { get; set; }
        public float heightCell { get; set; }
        public float widthCell { get; set; }
    }

    public partial class lstText
    {
        public int row { get; set; }
        public int columnF { get; set; }
        public int columnT { get; set; }
        public string value { get; set; }
        public float left { get; set; }
        public float top { get; set; }
        public bool? bold { get; set; }
    }
}
