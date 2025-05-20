using Newtonsoft.Json;

namespace VisuStore.Models
{
    public class Product
    {
        [JsonProperty("product_id")]
        public int Product_Id { get; set; }

        [JsonProperty("sku")]
        public string Sku { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("weight")]
        public decimal Weight { get; set; }

        [JsonProperty("barcode")]
        public string Barcode { get; set; }

        [JsonProperty("created_at")]
        public DateTime Created_At { get; set; }
    }
}
