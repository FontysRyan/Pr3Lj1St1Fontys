using System.Text.Json.Serialization;

namespace VisuStore.Models
{
    public class Rack
    {
        [JsonPropertyName("rack_id")]
        public int Rack_Id { get; set; }

        [JsonPropertyName("zone_id")]
        public int Zone_Id { get; set; }

        [JsonPropertyName("rack_number")]
        public int Rack_Number { get; set; }

        [JsonPropertyName("capacity")]
        public decimal Capacity { get; set; }
    }
}
