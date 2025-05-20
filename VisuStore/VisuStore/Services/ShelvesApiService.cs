using Newtonsoft.Json;
using VisuStore.Models;

namespace VisuStore.Services
{
    public class ShelvesApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000";

        public ShelvesApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<Shelf>> GetShelvesByCompartmentAsync(int CompartmentId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/shelves?compartment_id={CompartmentId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();

                var shelves = JsonConvert.DeserializeObject<List<Shelf>>(json);

                return shelves ?? new List<Shelf>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching shelves for compartment {CompartmentId}: {ex.Message}");
                return new List<Shelf>();
            }
        }
    }
}
