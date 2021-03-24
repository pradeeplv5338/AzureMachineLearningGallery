
# Analyze the command line args
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 4) {
  stop(sprintf("Invalid arguments count, expect: 4, actual: %d.", length(args)))
}
dataset1 <- args[1]
dataset2 <- args[2]
result_dataset1 <- args[3]
result_dataset2 <- args[4]

# Make sure pandas is ready
library("reticulate")
pd <- import("pandas")

# In the output directory of built-in components, it will contain a folder with a parquet file and some meta data, here we simply get the parquet file and read it.
load_parquet_from_directory <- function(path){
    files <- list.files(path, pattern="*.parquet")
    if (length(files) != 1) {
        stop(sprintf("Invalid parquet folder '%s', it must contain one parquet file.", path))
    }
    parquet_path <- paste(path, files[1], sep=.Platform$file.sep)
    print(sprintf("Load dataframe from parquet file %s:", parquet_path))
    r_dataframe <- pd$read_parquet(parquet_path, "pyarrow")
    print(r_dataframe)
    return(r_dataframe)
}

# To write the data which could be consumed by built-in component, we need to save the dataframe as a parquet file in the directory.
save_dataframe_as_parquet_to_directory <- function(df, path, filename='data.parquet'){
    py_dataframe <- r_to_py(df)
    parquet_path <- paste(path, filename, sep=.Platform$file.sep)
    print(sprintf("Save dataframe to parquet file %s:", parquet_path))
    print(df)
    py_dataframe$to_parquet(parquet_path, "pyarrow")
}

# You may put your code in this function, this function is similar to the function in the built-in component Execute R Script
azureml_main <- function(dataframe1, dataframe2){
  print("R script run.")
  # Return datasets as a Named List
  return(list(dataset1=dataframe1, dataset2=dataframe2))
}

# Read the dataframes
df1 <- load_parquet_from_directory(dataset1)
df2 <- load_parquet_from_directory(dataset2)

# Run your function
results <- azureml_main(df1, df2)

# Write the dataframes
result1 <- results$dataset1
result2 <- results$dataset2
save_dataframe_as_parquet_to_directory(result1, result_dataset1)
save_dataframe_as_parquet_to_directory(result2, result_dataset2)
