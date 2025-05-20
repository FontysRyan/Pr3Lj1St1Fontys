using Newtonsoft.Json;

namespace VisuStore.Models
{
    public class ProductLocation
    {
        [JsonProperty("location_id")]
        public int Location_Id { get; set; }

        [JsonProperty("product_id")]
        public int Product_Id { get; set; }

        [JsonProperty("zone_id")]
        public int Zone_Id { get; set; }

        [JsonProperty("shelf_id")]
        public int Shelf_Id { get; set; }

        [JsonProperty("quantity")]
        public int Quantity { get; set; }

        [JsonProperty("batch_number")]
        public string? Batch_Number { get; set; }

        [JsonProperty("date_received")]
        public DateTime Date_Received { get; set; }

        [JsonProperty("status")]
        public ProductLocationStatus Status { get; set; }

        public Product? Product { get; set; }
    }

    [JsonConverter(typeof(Newtonsoft.Json.Converters.StringEnumConverter))]
    public enum ProductLocationStatus
    {
        available,
        reserved,
        damaged
    }
}
