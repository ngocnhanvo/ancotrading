using System;
using System.Text;

public static class UnicodeToVNIConverter
{
    static string UnicodeChars =
    "àáảãạăắằẳẵặâấầẩẫậ" +
    "èéẻẽẹêếềểễệ" +
    "ìíỉĩị" +
    "òóỏõọôốồổỗộơớờởỡợ" +
    "ùúủũụưứừửữự" +
    "ỳýỷỹỵđ" +
    "ÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬ" +
    "ÈÉẺẼẸÊẾỀỂỄỆ" +
    "ÌÍỈĨỊ" +
    "ÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ" +
    "ÙÚỦŨỤƯỨỪỬỮỰ" +
    "ỲÝỶỸỴĐ";

    static string[] VNIChars =
    {
        "aø","aù","aû","aõ","aï",
        "aê","aé","aè","aú","aü","aë",
        "aâ","aá","aà","aå","aã","aä",

        "eø","eù","eû","eõ","eï",
        "eâ","eá","eà","eå","eã","eä",

        "ì","í","æ","ó","ò",

        "oø","où","oû","oõ","oï",
        "oâ","oá","oà","oå","oã","oä",
        "ô","ôù","ôø","ôû","ôõ","ôï",

        "uø","uù","uû","uõ","uï",
        "ö","öù","öø","öû","öõ","öï",

        "yø","yù","yû","yõ","î",
        "ñ",

        "AØ","AÙ","AÛ","AÕ","AÏ",
        "AÊ","AÉ","AÈ","AÚ","AÜ","AË",
        "AÂ","AÁ","AÀ","AÅ","AÃ","AÄ",

        "EØ","EÙ","EÛ","EÕ","EÏ",
        "EÂ","EÁ","EÀ","EÅ","EÃ","EÄ",

        "Ì","Í","Æ","Ó","Ò",

        "OØ","OÙ","OÛ","OÕ","OÏ",
        "OÂ","OÁ","OÀ","OÅ","OÃ","OÄ",
        "Ô","ÔÙ","ÔØ","ÔÛ","ÔÕ","ÔÏ",

        "UØ","UÙ","UÛ","UÕ","UÏ",
        "Ö","ÖÙ","ÖØ","ÖÛ","ÖÕ","ÖÏ",

        "YØ","YÙ","YÛ","YÕ","Î",
        "Ñ"
    };

    public static string Convert(string input)
    {
        if (string.IsNullOrEmpty(input))
            return input;

        StringBuilder sb = new StringBuilder();

        foreach (char c in input)
        {
            int index = UnicodeChars.IndexOf(c);

            if (index >= 0)
                sb.Append(VNIChars[index]);
            else
                sb.Append(c);
        }

        return sb.ToString();
    }
}