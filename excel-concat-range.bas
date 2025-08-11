Attribute VB_Name = "Module1"
Public Function ConcatRange(data As Range, Optional delim As String = ",") As String
    Dim concatStr As String
    concatStr = ""
    For Each cell In data
        concatStr = concatStr & delim & cell.Value
    Next cell
    concatStr = Right(concatStr, Len(concatStr) - Len(delim))
    ConcatRange = concatStr
End Function
