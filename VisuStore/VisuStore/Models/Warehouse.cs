using Newtonsoft.Json;

namespace VisuStore.Models
{
    public class Warehouse
    {
        [JsonProperty("warehouse_id")]
        public int Warehouse_Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("address")]
        public string Address { get; set; }

        [JsonProperty("city")]
        public string City { get; set; }

        [JsonProperty("postal_code")]
        public string Postal_Code { get; set; }

        [JsonProperty("created_at")]
        public DateTime Created_At { get; set; }
    }
}
