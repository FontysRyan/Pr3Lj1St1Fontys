using Newtonsoft.Json;

namespace VisuStore.Models
{
    public class Shelf
    {
        [JsonProperty("shelf_id")]
        public int Shelf_Id { get; set; }

        [JsonProperty("compartment_id")]
        public int Compartment_Id { get; set; }

        [JsonProperty("shelf_number")]
        public int Shelf_Number { get; set; }

        [JsonProperty("max_weight")]
        public decimal Max_Weight { get; set; }

        [JsonProperty("zone_id")]
        public int Zone_Id { get; set; }
    }
}
