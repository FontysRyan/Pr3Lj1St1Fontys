using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using VisuStore.Models;
using VisuStore.Services;

namespace VisuStore.Pages.Compartments
{
    public class IndexModel : PageModel
    {
        private readonly CompartmentsApiService _compartmentService;

        public IndexModel(CompartmentsApiService compartmentService)
        {
            _compartmentService = compartmentService;
        }

        public List<Compartment> Compartments { get; set; } = new();

        [BindProperty(SupportsGet = true)]
        public int RackId { get; set; }

        public async Task OnGetAsync(int Id)
        {
            Compartments = await _compartmentService.GetCompartmentsByRackAsync(Id);
        }
    }
}
