    server = function(input, output){
        output$contents <- renderTable({
            inFile <- input$file1

            if(is.null(inFile))
                return(NULL)

            ext <- tools::file_ext(inFile$name)
            file.rename(inFile$datapath,
               paste(inFile$datapath, ext, sep="."))
            read_excel(paste(inFile$datapath, ext, sep="."), 1)
         })
        }
 
