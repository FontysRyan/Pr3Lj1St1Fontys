using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using VisuStore.Models;
using VisuStore.Services;

namespace VisuStore.Pages.Shelves
{
    public class IndexModel : PageModel
    {
        private readonly ShelvesApiService _shelfService;

        private readonly ProductLocationsApiService _productLocationsApiService;

        private readonly ProductsApiService _productsApiService;

        public IndexModel(ShelvesApiService shelfService, ProductLocationsApiService locationService, ProductsApiService productsApiService)
        {
            _shelfService = shelfService;
            _productLocationsApiService = locationService;
            _productsApiService = productsApiService;
        }

        public List<Shelf> Shelves { get; set; } = new();

        public List<ProductLocation> ProductLocations { get; set; }

        [BindProperty(SupportsGet = true)]
        public int CompartmentId { get; set; }

        public async Task OnGetAsync(int Id)
        {
            Shelves = await _shelfService.GetShelvesByCompartmentAsync(Id);

            ProductLocations = await _productLocationsApiService.GetAllProductLocationsAsync();

            foreach (var pl in ProductLocations)
            {
                // Ophalen van bijbehorend product
                pl.Product = await _productsApiService.GetProductByIdAsync(pl.Product_Id);
            }
        }
    }
}
