using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using VisuStore.Models;

namespace VisuStore.Services
{
    public class ProductLocationsApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000";

        public ProductLocationsApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        // ✅ Algemene lijst ophalen
        public async Task<List<ProductLocation>> GetAllProductLocationsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/product_locations");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                var locations = JsonConvert.DeserializeObject<List<ProductLocation>>(json);

                return locations ?? new List<ProductLocation>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching all product locations: {ex.Message}");
                return new List<ProductLocation>();
            }
        }

        // ✅ Op product_id filteren
        public async Task<List<ProductLocation>> GetLocationsByProductIdAsync(int productId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/product_locations?product_id={productId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                var locations = JsonConvert.DeserializeObject<List<ProductLocation>>(json);

                return locations ?? new List<ProductLocation>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching product locations for product {productId}: {ex.Message}");
                return new List<ProductLocation>();
            }
        }

        // ✅ Op zone_id filteren
        public async Task<List<ProductLocation>> GetLocationsByZoneIdAsync(int zoneId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/product_locations?zone_id={zoneId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                var locations = JsonConvert.DeserializeObject<List<ProductLocation>>(json);

                return locations ?? new List<ProductLocation>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching product locations for zone {zoneId}: {ex.Message}");
                return new List<ProductLocation>();
            }
        }
    }
}
