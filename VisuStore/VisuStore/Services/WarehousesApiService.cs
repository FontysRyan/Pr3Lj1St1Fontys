using Newtonsoft.Json; // <-- LET OP: toegevoegd
using System.Text;
using VisuStore.Models;

namespace VisuStore.Services
{
    public class WarehousesApiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl = "http://192.168.133.123:5000";

        public WarehousesApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<List<Warehouse>> GetWarehousesAsync()
        {
            try
            {
                var GET_Result = await _httpClient.GetAsync($"{_baseUrl}/select/warehouses");
                GET_Result.EnsureSuccessStatusCode();
                var GET_Json = await GET_Result.Content.ReadAsStringAsync();

                var warehouses = JsonConvert.DeserializeObject<List<Warehouse>>(GET_Json); // <-- Newtonsoft gebruikt
                return warehouses ?? new List<Warehouse>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching warehouses: {ex.Message}");
                return new List<Warehouse>();
            }
        }

        public async Task<bool> AddWarehouseAsync(Warehouse warehouse)
        {
            try
            {
                var POST_Json = JsonConvert.SerializeObject(warehouse); // <-- Newtonsoft gebruikt
                var POST_Result = await _httpClient.PostAsync($"{_baseUrl}/insert/warehouses",
                    new StringContent(POST_Json, Encoding.UTF8, "application/json"));
                return POST_Result.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding warehouse: {ex.Message}");
                return false;
            }
        }

        public async Task<Warehouse?> GetWarehouseAsync(int id)
        {
            try
            {
                var GET_Result = await _httpClient.GetAsync($"{_baseUrl}/select/warehouses?warehouse_id={id}");
                GET_Result.EnsureSuccessStatusCode();
                var GET_Json = await GET_Result.Content.ReadAsStringAsync();

                var warehouses = JsonConvert.DeserializeObject<List<Warehouse>>(GET_Json); // JSON array ⇒ lijst
                return warehouses?.FirstOrDefault();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching warehouse {id}: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UpdateWarehouseAsync(Warehouse warehouse)
        {
            try
            {
                var PUT_Json = JsonConvert.SerializeObject(warehouse);
                var PUT_Result = await _httpClient.PutAsync(
                    $"{_baseUrl}/update/warehouses/{warehouse.Warehouse_Id}",
                    new StringContent(PUT_Json, Encoding.UTF8, "application/json")
                );
                return PUT_Result.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating warehouse {warehouse.Warehouse_Id}: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> DeleteWarehouseAsync(int id)
        {
            try
            {
                var DEL_Result = await _httpClient.DeleteAsync($"{_baseUrl}/delete/warehouses/{id}");
                return DEL_Result.IsSuccessStatusCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting warehouse {id}: {ex.Message}");
                return false;
            }
        }
    }
}
