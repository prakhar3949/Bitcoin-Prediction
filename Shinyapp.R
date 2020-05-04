library(shiny)
library(shinythemes)

ui <- fluidPage(
  titlePanel("Bitcoin Plots"),
  theme = shinythemes::shinytheme("superhero"),
  sidebarLayout( sidebarPanel( selectInput('plotname', 'Select a plot from the dropdown below',
                                           selected = '20 Day Forecast',
                                           choices = c(
                                             'Time Series plot of Data',
                                             'Decompostition of Time Series',
                                             'Transformed time series with ACF and PACF',
                                             'Residual Analysis',
                                             '20 Day Forecast'
                                             
                                           )
                                           
                                           
                                           
  )),
  
  
  #output
  mainPanel(  plotOutput('timeseries',width="900",height = "400px")
              
  )
  
  
  ))

server <- function(input,output,session){
  
  
  
  
  output$timeseries <- renderPlot({
    
    
    
    
    if(input$plotname == 'Time Series plot of Data') 
    {
      
      plot(ts_train) 
      
    }
    
    if(input$plotname == 'Decompostition of Time Series') 
    {
      
      
      plot(coin_decomp)
    }
    
    if(input$plotname == 'Transformed time series with ACF and PACF') 
    {
      log(1+coin_sub$mean_price) %>% diff() %>% diff(lag=1) %>% ggtsdisplay()
    }
    
    if(input$plotname == 'Residual Analysis') 
    {
      layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
      plot(updated_fit$residuals) 
      acf(updated_fit$residuals,ylim=c(-1,1)) 
      pacf(updated_fit$residuals,ylim=c(-1,1))
    }
    
    if(input$plotname == '20 Day Forecast') 
    {
      updated_fit %>% forecast(h=20) %>% autoplot()
    }
    
  })
}

shinyApp(ui=ui, server = server)
