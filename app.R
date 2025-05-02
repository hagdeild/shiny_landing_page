library(shiny)
library(shinymanager)
library(bslib)
library(fontawesome)

# ---- 1. credentials table ----
credentials <- data.frame(
  user = Sys.getenv("SHINY_AUTH_USER"),
  password = Sys.getenv("SHINY_AUTH_PASSWORD"),
  stringsAsFactors = FALSE
)

# ---- 2. build the raw UI with improved styling ----
landing_raw <- page_fillable(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#3498db",
    "enable-shadows" = TRUE,
    "border-radius" = "0.5rem"
  ),
  
  # Header with logo and title
  div(
    class = "d-flex align-items-center mb-4 p-3 bg-primary text-white rounded shadow-sm",
    # Use a local logo file from www directory
    tags$img(src = "logo.png", height = "50px", class = "me-3"),
    h2("My Shiny Apps", class = "m-0")
  ),
  
  # Main content card
  card(
    class = "shadow-sm",
    card_header(
      class = "bg-light",
      h4("Available Applications", class = "m-0")
    ),
    card_body(
      # App cards in a grid layout
      div(
        class = "row row-cols-1 row-cols-md-2 g-4",
        
        # App 1
        div(
          class = "col",
          card(
            class = "h-100 hover-shadow",
            card_header(tags$h5("App 1", class = "card-title m-0"), class = "bg-light"),
            card_body(
              p("Description of App 1 and its functionality. Replace with your own description."),
              div(class = "d-flex align-items-center",
                  fontawesome::fa("chart-line", fill = "#3498db", height = "1.5em"),
                  span("Data Visualization", class = "ms-2 text-muted")
              )
            ),
            card_footer(
              actionButton("btn_app1", "Launch App", 
                           class = "btn-primary", 
                           onclick = "window.open('https://<yourapp1>.shinyapps.io', '_blank')")
            )
          )
        ),
        
        # App 2
        div(
          class = "col",
          card(
            class = "h-100 hover-shadow",
            card_header(tags$h5("App 2", class = "card-title m-0"), class = "bg-light"),
            card_body(
              p("Description of App 2 and its functionality. Replace with your own description."),
              div(class = "d-flex align-items-center",
                  fontawesome::fa("table", fill = "#3498db", height = "1.5em"),
                  span("Data Analysis", class = "ms-2 text-muted")
              )
            ),
            card_footer(
              actionButton("btn_app2", "Launch App", 
                           class = "btn-primary", 
                           onclick = "window.open('https://<yourapp2>.shinyapps.io', '_blank')")
            )
          )
        )
      )
    )
  ),
  
  # Footer
  div(
    class = "mt-4 p-3 text-center text-muted",
    hr(),
    p("© 2025 My Organization", class = "mb-0"),
    tags$style(HTML("
      /* Custom CSS */
      .hover-shadow:hover {
        box-shadow: 0 .5rem 1rem rgba(0,0,0,.15)!important;
        transition: box-shadow 0.3s ease-in-out;
      }
      .card {
        transition: all 0.3s ease-in-out;
      }
    "))
  )
)

# ---- 3. Add custom styling for the auth panel ----
custom_auth_css <- tags$style(HTML("
  /* Auth panel styling */
  .panel-auth {
    border-radius: 0.5rem;
    box-shadow: 0 .5rem 1rem rgba(0,0,0,.15);
  }
  .panel-auth .panel-heading {
    background-color: #3498db !important;
    color: white !important;
    border-radius: 0.5rem 0.5rem 0 0;
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

# ---- 4. wrap the UI with secure_app() with custom styling ----
ui <- secure_app(
  landing_raw,
  tag_img = tags$img(src = "logo.png", width = 50),
  background = list(
    color = "#f8f9fa",
    image = NULL
  ),
  theme = shinythemes::shinytheme("flatly"),
  head_auth = custom_auth_css  # Add custom CSS
)

# ---- 5. protect the server with secure_server() ----
server <- function(input, output, session) {
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  # Handle buttons
  observeEvent(input$btn_app1, {
    session$sendCustomMessage("shinyapps:openLink", "https://<yourapp1>.shinyapps.io")
  })
  
  observeEvent(input$btn_app2, {
    session$sendCustomMessage("shinyapps:openLink", "https://<yourapp2>.shinyapps.io")
  })
}

# ---- 6. run the app ----
shinyApp(ui, server)