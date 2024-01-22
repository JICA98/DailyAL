# import required module
import os

scanDirectoy = './lib/src/'
exportedFileName = './lib/commons.dart'

# global variable to store the final data
content = """
// AUTO-GENERATED CONTENT
library dal_commons;

"""

def overDirectory(dir):
    global content
    for filename in os.listdir(dir):
        f = os.path.join(dir, filename)

        if os.path.isfile(f) and not f.__contains__('.g.'):
            content += 'export \'{}\';\n'.format(f.replace('/lib', ''))
        elif os.path.isdir(f):
            overDirectory(f)

# recursively loop through all the directories and populates the content      
overDirectory(scanDirectoy)

# writes to the output file after generating the content
with open(exportedFileName, 'w') as common_export:
    common_export.write(content)
    