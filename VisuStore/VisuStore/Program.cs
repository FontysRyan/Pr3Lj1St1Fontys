using VisuStore.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

builder.Services.AddHttpClient<WarehousesApiService>();

builder.Services.AddHttpClient<RacksApiService>();

builder.Services.AddHttpClient<CompartmentsApiService>();

builder.Services.AddHttpClient<ShelvesApiService>();

builder.Services.AddHttpClient<ProductsApiService>();

builder.Services.AddHttpClient<ProductLocationsApiService>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
