using System.Security.Claims;

namespace Golden.Services.Security
{
    public static class ClaimsIdentityExt
    {
        public static string TENANTID = "Golden.TenantId";

        public static void AddTenantId(this ClaimsIdentity claims, object tenantId)
        {
            claims.AddClaim(new Claim(TENANTID, tenantId?.ToString(), null, "Golden"));
        }

        public static bool IsTenantIdClaim(this ClaimsIdentity claims, string claimName)
        {
            return claimName == TENANTID;
        }
    }
}