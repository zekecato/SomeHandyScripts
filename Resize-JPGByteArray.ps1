#This function takes a jpg byte array, resizes it, and returns the new byte array with the new size.
function Resize-JPGByteArray {
    param(
    $ByteArray,
    [int]$NewWidth,
    [int]$NewHeight
    )

#create image object in memory from byte array
$oldimgMemStream = New-Object System.IO.MemoryStream
$oldimgMemStream.write($ByteArray, 0,$ByteArray.length)
$OldImage = [System.Drawing.Bitmap]::FromStream($oldimgMemStream)

#define new dimensions
$NewWidth = 50
$NewHeight = 50

#create new image container
$NewImage = new-object System.Drawing.Bitmap $NewWidth,$NewHeight

#Draw old image in new, smaller container
$Graphics = [System.Drawing.Graphics]::FromImage($NewImage)
$Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$Graphics.DrawImage($OldImage, 0, 0, $NewWidth, $NewHeight) 

#Save new image as byte array
$newimgmemstream = New-Object System.IO.MemoryStream
$NewImage.Save($newimgmemstream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$newimgBytes = $newimgmemstream.ToArray()

#dispose of images and memory streams
$NewImage.Dispose()
$OldImage.Dispose()
$newimgmemstream.Dispose()
$oldimgMemStream.Dispose()

return $newimgBytes
}