using Newtonsoft.Json;
using VisuStore.Models;

namespace VisuStore.Services
{
    public class RacksApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000"; // Pas aan indien nodig

        public RacksApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        // ✅ Haal racks op per warehouse ID
        public async Task<List<Rack>> GetRacksByWarehouseAsync(int warehouseId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/racks/by-warehouse/{warehouseId}");
                response.EnsureSuccessStatusCode();
                var json = await response.Content.ReadAsStringAsync();

                var racks = JsonConvert.DeserializeObject<List<Rack>>(json);

                return racks ?? new List<Rack>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching racks for warehouse {warehouseId}: {ex.Message}");
                return new List<Rack>();
            }
        }
    }
}
