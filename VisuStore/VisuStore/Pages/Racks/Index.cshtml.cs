using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using VisuStore.Models;
using VisuStore.Services;

namespace VisuStore.Pages.Racks
{
    public class IndexModel : PageModel
    {
        private readonly RacksApiService _racksService;

        public IndexModel(RacksApiService racksService)
        {
            _racksService = racksService;
        }

        [BindProperty(SupportsGet = true)]
        public int WarehouseId { get; set; }

        public List<Rack> Racks { get; set; } = new();

        public async Task OnGetAsync(int Id)
        {
            Racks = await _racksService.GetRacksByWarehouseAsync(Id);
        }
    }
}
