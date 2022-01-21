import os


path = "C:\\Users\\irina.zarubina\\Desktop\\ed"
ex = ".pdf"

if os.path.exists(path):
  if os.path.isdir(path):
    for root_folder, folders, files in os.walk(path):
      for file in files:
        file_path = os.path.join(root_folder, file)
        file_extention = os.path.splitext(file_path)[1]
        if ex == file_extention:
          os.remove(file_path)

            


        

