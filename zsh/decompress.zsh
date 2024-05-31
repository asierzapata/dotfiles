decompress() {
  local file=$1
  case $file in
    *.tar.gz|*.tgz) tar -xvf $file ;;
    *.zip) unzip $file ;;
    *.gz) gunzip $file ;;
    *.bz2) bunzip2 $file ;;
    *.xz) unxz $file ;;
    *.lzma) unlzma $file ;;
    *.7z) 7za x $file ;;
    *.rar) unrar x $file ;;
    *.zipx) unzip $file ;;
    *.tar) tar -xvf $file ;;
    *) echo "Unsupported file type: $file" ;;
  esac
}
