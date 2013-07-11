$regexPageNumFilename = [regex]'^(\d+)[,-]';
$regexPageNum = [regex] '(?<=first-page-number\s+=\s+\#)(\d+)';
$regexDates = [regex]'(\d+)-(\d+)';
$regexTitle = [regex]'(?<!sub)title\s+=\s+[^\n\r]*?\\smallCaps[^\"\r\n]*\"([^"]*)\"'
#$regex = [regex]'\\lyricmode\s*(?<open>{)(?:(?:(?<quote>[''"])|[^''"{}])*(?(open)((?<-open>})|(?<open>{))|))*(?(open)(?!))(?(quote)|(?!))';
$regex = [regex]'[a-zA-Z]{2,}(?<![a-g][ei]s)''|(?<!#)''[a-zA-Z]|\\lyricmode\s*{[^}]*''';
$files = (ls -filter *.ly);
$version = '\version "2.14.2"';
$include = '\include "../util.ly"';
$index = '';
foreach ($_ in $files) {
  echo $_;
  $content = $f = Get-Content $_ -Encoding UTF8;
  #$content = $f -replace "OFL Sorts Mill Goudy","GoudyOlSt BT";
  #if($content -contains $include) {} else {
  #  $content[0] = "$include
#"+$content[0];
#  }
#  if($content -contains $version){} else {
#    $content[0] = "$version
#"+$content[0];
#  }
  $content = $content -replace $regexDates,'$1–$2';
  $match = $regexPageNumFilename.Match($_.Name);
  if($match.Success) {
      $pagenum = $match.Groups[1].Value;
      $match = $regexPageNum.Match($f);
      if($match.Success) {
        $cpagenum = $match.Groups[1].Value;
        if($cpagenum -ne $pagenum) {
          $content = $content -ireplace $regexPageNum, $pagenum;
        }
      } else {
        echo "No page number line found in $_.";
      }
      $match = $regex.Match($f);
      if($match.Success) {
        echo "Neutral quotes found in $_. $match"
      }
      $m = $regexTitle.Match($content);
      while($m.Success) {
        $index += $pagenum + '|' + $m.Groups[1].Value + '
';
        $m = $regexTitle.match($content, $m.Index + $m.Length);
      }
   } else {
     echo "No page number found in filename $_.";
   }
   if($content -ne $f) {
     $content | out-file ($_.Name) -Encoding UTF8;
   }
}
$index | out-file 'index.txt' -Encoding UTF8