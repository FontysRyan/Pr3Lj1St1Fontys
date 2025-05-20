using Newtonsoft.Json; // <-- Newtonsoft gebruiken
using VisuStore.Models;

namespace VisuStore.Services
{
    public class ProductsApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000";

        public ProductsApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<Product>> GetProductsByWarehouseAsync(int warehouseId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/products/by-warehouse/{warehouseId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();

                // Gebruik Newtonsoft
                var products = JsonConvert.DeserializeObject<List<Product>>(json);
                return products ?? new List<Product>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching products for warehouse {warehouseId}: {ex.Message}");
                return new List<Product>();
            }
        }

        public async Task<Product?> GetProductByIdAsync(int productId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"{_baseUrl}/select/products?product_id={productId}");
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();

                // Newtonsoft expects an array, dus pak de eerste
                var productList = JsonConvert.DeserializeObject<List<Product>>(json);

                return productList?.FirstOrDefault();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching product {productId}: {ex.Message}");
                return null;
            }
        }
    }
}
