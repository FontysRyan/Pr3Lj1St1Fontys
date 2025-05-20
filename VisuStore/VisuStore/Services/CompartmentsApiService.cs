using Newtonsoft.Json;
using VisuStore.Models;

namespace VisuStore.Services
{
    public class CompartmentsApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000";

        public CompartmentsApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<Compartment>> GetCompartmentsByRackAsync(int RackId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/compartments?rack_id={RackId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();

                var compartments = JsonConvert.DeserializeObject<List<Compartment>>(json);

                return compartments ?? new List<Compartment>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching compartments for rack {RackId}: {ex.Message}");
                return new List<Compartment>();
            }
        }
    }
}
