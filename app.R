# Load and prepare dataset
data(PimaIndiansDiabetes)
df <- PimaIndiansDiabetes

# Replace 0s in key variables with NA (as 0 is biologically invalid)
df <- df %>%
  mutate(
    glucose = ifelse(glucose == 0, NA, glucose),
    mass = ifelse(mass == 0, NA, mass),
    age = ifelse(age == 0, NA, age)
  )

ui <- dashboardPage(
  dashboardHeader(title = "Pima Diabetes Dashboard"),
  
  dashboardSidebar(
    selectInput("status", "Diabetes Status:",
                choices = c("All", "pos", "neg"),
                selected = "All"),
    sliderInput("ageRange", "Age Range:", min = 0, max = 100, value = c(20, 60)),
    br(),
    downloadButton("downloadData", "Download Filtered Data")
  ),
  
  dashboardBody(
    fluidRow(
      valueBoxOutput("totalPatients"),
      valueBoxOutput("avgGlucose"),
      valueBoxOutput("percentPositive")
    ),
    fluidRow(
      box(title = "Age Histogram", status = "primary", solidHeader = TRUE,
          plotOutput("histAge"), width = 6),
      box(title = "Diabetes Status Count", status = "primary", solidHeader = TRUE,
          plotOutput("barDiabetes"), width = 6)
    ),
    fluidRow(
      box(title = "Glucose Boxplot by Diabetes Status", status = "primary", solidHeader = TRUE,
          plotOutput("boxGlucose"), width = 6),
      box(title = "Glucose vs. mass", status = "primary", solidHeader = TRUE,
          plotOutput("scatterPlot"), width = 6)
    ),
    uiOutput("errorText")
  )
)

server <- function(input, output, session) {
  
  # Filtered dataset
  filtered <- reactive({
    temp <- df %>%
      filter(!is.na(glucose), !is.na(mass), !is.na(age)) %>%
      filter(age >= input$ageRange[1], age <= input$ageRange[2])
    
    if (input$status != "All") {
      temp <- temp %>% filter(diabetes == input$status)
    }
    
    if (nrow(temp) == 0) return(NULL)
    return(temp)
  })
  
  # Save filtered data
  output$downloadData <- downloadHandler(
    filename = function() {
      "diabetes.csv"
    },
    content = function(file) {
      data <- filtered()
      if (!is.null(data)) {
        write_csv(data, file)
      }
    }
  )
  
  # Metrics
  output$totalPatients <- renderValueBox({
    data <- filtered()
    valueBox(value = if (!is.null(data)) nrow(data) else 0,
             subtitle = "Total Patients",
             icon = icon("users"),
             color = "teal")
  })
  
  output$avgGlucose <- renderValueBox({
    data <- filtered()
    valueBox(value = if (!is.null(data)) round(mean(data$glucose, na.rm = TRUE), 1) else "NA",
             subtitle = "Average Glucose",
             icon = icon("heartbeat"),
             color = "purple")
  })
  
  output$percentPositive <- renderValueBox({
    data <- filtered()
    if (!is.null(data)) {
      pct <- round(mean(data$diabetes == "pos") * 100, 1)
      valueBox(paste0(pct, "%"),
               subtitle = "% Diabetes Positive",
               icon = icon("percent"),
               color = "maroon")
    } else {
      valueBox("NA", subtitle = "% Diabetes Positive", icon = icon("percent"), color = "maroon")
    }
  })
  
  # Plots
  output$histAge <- renderPlot({
    data <- filtered()
    validate(need(!is.null(data), "No data available for this selection."))
    ggplot(data, aes(x = age)) +
      geom_histogram(bins = 10, fill = viridis(1), color = "white") +
      labs(x = "Age", y = "Count")
  })
  
  output$barDiabetes <- renderPlot({
    data <- filtered()
    validate(need(!is.null(data), "No data available for this selection."))
    ggplot(data, aes(x = diabetes, fill = diabetes)) +
      geom_bar() +
      scale_fill_viridis(discrete = TRUE, option = "D") +
      labs(x = "Diabetes Status", y = "Count") +
      theme(legend.position = "none")
  })
  
  output$boxGlucose <- renderPlot({
    data <- filtered()
    validate(need(!is.null(data), "No data available for this selection."))
    ggplot(data, aes(x = diabetes, y = glucose, fill = diabetes)) +
      geom_boxplot() +
      scale_fill_viridis(discrete = TRUE) +
      labs(x = "Diabetes Status", y = "Glucose") +
      theme(legend.position = "none")
  })
  
  output$scatterPlot <- renderPlot({
    data <- filtered()
    validate(need(!is.null(data), "No data available for this selection."))
    ggplot(data, aes(x = mass, y = glucose, color = diabetes)) +
      geom_point(alpha = 0.7) +
      scale_color_viridis(discrete = TRUE) +
      labs(x = "mass", y = "Glucose", color = "Diabetes")
  })
  
  # Optional UI warning
  output$errorText <- renderUI({
    if (is.null(filtered())) {
      div(style = "color:red; font-weight:bold;",
          "⚠️ No valid data available for the selected filters. Please adjust your settings.")
    }
  })
}

shinyApp(ui, server)
