# PimaDiabetesDashboard 🩺📊

**Interactive Shiny dashboard for the Pima Indians Diabetes dataset**  
Created as a learning project during an **R Shiny Workshop**.

This dashboard demonstrates how to build interactive data visualizations and key metrics in R using `shiny` and `shinydashboard`. Features include:

- Filter patients by **diabetes status** and **age range**  
- Display **key metrics**: total patients, average glucose, % diabetes positive  
- Visualizations:
  - Age histogram
  - Diabetes status count bar chart
  - Glucose boxplot by diabetes status
  - Glucose vs. mass scatter plot
- Download filtered dataset as CSV

## How to Run 🖥️
### Locally
1. Open `app.R` in **RStudio** (or any R IDE). 
2. Install required packages if not already installed:
```
install.packages(c("shiny", "shinydashboard", "mlbench", "ggplot2", "dplyr", "viridis", "readr"))
```
3. Click Run App in RStudio, or run in the console:
```
shiny::runApp("app.R")
```
### On Posit (ShinyApps.io)

This app is also ready to be deployed on Posit. You can publish it by pointing Posit to the folder containing app.R, or using rsconnect::deployApp():
```
library(rsconnect)
rsconnect::deployApp("path/to/your/app/folder")
```
After deployment, the dashboard will be available online via a Posit URL.
   
