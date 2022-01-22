import os


path = []
ex = ".pdf"


for root, dirs, files in os.walk("C:\\users"):
  if '\email_send' in root:
      mass = root
      path.append(mass)

try:
  for i in path:
    if os.path.exists(i):
      if os.path.isdir(i):
        for root_folder, folders, files in os.walk(i):
          for file in files:
            file_path = os.path.join(root_folder, file)
            file_extention = os.path.splitext(file_path)[1]
            if ex == file_extention:
              os.remove(file_path)

    else:
      print('Такой дириктории нет')

except:
  print('Такой дириктории нет')

            


        

