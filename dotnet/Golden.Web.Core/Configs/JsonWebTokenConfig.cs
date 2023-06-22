namespace Golden.Web.Core.Configs
{
    public class JsonWebTokenConfig
    {
        public int ExpirationDays { get; set; }
        public string Secret { get; set; }
        public string Audience { get; set; }
        public string Issuer { get; set; }
    }
}