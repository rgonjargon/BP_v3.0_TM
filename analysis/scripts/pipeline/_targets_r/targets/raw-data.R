# Raw data
# When switching to real data: add tar_target(raw_data_file, "analysis/data/foo.csv", format = "file")
# and make raw_data read from that path so the pipeline invalidates when the data file changes.
tar_target(raw_data, 
           airquality
)

# read_csv(here("analysis/data/[df.file.name].csv"), show_col_types = FALSE) # Import .csv file
# read_excel(here("analysis/data/[df.file.name].xlsx"), sheet = 1) # Import .xlsx file
