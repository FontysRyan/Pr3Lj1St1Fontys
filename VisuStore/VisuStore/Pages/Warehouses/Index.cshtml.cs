using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using VisuStore.Models;
using VisuStore.Services;

namespace VisuStore.Pages.Warehouses
{
    public class IndexModel : PageModel
    {
        private readonly WarehousesApiService _service;
        public List<Warehouse> Warehouses { get; set; }

        public IndexModel(WarehousesApiService service)
        {
            _service = service;
        }

        // Bij pagina-oproep worden warehouses opgehaald van de API
        public async Task OnGetAsync()
        {
            Warehouses = await _service.GetWarehousesAsync();
        }
    }
}
