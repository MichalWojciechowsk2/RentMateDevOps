using Infrastructure.Repositories;

namespace RentMateApi.requests
{
    public class UpdateUserFieldRequest
    {
        public UserFieldToUpdate Field {  get; set; }
        public string Value { get; set; }
    }
}
