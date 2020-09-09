import sys
import tarfile

if(len(sys.argv) != 3):
    print("extract_tar_xz archive_file destination")
    sys.exit(-1)
          
tar = tarfile.open(sys.argv[1])
tar.extractall(sys.argv[2])
tar.close()
