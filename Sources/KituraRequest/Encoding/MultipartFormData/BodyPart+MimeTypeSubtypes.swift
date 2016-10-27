extension BodyPart.MimeType {

    ///
    public enum ImageSubtype: String {

        ///
        case any = "*"

        ///
        case gif = "gif"

        ///
        case jpeg = "jpeg"

        ///
        case png = "png"

        ///
        case tiff = "tiff"
    }

    ///
    public enum TextSubtype: String {

        ///
        case any = "*"

        ///
        case css = "css"

        ///
        case csv = "csv"

        ///
        case html = "html"

        ///
        case javascript = "javascript"

        ///
        case plain = "plain"

        ///
        case php = "php"

        ///
        case xml = "xml"
    }

    public enum ApplicationSubtype: String {

        ///
        case json = "json"

        ///
        case javascript = "javascript"

        ///
        case octetStream = "octet-stream"

        ///
        case pdf = "pdf"

        ///
        case zip = "zip"

        ///
        case gzip = "gzip"
    }
}
