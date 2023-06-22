using Golden.Models.Domain.Addresses;
using Golden.Models.Requests.Addresses;
using System.Collections.Generic;

namespace Golden.Services.Interfaces
{
    public interface IAddressService
    {
        //stubs - these param/arg signatures must match those in AddressService
        //they are linked in DependencyInjection.cs
        //
        int Add(AddressAddRequest newAddress, int userId);
        void Delete(int deleteId);
        Address Get(int id);
        List<Address> GetRandomAddresses();
        void Update(AddressUpdateRequest updateAddress, int userId);
    }
}