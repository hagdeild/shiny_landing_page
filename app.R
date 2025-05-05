library(shiny)
library(shinymanager)
library(bslib)

# ---- 1. credentials table ----
credentials <- data.frame(
  user = Sys.getenv("SHINY_AUTH_USER"),
  password = Sys.getenv("SHINY_AUTH_PASSWORD"),
  stringsAsFactors = FALSE
)

# ---- 2. Define apps configuration ----
# This is the key change: a single data frame that contains all app information
# To add a new app, simply add a new row to this data frame
apps_config <- data.frame(
  app_id = c("app1", "app2"),
  app_title = c("Styrkjakerfi VR - Reiknivél", "FVSA kerfi fyrir VR"),
  app_description = c(
    "Reiknivél fyrir nýja hugmynd að styrkjakerfi VR",
    "Reiknivél sem heimfærir styrkjakerfi FVSA yfir á VR"
  ),
  app_url = c(
    "https://vrstettarfelag.shinyapps.io/varasjodur_tillaga_utfaersla/",
    "https://vrstettarfelag.shinyapps.io/varasjodur_utfaersla/"
  ),
  stringsAsFactors = FALSE
)

# ---- 3. Function to generate app cards ----
# This function creates a card for each app based on the configuration
generate_app_card <- function(app_info) {
  div(
    class = "card mb-4 border",
    div(
      class = "card-body",
      h5(app_info$app_title, class = "card-title"),
      p(app_info$app_description, class = "text-muted"),
      actionButton(
        paste0("btn_", app_info$app_id), 
        HTML("Opna app &raquo;"), 
        class = "btn btn-dark", 
        onclick = paste0("window.open('", app_info$app_url, "', '_blank')")
      )
    )
  )
}

# ---- 4. build the raw UI with improved styling ----
landing_raw <- page_fillable(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    "enable-shadows" = FALSE,
    "border-radius" = "0.25rem"
  ),
  
  # Header with just the title
  div(
    class = "container mt-4",
    h1("Reiknivélar og mælaborð VR", class = "mb-4")
  ),
  
  # App cards in vertical layout
  div(
    class = "container",
    # Dynamically generate app cards from configuration
    lapply(1:nrow(apps_config), function(i) {
      generate_app_card(apps_config[i, ])
    })
  ),
  
  # Empty footer - no CSS needed
  div()
)

# ---- 5. Add custom styling for the auth panel ----
custom_auth_css <- tags$style(HTML("
  /* Auth panel styling */
  .panel-auth {
    border-radius: 0.25rem;
    box-shadow: 0 .25rem 0.5rem rgba(0,0,0,.1);
  }
  .panel-auth .panel-heading {
    background-color: #3498db !important;
    color: white !important;
    border-radius: 0.25rem 0.25rem 0 0;
  }
  .panel-auth .form-group {
    margin-bottom: 1rem;
  }
  .panel-auth .btn-primary {
    background-color: #3498db !important;
    border-color: #3498db !important;
    width: 100%;
  }
"))

# ---- 6. wrap the UI with secure_app() with custom styling ----
ui <- secure_app(
  landing_raw,
  tag_img = tags$img(src = "logo.png", width = 50),
  background = list(
    color = "#ffffff",
    image = NULL
  ),
  theme = shinythemes::shinytheme("flatly"),
  head_auth = custom_auth_css  # Add custom CSS
)

# ---- 7. protect the server with secure_server() ----
server <- function(input, output, session) {
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  # Dynamically handle button clicks for all apps
  lapply(1:nrow(apps_config), function(i) {
    app_id <- apps_config$app_id[i]
    app_url <- apps_config$app_url[i]
    
    observeEvent(input[[paste0("btn_", app_id)]], {
      session$sendCustomMessage("shinyapps:openLink", app_url)
    })
  })
}

# ---- 8. run the app ----
shinyApp(ui, server)