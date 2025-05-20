using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using VisuStore.Models;
using VisuStore.Services;

namespace VisuStore.Pages.Products
{
    public class IndexModel : PageModel
    {
        private readonly ProductsApiService _productService;
        private readonly WarehousesApiService _warehouseService;

        public IndexModel(ProductsApiService productService, WarehousesApiService warehouseService)
        {
            _productService = productService;
            _warehouseService = warehouseService;
        }

        [BindProperty(SupportsGet = true)]
        public int WarehouseId { get; set; }

        public List<Product> Products { get; set; }
        public Warehouse CurrentWarehouse { get; set; }

        public async Task<IActionResult> OnGetAsync(int Id)
        {
            Console.WriteLine(WarehouseId);
            // Haal warehouse info op voor de titel of context
            CurrentWarehouse = await _warehouseService.GetWarehouseAsync(Id);

            // Haal bijbehorende producten op
            Products = await _productService.GetProductsByWarehouseAsync(Id);

            return Page();
        }
    }
}
