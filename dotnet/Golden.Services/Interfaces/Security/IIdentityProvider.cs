namespace Golden.Services.Interfaces.Security
{
    public interface IIdentityProvider<T>
    {
        T GetCurrentUserId();
    }
}