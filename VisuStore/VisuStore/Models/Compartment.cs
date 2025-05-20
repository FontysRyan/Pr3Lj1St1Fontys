using Newtonsoft.Json;

namespace VisuStore.Models
{
    public class Compartment
    {
        [JsonProperty("compartment_id")]
        public int Compartment_Id { get; set; }

        [JsonProperty("rack_id")]
        public int Rack_Id { get; set; }

        [JsonProperty("compartment_number")]
        public int Compartment_Number { get; set; }
    }
}
