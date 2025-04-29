# Ladda ner SCB:s egna API
library(pxweb)

# URL till tabellen "Prisstatistik småhus"
url <- "https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BO/BO0501/BO0501B/FastprisSHRegionAr"

# Förfrågan gäller köpta småhus inom Malmö kommun
query <- list(
    Region = c("1280"), # Malmö kommun
    Fastighetstyp = c("220"), # Permanent bostad
    ContentsCode = c("BO0501C1", "BO0501C2", "BO0501C4"), # Antal småhus, Köpeskilling, medelvärde i tkr och Köpesskillingkoefficient.
    Tid = c("2020", "2021", "2022", "2023") # Antal år
)

# Hämta data
scb_data <- pxweb_get(url = url, query = query)

# Konvertera till data.frame
scb <- as.data.frame(scb_data)

# Spara som CSV i data/external
write.csv(scb, file = "data/external/scb_data.csv", row.names = FALSE)

# Kontrollera att filen är sparad
print("CSV-file saved at: data/external/scb_data.csv")
