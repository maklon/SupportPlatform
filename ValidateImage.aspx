<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Drawing2D" %>
<%@ Page Language="C#" %>

<script runat="server">
    protected void Page_Load(object Sender, EventArgs e) {
        int number;
        char code;
        string checkCode = String.Empty;
        Random random = new Random();
        for (int i = 0; i < 5; i++) {
            number = random.Next();
            if (number % 2 == 0)
                code = (char)('0' + (char)(number % 10));
            else
                code = (char)('A' + (char)(number % 26));
            checkCode += code.ToString();
        }
        Session["ValidateImageCode"] = checkCode;

        Bitmap image = new System.Drawing.Bitmap((int)Math.Ceiling
        ((checkCode.Length * 13.0)), 22);
        Graphics g = Graphics.FromImage(image);
        try {
            //背景色
            g.Clear(Color.White);
            for (int i = 0; i < 25; i++) {
                int x1 = random.Next(image.Width);
                int x2 = random.Next(image.Width);
                int y1 = random.Next(image.Height);
                int y2 = random.Next(image.Height);

                g.DrawLine(new Pen(Color.Silver), x1, y1, x2, y2);
            }
            for (int i = 0; i < 100; i++) {
                int x = random.Next(image.Width);
                int y = random.Next(image.Height);

                image.SetPixel(x, y, Color.FromArgb(random.Next()));
            }
            g.SmoothingMode = SmoothingMode.HighQuality;           
            
            Font font = new System.Drawing.Font("Arial", 12, (System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic));
            System.Drawing.Drawing2D.LinearGradientBrush
            brush = new System.Drawing.Drawing2D.
            LinearGradientBrush(new Rectangle(0, 0, image.Width, image.Height), Color.Black, Color.Black, 1.2f, true);
            g.DrawString(checkCode, font, brush, 2, 2);
            //圖片邊框
            g.DrawRectangle(new Pen(Color.Black),
            0, 0, image.Width - 1, image.Height - 1);
            System.IO.MemoryStream ms = new System.IO.MemoryStream();
            image.Save(ms, System.Drawing.Imaging.ImageFormat.Gif);
            Response.ClearContent();
            Response.ContentType = "image/JPEG";
            Response.BinaryWrite(ms.ToArray());
        } finally {
            g.Dispose();
            image.Dispose();
        }
    }
    
    private void CreateCheckCodeImage(string checkCode) {
        
        
    }

</script>
